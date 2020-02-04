//
//  TokenOperationQueue+Chain.m
//  TokenOperationQueue
//
//  Created by 武嘉晟 on 2020/1/26.
//  Copyright © 2020 Token. All rights reserved.
//

#import "TokenOperationQueue+Chain.h"

@implementation TokenOperationQueue (Chain)

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

- (TokenOperationChain0Block _Nonnull)chain_cancelAllOperations {
    return ^TokenOperationQueue *(void) {
        [self cancelAllOperations];
        return self;
    };
}

- (TokenOperationUIntegerBlock _Nonnull)chain_setMaxConcurrent {
    return ^TokenOperationQueue *(NSUInteger maxConcurrent) {
        [self setMaxConcurrent:maxConcurrent];
        return self;
    };
}

- (dispatch_block_t _Nonnull)chain_finish {
    return ^(void) {};
}

@end
