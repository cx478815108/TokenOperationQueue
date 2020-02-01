//
//  TokenOperationGroup+Chain.m
//  TokenOperationQueue
//
//  Created by 武嘉晟 on 2020/1/26.
//  Copyright © 2020 Token. All rights reserved.
//

#import "TokenOperationGroup+Chain.h"

@implementation TokenOperationGroup (Chain)

- (TokenOperationGroupUIntegerBlock _Nonnull)chain_setMaxConcurrent {
    return ^TokenOperationGroup *(NSUInteger maxConcurrent) {
        [self setMaxConcurrent:maxConcurrent];
        return self;
    };
}

- (TokenOperationGroupChain1Block _Nonnull)chain_addOperation {
    return ^TokenOperationGroup *(dispatch_block_t _Nonnull operation) {
        [self addOperation:operation];
        return self;
    };
}

- (TokenOperationGroupChain2Block _Nonnull)chain_addOperationWithPriority {
    return ^TokenOperationGroup *(NSOperationQueuePriority priority,dispatch_block_t _Nonnull operation) {
        [self addOperation:operation withPriority:priority];
        return self;
    };
}

- (TokenOperationGroupChain1Block _Nonnull)chain_setCompletion {
    return ^TokenOperationGroup *(dispatch_block_t _Nullable completion) {
        [self setCompletion:completion];
        return self;
    };
}

- (TokenOperationGroupChain0Block _Nonnull)chain_run {
    return ^TokenOperationGroup *(void) {
        [self run];
        return self;
    };
}

- (dispatch_block_t _Nonnull)chain_cancel {
    return ^(void) {
        [self cancel];
    };
}

@end
