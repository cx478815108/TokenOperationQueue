/**
* Copyright (c) 2018-present, 陈雄 & 武嘉晟
*
* This source code is licensed under the MIT license found in the
* LICENSE file in the root directory
*/

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TokenRenderQueue : NSObject

- (instancetype _Nonnull)init NS_UNAVAILABLE;
+ (instancetype _Nonnull)new NS_UNAVAILABLE;
+ (instancetype _Nonnull)sharedRenderQueue;
- (void)addTask:(dispatch_block_t _Nonnull)task;

@end

NS_ASSUME_NONNULL_END
