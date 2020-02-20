/**
* Copyright (c) 2018-present, 陈雄 & 武嘉晟
*
* This source code is licensed under the MIT license found in the
* LICENSE file in the root directory
*/

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TokenSemaphoreLock : NSObject

+ (instancetype _Nonnull)new NS_UNAVAILABLE;

- (instancetype _Nonnull)init NS_UNAVAILABLE;

/// 信号量锁
+ (instancetype _Nonnull)semaphoreLock;

- (void)lock;

- (void)unlock;

@end

NS_ASSUME_NONNULL_END
