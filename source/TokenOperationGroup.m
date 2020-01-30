//
//  TokenOperationGroup.m
//  TokenOperationQueue
//
//  Created by 武嘉晟 on 2020/1/26.
//  Copyright © 2020 Token. All rights reserved.
//

#import "TokenOperationGroup.h"
#import <pthread.h>

@interface TokenOperationGroup()

/// 添加任务进组，任务完成出组，为privateCompletion服务
@property (nonatomic, copy, nonnull) dispatch_group_t operationsGroup;
/// 保障内部任务的串行执行
@property (nonatomic, copy, nonnull) dispatch_queue_t processQueue;
/// 多线程读写保护专用锁
@property (nonatomic, assign) pthread_mutex_t mutexLock;
/// 串/并行任务结束后的任务，可选
@property (nonatomic, copy, nullable) dispatch_block_t privateCompletion;
/// 标记任务开始，避免开发者反复调用run
@property (nonatomic, assign) BOOL started;
/// 标记任务取消，一旦开发者在任务运行的过程中调用cancel，后面的任务就不执行了
@property (nonatomic, assign) BOOL canceled;

/// 保存各个优先级的等待执行的任务队列
@property (nonatomic, strong, nonnull) NSMutableArray <dispatch_block_t> *highOperations;
@property (nonatomic, strong, nonnull) NSMutableArray <dispatch_block_t> *defaultOperations;
@property (nonatomic, strong, nonnull) NSMutableArray <dispatch_block_t> *lowOperations;
@property (nonatomic, strong, nonnull) NSMutableArray <dispatch_block_t> *backgroundOperations;

/// 最大并发数
@property(nonatomic, assign) NSUInteger privateMaxConcurrent;

@end

@implementation TokenOperationGroup

+ (instancetype)group {
    return [[self alloc] init];
}

- (instancetype)init {
    if (self = [super init]) {
        _privateMaxConcurrent = [[NSProcessInfo processInfo] activeProcessorCount]*2;
        pthread_mutex_init(&_mutexLock, NULL);
    }
    return self;
}

- (void)dealloc {
    pthread_mutex_destroy(&_mutexLock);
}

-(void)addOperation:(dispatch_block_t)operation{
    [self addOperation:operation withPriority:(TokenQueuePriorityDefault)];
}

-(void)addOperation:(dispatch_block_t)operation withPriority:(TokenQueuePriority)priority {
    if (!operation) {
        return;
    }
    dispatch_async(self.processQueue, ^{
        [self lock];
            dispatch_group_enter(self.operationsGroup);
        switch (priority) {
            case TokenQueuePriorityHigh:
                [self.highOperations addObject:operation];
                break;
            case TokenQueuePriorityDefault:
                [self.defaultOperations addObject:operation];
                break;
            case TokenQueuePriorityLow:
                [self.lowOperations addObject:operation];
                break;
            case TokenQueuePriorityBackground:
                [self.backgroundOperations addObject:operation];
                break;
            default:
                [self.defaultOperations addObject:operation];
                break;
        }
        [self unlock];
    });
}

- (void)run {
    [self lock];
        BOOL started = self.started;
    [self unlock];
    /// 避免反复调用run
    if (started) {
        return;
    }
    dispatch_async(self.processQueue, ^{
        [self lock];
            self.started = YES;
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            queue.maxConcurrentOperationCount = self.privateMaxConcurrent;
            /// 对所有开发者添加的任务丢到NSOperationQueue
            [queue addOperations:[self operations] waitUntilFinished:NO];
            dispatch_block_t completion = self.privateCompletion;
        [self unlock];
        dispatch_queue_t completionQueue = dispatch_get_global_queue(TokenQueuePriorityDefault, 0);
        dispatch_group_notify(self.operationsGroup, completionQueue, ^{
            !completion?:completion();
        });
    });
}

/// 获取组装成功的任务队列
- (NSArray<NSOperation *> * _Nullable)operations {
    NSMutableArray<NSOperation *> *ops = [NSMutableArray array];
    for (dispatch_block_t block in self.highOperations) {
        NSBlockOperation *op = [self blockOperationWithBlock:block];
        op.queuePriority = NSOperationQueuePriorityHigh;
        [ops addObject:op];
    }
    for (dispatch_block_t block in self.defaultOperations) {
        NSBlockOperation *op = [self blockOperationWithBlock:block];
        op.queuePriority = NSOperationQueuePriorityNormal;
        [ops addObject:op];
    }
    for (dispatch_block_t block in self.lowOperations) {
        NSBlockOperation *op = [self blockOperationWithBlock:block];
        op.queuePriority = NSOperationQueuePriorityLow;
        [ops addObject:op];
    }
    for (dispatch_block_t block in self.backgroundOperations) {
        NSBlockOperation *op = [self blockOperationWithBlock:block];
        op.queuePriority = NSOperationQueuePriorityVeryLow;
        [ops addObject:op];
    }
    return ops.copy;
}

/// 获取最后需要组装的任务
/// @param block 开发者设置的任务（有可能会被取消）
- (NSBlockOperation * _Nullable)blockOperationWithBlock:(dispatch_block_t)block {
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        /// 执行开发者的任务前检查一下是否被取消了
        if (self.canceled) {
            return;
        }
        block();
        dispatch_group_leave(self.operationsGroup);
    }];
    return op;
}

-(void)cancel{
    [self lock];
        self.canceled = YES;
    [self unlock];
    //wo do not to call dispatch_group_leave(self.operationsGroup);
}

- (void)lock {
    pthread_mutex_lock(&_mutexLock);
}

- (void)unlock {
    pthread_mutex_unlock(&_mutexLock);
}

- (void)setCompletion:(dispatch_block_t)completion {
    self.privateCompletion = completion;
}

#pragma mark - setter

- (void)setMaxConcurrent:(NSUInteger)maxConcurrent {
    _privateMaxConcurrent = maxConcurrent;
}

#pragma mark - getter

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

- (dispatch_group_t)operationsGroup {
    if (!_operationsGroup) {
        _operationsGroup = dispatch_group_create();
    }
    return _operationsGroup;
}

- (dispatch_queue_t)processQueue {
    if (!_processQueue) {
        _processQueue = dispatch_queue_create("com.tokenGroup.serialQueue", DISPATCH_QUEUE_SERIAL);
    }
    return _processQueue;
}

@end
