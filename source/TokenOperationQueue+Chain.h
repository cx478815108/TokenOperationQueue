//
//  TokenOperationQueue+Chain.h
//  TokenOperationQueue
//
//  Created by 武嘉晟 on 2020/1/26.
//  Copyright © 2020 Token. All rights reserved.
//

#import "TokenOperationQueue.h"

NS_ASSUME_NONNULL_BEGIN

typedef TokenOperationQueue* _Nonnull (^TokenOperationChain0Block) (void);
typedef TokenOperationQueue* _Nonnull (^TokenOperationChain1Block) (dispatch_block_t _Nonnull operation);
typedef TokenOperationQueue* _Nonnull (^TokenOperationChain2Block) (TokenQueuePriority priority,dispatch_block_t _Nonnull operation);
typedef TokenOperationQueue* _Nonnull (^TokenOperationUIntegerBlock) (NSUInteger maxConcurrent);

@interface TokenOperationQueue (Chain)

@property(nonatomic ,copy ,readonly, nonnull) TokenOperationChain1Block     chain_runOperation;
@property(nonatomic ,copy ,readonly, nonnull) TokenOperationChain2Block     chain_runOperationWithPriority;
@property(nonatomic ,copy ,readonly, nonnull) TokenOperationChain0Block     chain_waitUntilFinished;
@property(nonatomic ,copy ,readonly, nonnull) TokenOperationChain0Block     chain_cancelAllOperations;
@property(nonatomic ,copy ,readonly, nonnull) TokenOperationUIntegerBlock   chain_setMaxConcurrent;

@end

NS_ASSUME_NONNULL_END
