/**
* Copyright (c) 2018-present, 陈雄 & 武嘉晟
*
* This source code is licensed under the MIT license found in the
* LICENSE file in the root directory
*/

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
