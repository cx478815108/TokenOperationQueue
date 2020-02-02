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

/// 真正串/并行执行任务的队列，串行队列职责多一些
@property (nonatomic, copy, nonnull) dispatch_queue_t serialQueue;
@property (nonatomic, copy, nonnull) dispatch_queue_t concurrentQueue;
/// 所有任务执行必须进组，任务完成出组，为waitUntilFinished服务，可以阻塞当前线程
@property (nonatomic, copy, nonnull) dispatch_group_t operationsGroup;

/// 保存各个优先级的等待执行的任务队列
@property (nonatomic, strong, nonnull) NSMutableArray <dispatch_block_t> *highOperations;
@property (nonatomic, strong, nonnull) NSMutableArray <dispatch_block_t> *defaultOperations;
@property (nonatomic, strong, nonnull) NSMutableArray <dispatch_block_t> *lowOperations;
@property (nonatomic, strong, nonnull) NSMutableArray <dispatch_block_t> *backgroundOperations;
/// 控制最大并发数的信号量，所有的当_maxConcurrent大于1时的任务是否可以执行都需要通过该信号量控制，dealloc保证大于初始值
@property (nonatomic, copy, nonnull) dispatch_semaphore_t maxConcurrentSemaphore;
/// 队列优先级flag，用于调整任务执行优先级
@property (nonatomic, assign) TokenQueuePriority lastPriorityState;
/// 标记任务取消，一旦开发者在任务运行的过程中调用cancel，后面的任务就不执行了
@property (nonatomic, assign) BOOL canceled;

/// 标记开发者使用的sharedQueue还是queue
@property (nonatomic, assign) BOOL isSerial;

@end

@implementation TokenOperationQueue

+ (instancetype)sharedQueue {
    static TokenOperationQueue *obj;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSUInteger defaultNumber = NSProcessInfo.processInfo.activeProcessorCount*2;
        obj = [[TokenOperationQueue alloc] initWithMaxConcurrent:defaultNumber];
        obj.isSerial = NO;
    });
    return obj;
}

+ (instancetype)serialQueue {
    TokenOperationQueue *queue = [[self alloc] initWithMaxConcurrent:1];
    queue.isSerial = YES;
    return queue;
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
        _maxConcurrentSemaphore = dispatch_semaphore_create(0);
        for (NSInteger i = 0; i < _maxConcurrent; i++) {
            dispatch_semaphore_signal(_maxConcurrentSemaphore);
        }
    }
    return self;
}

- (void)dealloc {
    pthread_mutex_destroy(&_mutexLock);
}

-(void)runOperation:(dispatch_block_t _Nonnull)operation{
    [self runOperation:operation withPriority:TokenQueuePriorityDefault];
}

- (void)runOperation:(dispatch_block_t _Nonnull)operation
        withPriority:(TokenQueuePriority)priority {
    NSAssert(operation, @"operation cannot be nil, please check your code");
    if (!operation) {
        return;
    }
    NSAssert(!(self.isSerial && priority != TokenQueuePriorityDefault), @"serialQueue cannot use this API");
    if (self.isSerial && priority != TokenQueuePriorityDefault) {
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
        /// 任务添加完就需要取出一个任务开始执行，但是不一定就是执行刚刚添加的任务
        [self execute];
    });
}

