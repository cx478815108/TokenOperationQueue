//
//  TokenOperationGroup.h
//  TokenOperationQueue
//
//  Created by 武嘉晟 on 2020/1/26.
//  Copyright © 2020 Token. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TokenOperationGroup : NSObject

- (instancetype _Nonnull)init NS_UNAVAILABLE;
+ (instancetype _Nonnull)new NS_UNAVAILABLE;
/// 唯一获取group的方法，并非单例，所有任务执行完毕该对象释放
+ (instancetype _Nonnull)group;
/// 设置最大并发数
/// @param maxConcurrent 最大并发数
- (void)setMaxConcurrent:(NSUInteger)maxConcurrent;
/// 按照默认优先级添加任务
/// @param operation 要执行的任务
- (void)addOperation:(dispatch_block_t _Nonnull)operation;
/// 按照指定优先级添加任务
/// @param operation 要执行的任务
/// @param priority 优先级
- (void)addOperation:(dispatch_block_t _Nonnull)operation
        withPriority:(NSOperationQueuePriority)priority;
/// 设置结束任务
/// @param completion 上述任务执行完毕后执行的的结束任务
- (void)setCompletion:(dispatch_block_t _Nullable)completion;
/// 开始执行
- (void)run;
/// 结束任务，未执行的任务不再执行
- (void)cancel;

@end

NS_ASSUME_NONNULL_END
