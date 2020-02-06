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

/// 多线程读写保护专用锁
@property (nonatomic, assign) pthread_mutex_t mutexLock;
/// 添加任务进组，任务完成出组，为privateCompletion服务
@property (nonatomic, copy, nonnull) dispatch_group_t operationsGroup;
/// 保障内部任务的串行执行
@property (nonatomic, copy, nonnull) dispatch_queue_t processQueue;
/// 串/并行任务结束后的任务，可选
@property (nonatomic, copy, nullable) dispatch_block_t privateCompletion;
/// 标记任务开始，避免开发者反复调用run
@property (nonatomic, assign) BOOL started;
/// 标记任务取消，一旦开发者在任务运行的过程中调用cancel，后面的任务就不执行了
@property (nonatomic, assign) BOOL canceled;
/// 保存各个优先级的等待执行的任务队列
@property (nonatomic, strong, nonnull) NSMutableArray <dispatch_block_t> *veryHighOperations;
@property (nonatomic, strong, nonnull) NSMutableArray <dispatch_block_t> *highOperations;
@property (nonatomic, strong, nonnull) NSMutableArray <dispatch_block_t> *normalOperations;
@property (nonatomic, strong, nonnull) NSMutableArray <dispatch_block_t> *lowOperations;
@property (nonatomic, strong, nonnull) NSMutableArray <dispatch_block_t> *veryLowOperations;
/// 最大并发数
@property(nonatomic, assign) NSUInteger privateMaxConcurrent;

@end

@implementation TokenOperationGroup

+ (instancetype)group {
    return [[self alloc] init];
}

- (instancetype)init {
    if (self = [super init]) {
        _privateMaxConcurrent = NSProcessInfo.processInfo.activeProcessorCount*2;
        pthread_mutex_init(&_mutexLock, NULL);
    }
    return self;
}

- (void)dealloc {
    pthread_mutex_destroy(&_mutexLock);
}

- (void)addOperation:(dispatch_block_t _Nonnull)operation {
    [self addOperation:operation withPriority:(NSOperationQueuePriorityNormal)];
}

- (void)addOperation:(dispatch_block_t _Nonnull)operation
        withPriority:(NSOperationQueuePriority)priority {
    NSAssert(operation, @"operation cannot be nil, please check your code");
    if (!operation) {
        return;
    }
    dispatch_async(self.processQueue, ^{
        [self lock];
            dispatch_group_enter(self.operationsGroup);
            /// 向正确的队列添加任务
            [[self operationsWithPriority:priority] addObject:operation];
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
            /// 所有开发者添加的任务包装一下（支持被取消），丢到NSOperationQueue中
            [queue addOperations:[self operations] waitUntilFinished:NO];
            dispatch_block_t completion = self.privateCompletion;
        [self unlock];
        dispatch_queue_t completionQueue = dispatch_get_global_queue(NSOperationQueuePriorityNormal, 0);
        dispatch_group_notify(self.operationsGroup, completionQueue, ^{
            !completion?:completion();
        });
    });
}

- (void)cancel {
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

- (void)setCompletion:(dispatch_block_t _Nonnull)completion {
    NSAssert(completion, @"completion you set cannot be nil, please check your code");
    self.privateCompletion = completion;
}

#pragma mark - tools

/// 获取对应优先级的任务队列
/// @param priority 优先级
- (NSMutableArray <dispatch_block_t> * _Nonnull)operationsWithPriority:(NSOperationQueuePriority)priority {
    switch (priority) {
        case NSOperationQueuePriorityVeryLow:
            return self.veryLowOperations;
            break;
        case NSOperationQueuePriorityLow:
            return self.lowOperations;
            break;
        case NSOperationQueuePriorityNormal:
            return self.normalOperations;
            break;
        case NSOperationQueuePriorityHigh:
            return self.highOperations;
            break;
        case NSOperationQueuePriorityVeryHigh:
            return self.veryHighOperations;
            break;
        default:
            return self.normalOperations;
            break;
    }
}

/// 获取组装成功的任务队列
- (NSArray <NSOperation *> * _Nonnull)operations {
    NSMutableArray <NSOperation *> *ops = NSMutableArray.array;
    [ops addObjectsFromArray:[self blockOperationsWithPriority:NSOperationQueuePriorityVeryHigh]];
    [ops addObjectsFromArray:[self blockOperationsWithPriority:NSOperationQueuePriorityHigh]];
    [ops addObjectsFromArray:[self blockOperationsWithPriority:NSOperationQueuePriorityNormal]];
    [ops addObjectsFromArray:[self blockOperationsWithPriority:NSOperationQueuePriorityLow]];
    [ops addObjectsFromArray:[self blockOperationsWithPriority:NSOperationQueuePriorityVeryLow]];
    return ops.copy;
}

/// 组装开发者的任务为可被取消的NSOperation数组
/// @param priority 优先级
- (NSArray <NSOperation *> * _Nonnull)blockOperationsWithPriority:(NSOperationQueuePriority)priority {
    NSMutableArray <NSOperation *> *ops = [NSMutableArray array];
    for (dispatch_block_t block in [self operationsWithPriority:priority]) {
        /// 包装开发者执行的任务，使其可以被取消
        NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
            /// 执行开发者的任务前检查一下是否被取消了
            if (self.canceled) {
                return;
            }
            block();
            dispatch_group_leave(self.operationsGroup);
        }];
        op.queuePriority = priority;
        [ops addObject:op];
    }
    return ops.copy;
}

#pragma mark - setter

- (void)setMaxConcurrent:(NSUInteger)maxConcurrent {
    _privateMaxConcurrent = maxConcurrent;
}

#pragma mark - getter

- (NSMutableArray <dispatch_block_t> *)veryHighOperations {
    if (!_veryHighOperations) {
        _veryHighOperations = NSMutableArray.array;
    }
    return _veryHighOperations;
}

- (NSMutableArray <dispatch_block_t> *)highOperations {
    if (!_highOperations) {
        _highOperations = NSMutableArray.array;
    }
    return _highOperations;
}

- (NSMutableArray <dispatch_block_t> *)normalOperations {
    if (!_normalOperations) {
        _normalOperations = NSMutableArray.array;
    }
    return _normalOperations;
}

- (NSMutableArray <dispatch_block_t> *)lowOperations {
    if (!_lowOperations) {
        _lowOperations = NSMutableArray.array;
    }
    return _lowOperations;
}

- (NSMutableArray <dispatch_block_t> *)veryLowOperations {
    if (!_veryLowOperations) {
        _veryLowOperations = NSMutableArray.array;
    }
    return _veryLowOperations;
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
