//
//  TokenSerialQueue.m
//  TokenOperationQueue
//
//  Created by 武嘉晟 on 2020/2/5.
//  Copyright © 2020 Token. All rights reserved.
//

#import "TokenSerialQueue.h"
#import <pthread.h>

@interface TokenSerialQueue ()

/// 多线程读写保护专用锁
@property (nonatomic, assign) pthread_mutex_t mutexLock;
/// 真正执行任务的队列
@property (nonatomic, copy, nonnull) dispatch_queue_t serialQueue;
/// 所有任务执行必须进组，任务完成出组，为waitUntilFinished服务，可以阻塞当前线程
@property (nonatomic, copy, nonnull) dispatch_group_t operationsGroup;
/// 标记任务取消，一旦开发者在任务运行的过程中调用stop，后面的任务就不执行了
@property (nonatomic, assign) BOOL stoped;

@end

@implementation TokenSerialQueue

+ (instancetype)queue {
    return [[self alloc] init];
}

- (instancetype)init {
    if (self = [super init]) {
        /// 初始化多线程读写保护专用锁
        pthread_mutexattr_t attr;
        pthread_mutexattr_init(&attr);
        pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE);
        pthread_mutex_init(&_mutexLock, &attr);
        _stoped = NO;
    }
    return self;
}

- (void)dealloc {
    pthread_mutex_destroy(&_mutexLock);
}

- (void)runOperation:(dispatch_block_t _Nonnull)operation {
    NSAssert(operation, @"operation cannot be nil, please check your code");
    if (!operation) {
        return;
    }
    dispatch_group_enter(self.operationsGroup);
    dispatch_async(self.serialQueue, ^{
        if (!self.stoped) {
            operation();
        }
        dispatch_group_leave(self.operationsGroup);
    });

}
- (void)waitUntilFinished {
    /// 等待所有任务执行完毕，该方法才可以返回
    dispatch_group_wait(self.operationsGroup, DISPATCH_TIME_FOREVER);
}
- (void)stop {
    [self lock];
        self.stoped = YES;
    [self unlock];
}

#pragma mark - lock

- (void)lock {
    pthread_mutex_lock(&_mutexLock);
}

- (void)unlock {
    pthread_mutex_unlock(&_mutexLock);
}

#pragma mark - getter

- (dispatch_queue_t)serialQueue {
    if (!_serialQueue) {
        _serialQueue = dispatch_queue_create("com.tokenQueue.serialQueue", DISPATCH_QUEUE_SERIAL);
    }
    return _serialQueue;
}

- (dispatch_group_t)operationsGroup {
    if (!_operationsGroup) {
        _operationsGroup = dispatch_group_create();
    }
    return _operationsGroup;
}

@end
