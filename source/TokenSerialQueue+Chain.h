//
//  TokenSerialQueue+Chain.h
//  TokenOperationQueue
//
//  Created by 武嘉晟 on 2020/2/5.
//  Copyright © 2020 Token. All rights reserved.
//

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
