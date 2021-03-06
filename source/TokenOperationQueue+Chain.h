/**
* Copyright (c) 2018-present, 陈雄 & 武嘉晟
*
* This source code is licensed under the MIT license found in the
* LICENSE file in the root directory
*/

#import "TokenOperationQueue.h"

NS_ASSUME_NONNULL_BEGIN

typedef TokenOperationQueue * _Nonnull (^TokenOperationChain1Block) (dispatch_block_t _Nonnull operation);
typedef TokenOperationQueue * _Nonnull (^TokenOperationChain2Block) (TokenQueuePriority priority, dispatch_block_t _Nonnull operation);
typedef TokenOperationQueue * _Nonnull (^TokenOperationUIntegerBlock) (NSUInteger maxConcurrent);

@interface TokenOperationQueue (Chain)

@property (nonatomic, copy, readonly, nonnull) TokenOperationUIntegerBlock  chain_setMaxConcurrent;
@property (nonatomic, copy, readonly, nonnull) TokenOperationChain1Block    chain_runOperation;
@property (nonatomic, copy, readonly, nonnull) TokenOperationChain2Block    chain_runOperationWithPriority;
@property (nonatomic, copy, readonly, nonnull) dispatch_block_t             chain_waitUntilFinished;
@property (nonatomic, copy, readonly, nonnull) dispatch_block_t             chain_cancelAllOperations;
@property (nonatomic, copy, readonly, nonnull) dispatch_block_t             chain_finish;

@end

NS_ASSUME_NONNULL_END
