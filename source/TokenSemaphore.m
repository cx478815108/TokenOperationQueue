//
//  TokenSemaphore.m
//  TokenOperationQueue
//
//  Created by 武嘉晟 on 2020/1/25.
//  Copyright © 2020 Token. All rights reserved.
//

#import "TokenSemaphore.h"

@interface TokenSemaphore()

@property(nonatomic, strong) dispatch_semaphore_t semaphore;

@end

@implementation TokenSemaphore

+ (instancetype)waitSemaphore {
    return [[self alloc] initWithCount:0];
}

+ (instancetype)lockSemaphore {
    return [[self alloc] initWithCount:1];
}

- (instancetype)initWithCount:(NSInteger)count {
    if (self = [super init]) {
        _semaphore = dispatch_semaphore_create(count);
    }
    return self;
}

- (void)wait {
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
}

- (void)signal {
    dispatch_semaphore_signal(_semaphore);
}
@end