/// 取出对应级别的存放任务的数组
/// @param priority 级别
- (NSMutableArray * _Nonnull)operationsWithPriority:(TokenQueuePriority)priority {
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

/// 尝试取出队列中的一个任务并且执行
- (void)execute {
    [self lock];
        NSUInteger maxConcurrent = self.maxConcurrent;
    [self unlock];

    /// 开发者设置串行执行
    if (maxConcurrent == 1) {
        dispatch_block_t operation = [self locked_popOperation];
        if (operation) {
            /// 所有的添加到serialQueue的task会依次执行
            dispatch_async(self.serialQueue, ^{
                if (!self.canceled) {
                    operation();
                }
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
                if (!self.canceled) {
                    operation();
                }
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

/// 按照优先级取出应该执行的任务，并且调整队列优先级
- (dispatch_block_t _Nullable)locked_popOperation {
    [self lock];
        dispatch_block_t operation = [self.highOperations firstObject];
        if (operation) {
            /// 取到高优先级任务，设置队列优先级为高，pop任务
            if (self.lastPriorityState != TokenQueuePriorityHigh) {
                dispatch_set_target_queue(self.concurrentQueue, dispatch_get_global_queue(TokenQueuePriorityHigh, 0));
            }
            self.lastPriorityState = TokenQueuePriorityHigh;
            [self.highOperations removeObjectAtIndex:0];
        } else {
            /// 没取到对应的，尝试取默认优先级
            operation = [self.defaultOperations firstObject];
            if (operation) {
                if (self.lastPriorityState != TokenQueuePriorityDefault) {
                    dispatch_set_target_queue(self.concurrentQueue, dispatch_get_global_queue(TokenQueuePriorityDefault, 0));
                }
                self.lastPriorityState = TokenQueuePriorityDefault;
                [self.defaultOperations removeObjectAtIndex:0];
            }
        }
        if (!operation) {
            /// 高优和默认优先都取不到
            operation = [self.lowOperations firstObject];
            if (operation) {
                /// 取到低优
                if (self.lastPriorityState != TokenQueuePriorityLow) {
                    dispatch_set_target_queue(self.concurrentQueue, dispatch_get_global_queue(TokenQueuePriorityLow, 0));
                }
                self.lastPriorityState = TokenQueuePriorityLow;
                [self.lowOperations removeObjectAtIndex:0];
            }
        }
        if (!operation) {
            /// 默认优先级也没取到
            operation = [self.backgroundOperations firstObject];
            if (operation) {
                /// 取到后台优先级
                if (self.lastPriorityState != TokenQueuePriorityBackground) {
                    dispatch_set_target_queue(self.concurrentQueue, dispatch_get_global_queue(TokenQueuePriorityBackground, 0));
                }
                self.lastPriorityState = TokenQueuePriorityBackground;
                [self.backgroundOperations removeObjectAtIndex:0];
            }
        }
    
    [self unlock];
    /// 可能一个都取不到
    return operation;
}

-(void)waitUntilFinished{
    [self execute];
    /// 等待所有任务执行完毕，该方法才可以返回
    dispatch_group_wait(self.operationsGroup, DISPATCH_TIME_FOREVER);
}

-(void)cancelAllOperations{
    [self lock];
        self.canceled = YES;
    [self unlock];
}

#pragma mark - lock

- (void)lock {
    pthread_mutex_lock(&_mutexLock);
}

- (void)unlock {
    pthread_mutex_unlock(&_mutexLock);
}

#pragma mark - setter

- (void)setMaxConcurrent:(NSUInteger)maxConcurrent {
    NSAssert(!self.isSerial, @"serial cannot use this API");
    if (self.isSerial) {
        return;
    }
    NSAssert(maxConcurrent >= 2, @"maxConcurrent must >= 2");
    if (maxConcurrent < 2) {
        return;
    }
    [self lock];
        __block NSInteger diff = self.maxConcurrent - maxConcurrent;
        /// 下面这一行不要写self.maxConcurrent = maxConcurrent; 会出事的
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
        _highOperations = NSMutableArray.array;
    }
    return _highOperations;
}

- (NSMutableArray<dispatch_block_t> *)defaultOperations {
    if (!_defaultOperations) {
        _defaultOperations = NSMutableArray.array;
    }
    return _defaultOperations;
}

- (NSMutableArray<dispatch_block_t> *)lowOperations {
    if (!_lowOperations) {
        _lowOperations = NSMutableArray.array;
    }
    return _lowOperations;
}

- (NSMutableArray<dispatch_block_t> *)backgroundOperations {
    if (!_backgroundOperations) {
        _backgroundOperations = NSMutableArray.array;
    }
    return _backgroundOperations;
}

@end
