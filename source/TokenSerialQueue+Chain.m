//
//  TokenSerialQueue+Chain.m
//  TokenOperationQueue
//
//  Created by 武嘉晟 on 2020/2/5.
//  Copyright © 2020 Token. All rights reserved.
//

#import "TokenSerialQueue+Chain.h"

@implementation TokenSerialQueue (Chain)

- (TokenSerialChain0Block _Nonnull)chain_runOperation {
    return ^TokenSerialQueue *(dispatch_block_t _Nonnull operation) {
        [self runOperation:operation];
        return self;
    };
}

- (dispatch_block_t _Nonnull)chain_waitUntilFinished {
    return ^(void) {
        [self waitUntilFinished];
    };
}

- (dispatch_block_t _Nonnull)chain_stop {
    return ^(void) {
        [self stop];
    };
}

@end
