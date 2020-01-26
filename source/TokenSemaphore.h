//
//  TokenSemaphore.h
//  TokenOperationQueue
//
//  Created by 武嘉晟 on 2020/1/25.
//  Copyright © 2020 Token. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 信号量对象
@interface TokenSemaphore : NSObject

+ (instancetype) new NS_UNAVAILABLE;
- (instancetype) init NS_UNAVAILABLE;

/**
 初始化信号量为0
 */
+ (instancetype)waitSemaphore;

/**
 初始化信号量为1
 */
+ (instancetype)lockSemaphore;
- (void)wait;
- (void)signal;

@end

NS_ASSUME_NONNULL_END
