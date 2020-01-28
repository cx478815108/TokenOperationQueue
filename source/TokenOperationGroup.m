//
//  TokenOperationGroup.m
//  TokenOperationQueue
//
//  Created by 武嘉晟 on 2020/1/26.
//  Copyright © 2020 Token. All rights reserved.
//

#import "TokenOperationGroup.h"
#import "TokenOperationQueue+Chain.h"
#import <pthread.h>

@interface TokenOperationGroup()

/// key:优先级 value:任务数组（其实我想搞四个数组，OC的字典类型弱）
@property (nonatomic, strong, nonnull) NSMutableDictionary <NSNumber *, NSMutableArray <dispatch_block_t> *> *operationsStore;
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

@end

@implementation TokenOperationGroup

+ (instancetype)group {
    return [[self alloc] init];
}

- (instancetype)init {
    if (self = [super init]) {
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
            NSMutableArray *priorityOperationsArray = self.operationsStore[@(priority)];
            if (!priorityOperationsArray) {
                priorityOperationsArray = NSMutableArray.array;
                self.operationsStore[@(priority)] = priorityOperationsArray;
            }
            [priorityOperationsArray addObject:operation];
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
            /// 按照优先级添加任务到TokenOperationQueue
            [self runOperationsWithPriority:(TokenQueuePriorityHigh)];
            [self runOperationsWithPriority:(TokenQueuePriorityDefault)];
            [self runOperationsWithPriority:(TokenQueuePriorityLow)];
            [self runOperationsWithPriority:(TokenQueuePriorityBackground)];
            dispatch_block_t completion = self.privateCompletion;
        [self unlock];
        dispatch_queue_t completionQueue = dispatch_get_global_queue(TokenQueuePriorityDefault, 0);
        dispatch_group_notify(self.operationsGroup, completionQueue, ^{
            !completion?:completion();
        });
    });
}

- (void)runOperationsWithPriority:(TokenQueuePriority)priority {
    if (self.canceled) {
        return;
    }
    NSMutableArray <dispatch_block_t> *operations = self.operationsStore[@(priority)];
    if (!operations) {
        return;
    }
    /// 取出该优先级所有任务添加到TokenOperationQueue单例
    for (NSInteger i = 0; i < operations.count; i++) {
        dispatch_block_t newOperation = ^{
            if (self.canceled) {
                return;
            }
            operations[i]();
            dispatch_group_leave(self.operationsGroup);
        };
        TokenOperationQueue.sharedQueue.chain_runOperation(^{
            newOperation();
        });
    }
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

#pragma mark - getter

- (NSMutableDictionary<NSNumber *,NSMutableArray<dispatch_block_t> *> *)operationsStore {
    if (!_operationsStore) {
        _operationsStore = NSMutableDictionary.dictionary;
    }
    return _operationsStore;
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
