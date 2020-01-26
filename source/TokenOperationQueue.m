//
//  TokenQueue.m
//  TokenOperation
//
//  Created by 陈雄 on 2018/5/3.
//  Copyright © 2018年 com.feelings. All rights reserved.
//

#import "TokenOperationQueue.h"
#import <pthread.h>

@interface TokenOperationQueue ()

/// 多线程读写保护专用锁
@property (nonatomic, assign) pthread_mutex_t mutexLock;

/// 真正串/并行执行任务的队列
@property (nonatomic, copy, nonnull) dispatch_queue_t serialQueue;
@property (nonatomic, copy, nonnull) dispatch_queue_t concurrentQueue;
/// 所有任务执行必须进组，任务完成出组，为waitUntilFinished服务，可以阻塞当前线程
@property (nonatomic, copy, nonnull) dispatch_group_t operationsGroup;

/// 保存各个优先级的等待执行的任务队列
@property (nonatomic, strong, nonnull) NSMutableArray <dispatch_block_t> *highOperations;
@property (nonatomic, strong, nonnull) NSMutableArray <dispatch_block_t> *defaultOperations;
@property (nonatomic, strong, nonnull) NSMutableArray <dispatch_block_t> *lowOperations;
@property (nonatomic, strong, nonnull) NSMutableArray <dispatch_block_t> *backgroundOperations;
/// 控制最大并发数的信号量，所有的当_maxConcurrent大于1时的任务是否可以执行都需要通过该信号量控制
@property (nonatomic, copy, nonnull) dispatch_semaphore_t maxConcurrentSemaphore;

@property (nonatomic, assign) TokenQueuePriority lastPriorityState;

@end

@implementation TokenOperationQueue {
    NSUInteger _maxConcurrent;
}

+(instancetype)sharedQueue{
    static TokenOperationQueue *obj;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSUInteger defaultNumber = [[NSProcessInfo processInfo] activeProcessorCount]*2;
        obj = [[TokenOperationQueue alloc] initWithMaxConcurrent:defaultNumber];
    });
    return obj;
}

-(instancetype)initWithMaxConcurrent:(NSUInteger)maxConcurrent{
    if (self = [super init]) {
        /// 初始化多线程读写保护专用锁
        pthread_mutexattr_t attr;
        pthread_mutexattr_init(&attr);
        pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE);
        pthread_mutex_init(&_mutexLock, &attr);
        /// 设置最大并发量
        _maxConcurrent = maxConcurrent;
        /// 初始化控制最大并发数的信号量
        _maxConcurrentSemaphore = dispatch_semaphore_create(_maxConcurrent);
    }
    return self;
}

- (void)dealloc {
    pthread_mutex_destroy(&_mutexLock);
}

-(void)lock{
    pthread_mutex_lock(&_mutexLock);
}

-(void)unlock{
    pthread_mutex_unlock(&_mutexLock);
}

-(void)runOperation:(dispatch_block_t)operation{
    [self runOperation:operation withPriority:TokenQueuePriorityDefault];
}

- (void)runOperation:(dispatch_block_t _Nullable)operation
        withPriority:(TokenQueuePriority)priority {
    if (!operation) {
        return;
    }
    /// 任务即将被添加到serialQueue，进组
    dispatch_group_enter(self.operationsGroup);
    dispatch_async(self.serialQueue, ^{
        [self lock];
            /// 添加任务到对应级别的队列
            NSMutableArray *operationsArray = [self operationsWithPriority:priority];
            [operationsArray addObject:operation];
        [self unlock];
        /// 任务添加完就需要开始走执行流程，不要让外面调用所谓的start或者begin
        [self execute];
    });
}

-(dispatch_block_t)locked_popOperation{
    [self lock];
        dispatch_block_t operation = [self.highOperations firstObject];
        if (operation) {
            if (self.lastPriorityState != TokenQueuePriorityHigh) {
                dispatch_set_target_queue(self.concurrentQueue, dispatch_get_global_queue(TokenQueuePriorityHigh, 0));
            }
            self.lastPriorityState = TokenQueuePriorityHigh;
            [self.highOperations removeObjectAtIndex:0];
        }
        else if (operation == nil) {
            operation = [self.defaultOperations firstObject];
            if (operation) {
                if (self.lastPriorityState != TokenQueuePriorityDefault) {
                    dispatch_set_target_queue(self.concurrentQueue, dispatch_get_global_queue(TokenQueuePriorityDefault, 0));
                }
                self.lastPriorityState = TokenQueuePriorityDefault;
                [self.defaultOperations removeObjectAtIndex:0];
            }
        }
        if (operation == nil) {
            operation = [self.lowOperations firstObject];
            if (operation) {
                if (self.lastPriorityState != TokenQueuePriorityLow) {
                    dispatch_set_target_queue(self.concurrentQueue, dispatch_get_global_queue(TokenQueuePriorityLow, 0));
                }
                self.lastPriorityState = TokenQueuePriorityLow;
                [self.lowOperations removeObjectAtIndex:0];
            }
        }
        if (operation == nil) {
            operation = [self.backgroundOperations firstObject];
            if (operation) {
                if (self.lastPriorityState != TokenQueuePriorityBackground) {
                    dispatch_set_target_queue(self.concurrentQueue, dispatch_get_global_queue(TokenQueuePriorityBackground, 0));
                }
                self.lastPriorityState = TokenQueuePriorityBackground;
                [self.backgroundOperations removeObjectAtIndex:0];
            }
        }
    
    [self unlock];
    return operation;
}

