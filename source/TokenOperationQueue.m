//
//  TokenQueue.m
//  TokenOperation
//
//  Created by 陈雄 on 2018/5/3.
//  Copyright © 2018年 com.feelings. All rights reserved.
//

#import "TokenOperationQueue.h"
#import <pthread.h>
#import <stdatomic.h>

@interface TokenOperationQueue()
@end

@implementation TokenOperationQueue {
    pthread_mutex_t      _lock;
    NSUInteger           _maxConcurrent;
    dispatch_queue_t     _serialQueue;
    dispatch_queue_t     _concurrentQueue;
    dispatch_group_t     _operationsGroup;
    dispatch_semaphore_t _maxConcurrentSemaphore;
    
    NSMutableArray <dispatch_block_t> *_highOperations;
    NSMutableArray <dispatch_block_t> *_defaultOperations;
    NSMutableArray <dispatch_block_t> *_lowOperations;
    NSMutableArray <dispatch_block_t> *_backgroundOperations;
    
    TokenQueuePriority _lastPriorityState;
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
        pthread_mutexattr_t attr;
        pthread_mutexattr_init(&attr);
        pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE);
        pthread_mutex_init(&_lock, &attr);
        _maxConcurrent          = maxConcurrent;
        _serialQueue            = dispatch_queue_create("com.tokenQueue.serialQueue", DISPATCH_QUEUE_SERIAL);
        _concurrentQueue        = dispatch_queue_create("com.tokenQueue.concurrentQueue", DISPATCH_QUEUE_CONCURRENT);
        _maxConcurrentSemaphore = dispatch_semaphore_create(maxConcurrent);
        _operationsGroup        = dispatch_group_create();
    }
    return self;
}

-(void)lock{
    pthread_mutex_lock(&_lock);
}

-(void)unlock{
    pthread_mutex_unlock(&_lock);
}

-(void)runOperation:(dispatch_block_t)operation{
    [self runOperation:operation withPriority:TokenQueuePriorityDefault];
}

-(void)runOperation:(dispatch_block_t)operation withPriority:(TokenQueuePriority)priority{
    if (operation == nil) return ;
    dispatch_group_enter(self->_operationsGroup);
    dispatch_async(_serialQueue, ^{
        [self lock];
            NSMutableArray *operationsArray = [self operationsWithPriority:priority];
            [operationsArray addObject:operation];
        [self unlock];
        [self execute];
    });
}

-(dispatch_block_t)locked_popOperation{
    [self lock];
        dispatch_block_t operation = [_highOperations firstObject];
        if (operation) {
            if (_lastPriorityState != TokenQueuePriorityHigh) {
                dispatch_set_target_queue(_concurrentQueue, dispatch_get_global_queue(TokenQueuePriorityHigh, 0));
            }
            _lastPriorityState = TokenQueuePriorityHigh;
            [_highOperations removeObjectAtIndex:0];
        }
        else if (operation == nil) {
            operation = [_defaultOperations firstObject];
            if (operation) {
                if (_lastPriorityState != TokenQueuePriorityDefault) {
                    dispatch_set_target_queue(_concurrentQueue, dispatch_get_global_queue(TokenQueuePriorityDefault, 0));
                }
                _lastPriorityState = TokenQueuePriorityDefault;
                [_defaultOperations removeObjectAtIndex:0];
            }
        }
        if (operation == nil) {
            operation = [_lowOperations firstObject];
            if (operation) {
                if (_lastPriorityState != TokenQueuePriorityLow) {
                    dispatch_set_target_queue(_concurrentQueue, dispatch_get_global_queue(TokenQueuePriorityLow, 0));
                }
                _lastPriorityState = TokenQueuePriorityLow;
                [_lowOperations removeObjectAtIndex:0];
            }
        }
        if (operation == nil) {
            operation = [_backgroundOperations firstObject];
            if (operation) {
                if (_lastPriorityState != TokenQueuePriorityBackground) {
                    dispatch_set_target_queue(_concurrentQueue, dispatch_get_global_queue(TokenQueuePriorityBackground, 0));
                }
                _lastPriorityState = TokenQueuePriorityBackground;
                [_backgroundOperations removeObjectAtIndex:0];
            }
        }
    
    [self unlock];
    return operation;
}

-(NSMutableArray *)operationsWithPriority:(TokenQueuePriority)priority{
    switch (priority) {
        case TokenQueuePriorityDefault:
            if (_defaultOperations == nil) {
                _defaultOperations = @[].mutableCopy;
            }
            return _defaultOperations;
        case TokenQueuePriorityHigh:
            if (_highOperations == nil) {
                _highOperations = @[].mutableCopy;
            }
            return _highOperations;
        case TokenQueuePriorityLow:
            if (_lowOperations == nil) {
                _lowOperations = @[].mutableCopy;
            }
            return _lowOperations;
        case TokenQueuePriorityBackground:
            if (_backgroundOperations == nil) {
                _backgroundOperations = @[].mutableCopy;
            }
            return _backgroundOperations;
        default:
            if (_defaultOperations == nil) {
                _defaultOperations = @[].mutableCopy;
            }
            return _defaultOperations;
    }
}

