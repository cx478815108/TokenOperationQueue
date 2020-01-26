//
//  TokenOperationQueue+Chain.m
//  TokenOperationQueue
//
//  Created by 武嘉晟 on 2020/1/26.
//  Copyright © 2020 Token. All rights reserved.
//

#import "TokenOperationQueue+Chain.h"

@implementation TokenOperationQueue (Chain)

-(TokenOperationChain1Block)chain_runOperation{
    return ^TokenOperationQueue *(dispatch_block_t operation) {
        [self runOperation:operation];
        return self;
    };
}

-(TokenOperationChain2Block)chain_runOperationWithPriority{
    return ^TokenOperationQueue *(TokenQueuePriority priority,dispatch_block_t operation) {
        [self runOperation:operation withPriority:priority];
        return self;
    };
}

-(TokenOperationChain0Block)chain_waitUntilFinished{
    return ^TokenOperationQueue *(void) {
        [self waitUntilFinished];
        return self;
    };
}

-(TokenOperationChain0Block)chain_cancelAllOperations{
    return ^TokenOperationQueue *(void) {
        [self cancelAllOperations];
        return self;
    };
}

-(TokenOperationIntegerBlock)chain_setMaxConcurrent{
    return ^TokenOperationQueue *(NSUInteger maxConcurrent) {
        [self setMaxConcurrent:maxConcurrent];
        return self;
    };
}

@end