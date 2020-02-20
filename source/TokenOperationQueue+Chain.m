/**
* Copyright (c) 2018-present, 陈雄 & 武嘉晟
*
* This source code is licensed under the MIT license found in the
* LICENSE file in the root directory
*/

#import "TokenOperationQueue+Chain.h"

@implementation TokenOperationQueue (Chain)

- (TokenOperationUIntegerBlock _Nonnull)chain_setMaxConcurrent {
    return ^TokenOperationQueue *(NSUInteger maxConcurrent) {
        [self setMaxConcurrent:maxConcurrent];
        return self;
    };
}

- (TokenOperationChain1Block _Nonnull)chain_runOperation {
    return ^TokenOperationQueue *(dispatch_block_t _Nonnull operation) {
        [self runOperation:operation];
        return self;
    };
}

- (TokenOperationChain2Block _Nonnull)chain_runOperationWithPriority {
    return ^TokenOperationQueue *(TokenQueuePriority priority,dispatch_block_t _Nonnull operation) {
        [self runOperation:operation withPriority:priority];
        return self;
    };
}

- (dispatch_block_t _Nonnull)chain_waitUntilFinished {
    return ^(void) {
        [self waitUntilFinished];
    };
}

- (dispatch_block_t _Nonnull)chain_cancelAllOperations {
    return ^(void) {
        [self cancelAllOperations];
    };
}

- (dispatch_block_t _Nonnull)chain_finish {
    return ^(void) {};
}

@end
