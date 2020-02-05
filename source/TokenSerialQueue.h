//
//  TokenSerialQueue.h
//  TokenOperationQueue
//
//  Created by 武嘉晟 on 2020/2/5.
//  Copyright © 2020 Token. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TokenSerialQueue : NSObject

- (instancetype _Nonnull)init NS_UNAVAILABLE;
+ (instancetype _Nonnull)new NS_UNAVAILABLE;
+ (instancetype _Nonnull)queue;
/// 执行任务
/// @param operation 任务
- (void)runOperation:(dispatch_block_t _Nonnull)operation;
/// 阻塞当前Thread，等待所有任务执行完毕该方法才会返回
- (void)waitUntilFinished;
/// 取消所有未执行任务
- (void)stop;

@end

NS_ASSUME_NONNULL_END
