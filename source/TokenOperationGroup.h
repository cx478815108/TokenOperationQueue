//
//  TokenOperationGroup.h
//  TokenOperationQueue
//
//  Created by 武嘉晟 on 2020/1/26.
//  Copyright © 2020 Token. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TokenOperationQueue.h"

NS_ASSUME_NONNULL_BEGIN

@interface TokenOperationGroup : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
+ (instancetype)group;

- (void)addOperation:(dispatch_block_t _Nullable)operation;
- (void)addOperation:(dispatch_block_t _Nullable)operation
        withPriority:(TokenQueuePriority)priority;
- (void)run;
- (void)cancel;
- (void)setCompletion:(dispatch_block_t _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
