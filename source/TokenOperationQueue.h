//
//  TokenQueue.h
//  TokenOperation
//
//  Created by 陈雄 on 2018/5/3.
//  Copyright © 2018年 com.feelings. All rights reserved.
//

#import <Foundation/Foundation.h>

void TokenOperationRunOnMainThread(dispatch_block_t operation);
void TokenTranscationCommit(dispatch_block_t operation);
void TokenDispatchApply(size_t count,
                        dispatch_queue_t queue,
                        NSUInteger threadCount,
                        void(^work)(size_t i));


typedef NS_ENUM(long, TokenQueuePriority) {
    TokenQueuePriorityHigh       = 2,         // equal to DISPATCH_QUEUE_PRIORITY_HIGH
    TokenQueuePriorityDefault    = 0,         // equal to DISPATCH_QUEUE_PRIORITY_DEFAULT
    TokenQueuePriorityLow        = -2,        // equal to DISPATCH_QUEUE_PRIORITY_LOW
    TokenQueuePriorityBackground = INT16_MIN, // equal to DISPATCH_QUEUE_PRIORITY_BACKGROUND
};

/**
TokenOperationQueue provides an easy way to use threads with priority and to solve the problem with too many threads

example:
    TokenOperationQueue.sharedQueue.chain_setMaxConcurrent(3); // max number of threads is 3;
    TokenOperationQueue.sharedQueue
    .runOperation(^{
        NSLog(@"task1");
    })
    .runOperation(^{
        NSLog(@"task2");
    })
    .runOperationwithPriority(TokenQueuePriorityHigh,^{
        NSLog(@"task3");
    });
 
    [TokenOperationQueue.sharedQueue waitUntilDone]; //this will block the current thread until the previous tasks are all finished;
 
 or you can use like this:
     [TokenOperationQueue.sharedQueue .runOperation(^{
         NSLog(@"task1");
     }];
 
     [TokenOperationQueue.sharedQueue .runOperation(^{
        NSLog(@"task2");
     }];
 
     [TokenOperationQueue.sharedQueue .runOperation(^{
        NSLog(@"task3");
     }];
 
 */
@interface TokenOperationQueue : NSObject

+(instancetype)sharedQueue;

-(instancetype)init NS_UNAVAILABLE;
-(instancetype)initWithMaxConcurrent:(NSUInteger)maxConcurrent;

@property(nonatomic ,assign) NSUInteger maxConcurrent;

+(BOOL)isMainThread;

-(void)runOperation:(dispatch_block_t)operation;

-(void)runOperation:(dispatch_block_t)operation
       withPriority:(TokenQueuePriority)priority;

/**
 do not call like this
     runOperation(^{
            ...
         [TokenOperationQueue.sharedQueue waitUntilDone];
     });
 or it will cause a deadlock
 */
-(void)waitUntilDone;

-(void)cancelAllOperations;
@end

typedef TokenOperationQueue * (^TokenOperationChain0Block) (void);
typedef TokenOperationQueue * (^TokenOperationChain1Block) (dispatch_block_t operation);
typedef TokenOperationQueue * (^TokenOperationChain2Block) (TokenQueuePriority priority,dispatch_block_t operation);
typedef TokenOperationQueue * (^TokenOperationIntegerBlock)(NSUInteger maxConcurrent);

@interface TokenOperationQueue(Chain)
@property(nonatomic ,copy ,readonly) TokenOperationChain1Block  chain_runOperation;
@property(nonatomic ,copy ,readonly) TokenOperationChain2Block  chain_runOperationWithPriority;
@property(nonatomic ,copy ,readonly) TokenOperationChain0Block  chain_waitUntilDone;
@property(nonatomic ,copy ,readonly) TokenOperationChain0Block  chain_cancelAllOperations;
@property(nonatomic ,copy ,readonly) TokenOperationIntegerBlock chain_setMaxConcurrent;
@end

/**
 a group tasks solution based on TokenOperationQueue
 example:

     //all tasks will be executed concurrently. if you want to set the max number of threads,you'd better to use
     //TokenOperationQueue.sharedQueue.chain_setMaxConcurrent(3);
 
     TokenOperationGroup.group
     .chain_addOperation(^{
        NSLog(@"TASK 1");
     })
     .chain_addOperation(^{
        NSLog(@"TASK 2");
     })
     .chain_addOperation(^{
        NSLog(@"TASK 3");
     })
     .chain_setCompletion(^{
        NSLog(@"done");
     })
     .chain_run();
 */
@interface TokenOperationGroup : NSObject
+(instancetype)group;
-(void)addOperation:(dispatch_block_t)operation;
-(void)addOperation:(dispatch_block_t)operation
       withPriority:(TokenQueuePriority)priority;
-(void)run;
-(void)cancel;
-(void)setCompletion:(dispatch_block_t)completion;
@end

typedef TokenOperationGroup * (^TokenOperationGroupChain0Block) (void);
typedef TokenOperationGroup * (^TokenOperationGroupChain1Block) (dispatch_block_t operation);
typedef TokenOperationGroup * (^TokenOperationGroupChain2Block) (TokenQueuePriority priority,dispatch_block_t operation);

@interface TokenOperationGroup(Chain)
@property(nonatomic ,copy ,readonly) TokenOperationGroupChain1Block chain_addOperation;
@property(nonatomic ,copy ,readonly) TokenOperationGroupChain2Block chain_addOperationWithPriority;
@property(nonatomic ,copy ,readonly) TokenOperationGroupChain1Block chain_setCompletion;
@property(nonatomic ,copy ,readonly) TokenOperationGroupChain0Block chain_run;
@property(nonatomic ,copy ,readonly) dispatch_block_t               chain_cancel;
@end