/// 取出对应级别的存放任务的数组
/// @param priority 级别
-(NSMutableArray * _Nonnull)operationsWithPriority:(TokenQueuePriority)priority{
    switch (priority) {
        case TokenQueuePriorityDefault:
            return self.defaultOperations;
        case TokenQueuePriorityHigh:
            return self.highOperations;
        case TokenQueuePriorityLow:
            return self.lowOperations;
        case TokenQueuePriorityBackground:
            return self.backgroundOperations;
        default:
            return self.defaultOperations;
    }
}

/// 执行任务
- (void)execute {
    [self lock];
        NSUInteger maxConcurrent = _maxConcurrent;
    [self unlock];

    /// 开发者设置串行执行
    if (maxConcurrent == 1) {
        dispatch_block_t operation = [self locked_popOperation];
        if (operation) {
            /// 所有的添加到serialQueue的task会依次执行
            dispatch_async(self.serialQueue, ^{
                operation();
                /// 任务执行完毕，出组
                dispatch_group_leave(self.operationsGroup);
                [self execute];
            });
        }
        return;
    }

    /// 此处用serialQueue是保障task不会阻塞，并且保障其他会在serialQueue设置必备参数的任务执行完毕（不要改成sync，会出事的）
    dispatch_async(self.serialQueue, ^{
        /// 取出和执行任务需要等待信号量
        dispatch_semaphore_wait(self.maxConcurrentSemaphore, DISPATCH_TIME_FOREVER);
        dispatch_block_t operation = [self locked_popOperation];
        if (operation) {
            dispatch_async(self.concurrentQueue, ^{
                operation();
                /// 任务执行完毕需要释放信号量
                dispatch_semaphore_signal(self.maxConcurrentSemaphore);
                /// 任务执行完毕，出组
                dispatch_group_leave(self.operationsGroup);
                //检查是否嵌套加入了operation
                [self execute];
            });
        } else {
            /// 取不到任务也需要释放信号量
            dispatch_semaphore_signal(self.maxConcurrentSemaphore);
        }
    }); 
}

-(void)waitUntilFinished{
    [self execute];
    /// 等待所有任务执行完毕，该方法才可以返回
    dispatch_group_wait(self.operationsGroup, DISPATCH_TIME_FOREVER);
}

-(void)cancelAllOperations{
    [self lock];
        NSInteger operationsCount = self.highOperations.count + self.defaultOperations.count +self.lowOperations.count + self.backgroundOperations.count;
        [self.highOperations       removeAllObjects];
        [self.defaultOperations    removeAllObjects];
        [self.lowOperations        removeAllObjects];
        [self.backgroundOperations removeAllObjects];
        /// 取消所有任务，需要计算没被执行的任务，进行对应次数的出组，保证不会阻塞当前线程，导致waitUntilFinished无法返回
        while (operationsCount!=0) {
            dispatch_group_leave(self.operationsGroup);
            operationsCount -= 1;
        }
    [self unlock];
}

#pragma mark - setter
- (void)setMaxConcurrent:(NSUInteger)maxConcurrent {
    [self lock];
        __block NSInteger diff = _maxConcurrent - maxConcurrent;
        _maxConcurrent = maxConcurrent;
    [self unlock];
    if (diff == 0) {
        return;
    }
    /// 最大并发数调整，需要修改对应的并发专用信号量，并且使用serialQueue保障不会在调整信号量的时候执行其他任务
    dispatch_async(self.serialQueue, ^{
        while (diff != 0) {
            if (diff > 0) {
                /// 增大
                dispatch_semaphore_wait(self.maxConcurrentSemaphore, DISPATCH_TIME_FOREVER);
                diff -= 1;
            } else {
                /// 减少
                dispatch_semaphore_signal(self.maxConcurrentSemaphore);
                diff += 1;
            }
        }
    });
}

#pragma mark - getter

- (dispatch_queue_t)serialQueue {
    if (!_serialQueue) {
        _serialQueue = dispatch_queue_create("com.tokenQueue.serialQueue", DISPATCH_QUEUE_SERIAL);
    }
    return _serialQueue;
}

- (dispatch_queue_t)concurrentQueue {
    if (!_concurrentQueue) {
        _concurrentQueue = dispatch_queue_create("com.tokenQueue.concurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    }
    return _concurrentQueue;
}

- (dispatch_group_t)operationsGroup {
    if (!_operationsGroup) {
        _operationsGroup = dispatch_group_create();
    }
    return _operationsGroup;
}

- (NSMutableArray<dispatch_block_t> *)highOperations {
    if (!_highOperations) {
        _highOperations = [NSMutableArray array];
    }
    return _highOperations;
}

- (NSMutableArray<dispatch_block_t> *)defaultOperations {
    if (!_defaultOperations) {
        _defaultOperations = [NSMutableArray array];
    }
    return _defaultOperations;
}

- (NSMutableArray<dispatch_block_t> *)lowOperations {
    if (!_lowOperations) {
        _lowOperations = [NSMutableArray array];
    }
    return _lowOperations;
}

- (NSMutableArray<dispatch_block_t> *)backgroundOperations {
    if (!_backgroundOperations) {
        _backgroundOperations = [NSMutableArray array];
    }
    return _backgroundOperations;
}

@end
