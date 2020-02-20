/**
* Copyright (c) 2018-present, 陈雄 & 武嘉晟
*
* This source code is licensed under the MIT license found in the
* LICENSE file in the root directory
*/

#import "TokenSerialQueue.h"

NS_ASSUME_NONNULL_BEGIN

typedef TokenSerialQueue * _Nonnull (^TokenSerialChain0Block) (dispatch_block_t _Nonnull operation);

@interface TokenSerialQueue (Chain)

@property (nonatomic, copy, readonly, nonnull) TokenSerialChain0Block   chain_runOperation;
@property (nonatomic, copy, readonly, nonnull) dispatch_block_t         chain_waitUntilFinished;
@property (nonatomic, copy, readonly, nonnull) dispatch_block_t         chain_stop;
@property (nonatomic, copy, readonly, nonnull) dispatch_block_t         chain_finish;

@end

NS_ASSUME_NONNULL_END