-(void)execute{
    [self lock];
        NSUInteger maxConcurrent = _maxConcurrent;
    [self unlock];
    
    if (maxConcurrent == 1) {
        dispatch_block_t operation = [self locked_popOperation];
        if (operation) {
            dispatch_async(_serialQueue, ^{
                operation();
                dispatch_group_leave(self->_operationsGroup);
                [self execute];
            });
        }
        return ;
    }
    
    dispatch_async(_serialQueue, ^{
        dispatch_semaphore_wait(self->_maxConcurrentSemaphore, DISPATCH_TIME_FOREVER);
        dispatch_block_t operation = [self locked_popOperation];
        if (operation) {
            dispatch_async(self->_concurrentQueue, ^{
                operation();
                dispatch_semaphore_signal(self->_maxConcurrentSemaphore);
                dispatch_group_leave(self->_operationsGroup);
                //检查是否嵌套加入了operation
                [self execute];
            });
        }
        else {
            dispatch_semaphore_signal(self->_maxConcurrentSemaphore);
        }
    }); 
}

-(void)waitUntilDone{
    [self execute];
    dispatch_group_wait(_operationsGroup, DISPATCH_TIME_FOREVER);
}

-(void)cancelAllOperations{
    [self lock];
        NSInteger operationsCount = _highOperations.count + _defaultOperations.count +_lowOperations.count + _backgroundOperations.count;
        [_highOperations       removeAllObjects];
        [_defaultOperations    removeAllObjects];
        [_lowOperations        removeAllObjects];
        [_backgroundOperations removeAllObjects];
        while (operationsCount!=0) {
            dispatch_group_leave(_operationsGroup);
            operationsCount -= 1;
        }
    [self unlock];
}

+(BOOL)isMainThread{
    BOOL isMainThread = (0 != pthread_main_np());
    return isMainThread;
}

#pragma setter
-(void)setMaxConcurrent:(NSUInteger)maxConcurrent{
    [self lock];
        __block NSInteger diff = _maxConcurrent - maxConcurrent;
        _maxConcurrent = maxConcurrent;
    [self unlock];
    if (diff == 0) return ;
    dispatch_async(_serialQueue, ^{
        while (diff != 0) {
            if (diff > 0) {
                dispatch_semaphore_wait(self->_maxConcurrentSemaphore, DISPATCH_TIME_FOREVER);
                diff -= 1;
            }
            else {
                dispatch_semaphore_signal(self->_maxConcurrentSemaphore);
                diff += 1;
            }
        }
    });
}

-(void)dealloc{
    pthread_mutex_destroy(&_lock);
}

@end


#pragma mark - TokenOperationQueue Chain

@implementation TokenOperationQueue (Chain)
-(TokenOperationChain1Block)chain_runOperation{
    return ^TokenOperationQueue *(dispatch_block_t operation) {
        [self runOperation:operation];
        return self;
    };
}

-(TokenOperationChain2Block)chain_runOperationWithPriority{
    return ^TokenOperationQueue *(TokenQueuePriority priority,dispatch_block_t operation) {
        [self runOperation:operation withPriority:priority];
        return self;
    };
}

-(TokenOperationChain0Block)chain_waitUntilDone{
    return ^TokenOperationQueue *(void) {
        [self waitUntilDone];
        return self;
    };
}

-(TokenOperationChain0Block)chain_cancelAllOperations{
    return ^TokenOperationQueue *(void) {
        [self cancelAllOperations];
        return self;
    };
}

-(TokenOperationIntegerBlock)chain_setMaxConcurrent{
    return ^TokenOperationQueue *(NSUInteger maxConcurrent) {
        [self setMaxConcurrent:maxConcurrent];
        return self;
    };
}
@end


#pragma mark - TokenRenderQueue
@interface TokenRenderQueue:NSObject
@end

@implementation TokenRenderQueue{
    NSMutableArray       *_tasks;
    pthread_mutex_t      _lock;
    CFRunLoopObserverRef _runLoopObserver;
}

+(instancetype)sharedRenderQueue{
    static TokenRenderQueue *queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = [[TokenRenderQueue alloc] init];
    });
    return queue;
}

