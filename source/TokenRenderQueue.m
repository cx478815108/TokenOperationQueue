//
//  TokenRenderQueue.m
//  TokenOperationQueue
//
//  Created by 武嘉晟 on 2020/1/25.
//  Copyright © 2020 Token. All rights reserved.
//

#import "TokenRenderQueue.h"
#import <pthread.h>
#import <stdatomic.h>

@interface TokenRenderQueue ()

/// 多线程读写保护专用锁
@property (nonatomic, assign) pthread_mutex_t mutexLock;
/// 提交的任务数组
@property (nonatomic, strong, nonnull) NSMutableArray <dispatch_block_t> *tasks;
/// 专门用于主线程runloop kCFRunLoopBeforeWaiting 的监听
@property (nonatomic, assign) CFRunLoopObserverRef runLoopObserver;

@end

@implementation TokenRenderQueue

+ (instancetype _Nonnull)sharedRenderQueue {
    static TokenRenderQueue *queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = [[TokenRenderQueue alloc] init];
    });
    return queue;
}

- (instancetype _Nonnull)init {
    if (self = [super init]) {
        pthread_mutex_init(&_mutexLock, NULL);
        __unsafe_unretained TokenRenderQueue *weakSelf = self;
        _runLoopObserver = CFRunLoopObserverCreateWithHandler(NULL,
                                                              kCFRunLoopBeforeWaiting, // before the run loop starts sleeping
                                                              YES,
                                                              INT_MAX, //order after CA transaction commits
                                                              ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
            [weakSelf processTask];
        });
        CFRunLoopAddObserver(CFRunLoopGetMain(), _runLoopObserver,  kCFRunLoopCommonModes);
    }
    return self;
}

- (void)dealloc {
    pthread_mutex_destroy(&_mutexLock);
    CFRelease(_runLoopObserver);
    _runLoopObserver = nil;
}

- (void)addTask:(dispatch_block_t _Nonnull)task {
    NSAssert(task, @"task cannot be nil");
    if (!task) {
        return;
    }
    [self lock];
        [self.tasks addObject:task];
    [self unlock];
}

- (void)processTask {
    [self lock];
        dispatch_block_t task = [self.tasks firstObject];
        if (task) {
            task();
            [self.tasks removeObjectAtIndex:0];
        }
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

- (NSMutableArray <dispatch_block_t> *)tasks {
    if (!_tasks) {
        _tasks = NSMutableArray.array;
    }
    return _tasks;
}

@end
