//
//  TokenOperationGroup+Chain.m
//  TokenOperationQueue
//
//  Created by 武嘉晟 on 2020/1/26.
//  Copyright © 2020 Token. All rights reserved.
//

#import "TokenOperationGroup+Chain.h"

@implementation TokenOperationGroup (Chain)

-(TokenOperationGroupChain1Block)chain_addOperation{
    return ^TokenOperationGroup *(dispatch_block_t operation){
        [self addOperation:operation];
        return self;
    };
}

-(TokenOperationGroupChain2Block)chain_addOperationWithPriority{
    return ^TokenOperationGroup *(TokenQueuePriority priority,dispatch_block_t operation){
        [self addOperation:operation withPriority:priority];
        return self;
    };
}

-(TokenOperationGroupChain1Block)chain_setCompletion{
    return ^TokenOperationGroup *(dispatch_block_t completion){
        [self setCompletion:completion];
        return self;
    };
}

-(TokenOperationGroupChain0Block)chain_run{
    return ^TokenOperationGroup *(void){
        [self run];
        return self;
    };
}

-(dispatch_block_t)chain_cancel{
    return ^(void){
        [self cancel];
    };
}

@end
