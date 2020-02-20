/**
* Copyright (c) 2018-present, 陈雄 & 武嘉晟
*
* This source code is licensed under the MIT license found in the
* LICENSE file in the root directory
*/

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 信号量对象
@interface TokenSemaphore : NSObject

+ (instancetype _Nonnull)new NS_UNAVAILABLE;
- (instancetype _Nonnull)init NS_UNAVAILABLE;
/**
 初始化信号量为0
 */
+ (instancetype _Nonnull)waitSemaphore;
/**
 初始化信号量为1
 */
+ (instancetype _Nonnull)lockSemaphore;
- (void)wait;
- (void)signal;

@end

NS_ASSUME_NONNULL_END
