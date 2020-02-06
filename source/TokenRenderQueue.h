//
//  TokenRenderQueue.h
//  TokenOperationQueue
//
//  Created by 武嘉晟 on 2020/1/25.
//  Copyright © 2020 Token. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TokenRenderQueue : NSObject

- (instancetype _Nonnull)init NS_UNAVAILABLE;
+ (instancetype _Nonnull)new NS_UNAVAILABLE;
+ (instancetype _Nonnull)sharedRenderQueue;
- (void)addTask:(dispatch_block_t _Nonnull)task;

@end

NS_ASSUME_NONNULL_END