- (instancetype)init
{
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

-(void)processTask{
    [self lock];
        dispatch_block_t task = [_tasks firstObject];
        if (task) {
            task();
            [_tasks removeObjectAtIndex:0];
        }
    [self unlock];
}

-(void)addTask:(dispatch_block_t)task {
    if (task == nil) return ;
    [self lock];
        [_tasks addObject:task];
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

- (void)dealloc
{
    pthread_mutex_destroy(&_lock);
    CFRelease(_runLoopObserver);
    _runLoopObserver = nil;
}

@end

#pragma mark - TokenOperationGroup
@implementation TokenOperationGroup{
    NSMutableDictionary <NSNumber *,NSMutableArray <dispatch_block_t>*> *_operationsStore;
    dispatch_group_t _group;
    pthread_mutex_t  _lock;
    dispatch_block_t _completion;
    dispatch_queue_t _processQueue;
    BOOL             _started;
    BOOL             _canceld;
}

+(instancetype)group{
    return [[self alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        pthread_mutex_init(&_lock, NULL);
        _group = dispatch_group_create();
        _operationsStore = @{}.mutableCopy;
        _processQueue = dispatch_queue_create("com.tokenGroup.serialQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

-(void)addOperation:(dispatch_block_t)operation{
    [self addOperation:operation withPriority:(TokenQueuePriorityDefault)];
}

-(void)addOperation:(dispatch_block_t)operation withPriority:(TokenQueuePriority)priority {
    if (operation == nil) return ;
    dispatch_async(_processQueue, ^{
        [self _lock];
            dispatch_group_enter(self->_group);
            NSMutableArray *priorityOperationsArray = self->_operationsStore[@(priority)];
            if (priorityOperationsArray == nil) {
                priorityOperationsArray = @[].mutableCopy;
                [self->_operationsStore setObject:priorityOperationsArray forKey:@(priority)];
            }
            [priorityOperationsArray addObject:operation];
        [self _unlock];
    });
}

-(void)run {
    [self _lock];
        BOOL started = _started;
    [self _unlock];
    if (started) return ;
    dispatch_async(_processQueue, ^{
        [self _lock];
            self->_started = YES;
            [self runOperationsWithPriority:(TokenQueuePriorityHigh)];
            [self runOperationsWithPriority:(TokenQueuePriorityDefault)];
            [self runOperationsWithPriority:(TokenQueuePriorityLow)];
            [self runOperationsWithPriority:(TokenQueuePriorityBackground)];
            dispatch_block_t completion = self->_completion;
        [self _unlock];
        dispatch_queue_t completionQueue = dispatch_get_global_queue(TokenQueuePriorityDefault, 0);
        dispatch_group_notify(self->_group, completionQueue, ^{
            !completion?:completion();
        });
    });
}

-(void)runOperationsWithPriority:(TokenQueuePriority)priority{
    if (_canceld) return ;
    NSMutableArray <dispatch_block_t> *operations = _operationsStore[@(priority)];
    if (operations == nil) return ;
    
    for (NSInteger i = 0;i<operations.count;i++) {
        
        dispatch_block_t newOperation = ^{
            if (self->_canceld) return ;
            operations[i]();
            dispatch_group_leave(self->_group);
        };
        TokenOperationQueue.sharedQueue.chain_runOperation(^{
            newOperation();
        });
    }
}

-(void)cancel{
    [self _lock];
        _canceld = YES;
    [self _unlock];
    //wo do not to call dispatch_group_leave(self->_group);
}

-(void)setCompletion:(dispatch_block_t)completion{
    _completion = completion;
}

- (void)_lock
{
    pthread_mutex_lock(&_lock);
}

- (void)_unlock
{
    pthread_mutex_unlock(&_lock);
}

- (void)dealloc
{
    pthread_mutex_destroy(&_lock);
}

@end

#pragma mark - TokenOperationGroup Chain
@implementation TokenOperationGroup(Chain)
-(TokenOperationGroupChain1Block)chain_addOperation{
    return ^TokenOperationGroup *(dispatch_block_t operation){
        [self addOperation:operation];
        return self;
    };
}

-(TokenOperationGroupChain2Block)chain_addOperationWithPriority{
    return ^TokenOperationGroup *(TokenQueuePriority priority,dispatch_block_t operation){
        [self addOperation:operation withPriority:priority];
        return self;
    };
}

-(TokenOperationGroupChain1Block)chain_setCompletion{
    return ^TokenOperationGroup *(dispatch_block_t completion){
        [self setCompletion:completion];
        return self;
    };
}

-(TokenOperationGroupChain0Block)chain_run{
    return ^TokenOperationGroup *(void){
        [self run];
        return self;
    };
}

-(dispatch_block_t)chain_cancel{
    return ^(void){
        [self cancel];
    };
}

@end

#pragma mark - Tools
void TokenOperationRunOnMainThread(dispatch_block_t operation){
    if (operation == nil) return ;
    if (![TokenOperationQueue isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            operation();
        });
    }
    else {
        operation();
    }
}

void TokenTranscationCommit(dispatch_block_t operation){
    [[TokenRenderQueue sharedRenderQueue] addTask:operation];
}

void TokenDispatchApply(size_t count,
                        dispatch_queue_t queue,
                        NSUInteger threadCount,
                        void(^work)(size_t i)) {
    if (threadCount == 0) { threadCount = 2;}
    dispatch_group_t group = dispatch_group_create();
    __block atomic_size_t counter = ATOMIC_VAR_INIT(0);
    for (NSUInteger t = 0; t < threadCount; t++) {
        dispatch_group_async(group, queue, ^{
            size_t i;
            while ((i = atomic_fetch_add(&counter, 1)) < count) {
                work(i);
            }
        });
    }
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
};
