/**
* Copyright (c) 2018-present, 陈雄 & 武嘉晟
*
* This source code is licensed under the MIT license found in the
* LICENSE file in the root directory
*/

#import "TokenSemaphoreLock.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^TokenSemaphoreLockOperation)(dispatch_block_t _Nonnull operation);

@interface TokenSemaphoreLock (Chain)

@property (nonatomic, copy, readonly, nonnull) TokenSemaphoreLockOperation runLockOperation;

@end

NS_ASSUME_NONNULL_END
