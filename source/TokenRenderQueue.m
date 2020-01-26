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

@implementation TokenRenderQueue {
    NSMutableArray       *_tasks;
    pthread_mutex_t      _lock;
    CFRunLoopObserverRef _runLoopObserver;
}

+ (instancetype)sharedRenderQueue {
    static TokenRenderQueue *queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = [[TokenRenderQueue alloc] init];
    });
    return queue;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        pthread_mutex_init(&_lock, NULL);
        CFRunLoopRef mainRunloop = CFRunLoopGetMain();
        _tasks = @[].mutableCopy;

        __unsafe_unretained TokenRenderQueue *weakSelf = self;
        _runLoopObserver = CFRunLoopObserverCreateWithHandler(NULL,
                                                              kCFRunLoopBeforeWaiting, // before the run loop starts sleeping
                                                              YES,
                                                              INT_MAX, //order after CA transaction commits
                                                              ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
            [weakSelf processTask];
        });
        CFRunLoopAddObserver(mainRunloop, _runLoopObserver,  kCFRunLoopCommonModes);
    }
    return self;
}

- (void)dealloc
{
    pthread_mutex_destroy(&_lock);
    CFRelease(_runLoopObserver);
    _runLoopObserver = nil;
}

-(void)addTask:(dispatch_block_t)task {
    if (task == nil) return ;
    [self lock];
    [_tasks addObject:task];
    [self unlock];
}

-(void)processTask{
    [self lock];
    dispatch_block_t task = [_tasks firstObject];
    if (task) {
        task();
        [_tasks removeObjectAtIndex:0];
    }
    [self unlock];
}

- (void)lock
{
    pthread_mutex_lock(&_lock);
}

- (void)unlock
{
    pthread_mutex_unlock(&_lock);
}

@end
