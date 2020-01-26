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

@property (nonatomic, strong, nonnull) NSMutableDictionary <NSNumber *, NSMutableArray <dispatch_block_t> *> *operationsStore;

@end

@implementation TokenOperationGroup{
    dispatch_group_t _group;
    pthread_mutex_t  _lock;
    dispatch_block_t _completion;
    dispatch_queue_t _processQueue;
    BOOL             _started;
    BOOL             _canceld;
}

+ (instancetype)group {
    return [[self alloc] init];
}

- (instancetype)init {
    if (self = [super init]) {
        pthread_mutex_init(&_lock, NULL);
        _group = dispatch_group_create();
        _operationsStore = [NSMutableDictionary dictionary];
        _processQueue = dispatch_queue_create("com.tokenGroup.serialQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)dealloc {
    pthread_mutex_destroy(&_lock);
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

@end
