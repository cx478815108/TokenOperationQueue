/**
* Copyright (c) 2018-present, 陈雄 武嘉晟
*
* This source code is licensed under the MIT license found in the
* LICENSE file in the root directory
*/

#import "TokenOperationGroup.h"

NS_ASSUME_NONNULL_BEGIN

typedef TokenOperationGroup * _Nonnull (^TokenOperationGroupChain0Block) (void);
typedef TokenOperationGroup * _Nonnull (^TokenOperationGroupChain1Block) (dispatch_block_t _Nonnull operation);
typedef TokenOperationGroup * _Nonnull (^TokenOperationGroupChain2Block) (NSOperationQueuePriority priority, dispatch_block_t _Nonnull operation);
typedef TokenOperationGroup * _Nonnull (^TokenOperationGroupUIntegerBlock) (NSUInteger maxConcurrent);

@interface TokenOperationGroup (Chain)

@property (nonatomic, copy, readonly, nonnull) TokenOperationGroupUIntegerBlock chain_setMaxConcurrent;
@property (nonatomic, copy, readonly, nonnull) TokenOperationGroupChain1Block   chain_addOperation;
@property (nonatomic, copy, readonly, nonnull) TokenOperationGroupChain2Block   chain_addOperationWithPriority;
@property (nonatomic, copy, readonly, nonnull) TokenOperationGroupChain1Block   chain_setCompletion;
@property (nonatomic, copy, readonly, nonnull) TokenOperationGroupChain0Block   chain_run;
@property (nonatomic, copy, readonly, nonnull) dispatch_block_t                 chain_cancel;

@end

NS_ASSUME_NONNULL_END
