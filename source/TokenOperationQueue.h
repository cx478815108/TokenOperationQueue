//
//  TokenQueue.h
//  TokenOperation
//
//  Created by 陈雄 on 2018/5/3.
//  Copyright © 2018年 com.feelings. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(long, TokenQueuePriority) {
    TokenQueuePriorityHigh       = 2,         // equal to DISPATCH_QUEUE_PRIORITY_HIGH
    TokenQueuePriorityDefault    = 0,         // equal to DISPATCH_QUEUE_PRIORITY_DEFAULT
    TokenQueuePriorityLow        = -2,        // equal to DISPATCH_QUEUE_PRIORITY_LOW
    TokenQueuePriorityBackground = INT16_MIN, // equal to DISPATCH_QUEUE_PRIORITY_BACKGROUND
};

@interface TokenOperationQueue : NSObject

/// 最大并发数，可用于sharedQueue初始化之后进行修改
@property(nonatomic, assign) NSUInteger maxConcurrent;

- (instancetype _Nonnull)init NS_UNAVAILABLE;
+ (instancetype _Nonnull)new NS_UNAVAILABLE;
/// 获取全局并发队列单例 最大并发数和cpu相关
+ (instancetype _Nonnull)sharedQueue;
/// 获取串行queue，并非单例，所有任务执行完毕该对象释放
+ (instancetype _Nonnull)serialQueue;
/// 以默认优先级执行任务
/// @param operation 任务
- (void)runOperation:(dispatch_block_t _Nonnull)operation;
/// 以指定优先级执行任务（仅并行队列可用）
/// @param operation 任务
/// @param priority 优先级
- (void)runOperation:(dispatch_block_t _Nonnull)operation
        withPriority:(TokenQueuePriority)priority;
/// 阻塞当前Thread，等待所有任务执行完毕该方法才会返回
- (void)waitUntilFinished;
/// 取消所有未执行任务
- (void)cancelAllOperations;

@end
