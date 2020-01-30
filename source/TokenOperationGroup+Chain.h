//
//  TokenOperationGroup+Chain.h
//  TokenOperationQueue
//
//  Created by 武嘉晟 on 2020/1/26.
//  Copyright © 2020 Token. All rights reserved.
//

#import "TokenOperationGroup.h"

NS_ASSUME_NONNULL_BEGIN

typedef TokenOperationGroup* _Nonnull (^TokenOperationGroupChain0Block) (void);
typedef TokenOperationGroup* _Nonnull (^TokenOperationGroupChain1Block) (dispatch_block_t operation);
typedef TokenOperationGroup* _Nonnull (^TokenOperationGroupChain2Block) (TokenQueuePriority priority,dispatch_block_t operation);
typedef TokenOperationGroup* _Nonnull (^TokenOperationGroupIntegerBlock)(NSUInteger maxConcurrent);

@interface TokenOperationGroup (Chain)
@property (nonatomic, copy, readonly) TokenOperationGroupIntegerBlock chain_setMaxConcurrent;
@property(nonatomic, copy, readonly) TokenOperationGroupChain1Block chain_addOperation;
@property(nonatomic, copy, readonly) TokenOperationGroupChain2Block chain_addOperationWithPriority;
@property(nonatomic, copy, readonly) TokenOperationGroupChain1Block chain_setCompletion;
@property(nonatomic, copy, readonly) TokenOperationGroupChain0Block chain_run;
@property(nonatomic, copy, readonly) dispatch_block_t               chain_cancel;
@end

NS_ASSUME_NONNULL_END
