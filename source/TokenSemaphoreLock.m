/**
* Copyright (c) 2018-present, 陈雄 & 武嘉晟
*
* This source code is licensed under the MIT license found in the
* LICENSE file in the root directory
*/

#import "TokenSemaphoreLock.h"

@interface TokenSemaphoreLock()
@property (nonatomic, strong, nonnull) dispatch_semaphore_t lockSemaphore;
@end

@implementation TokenSemaphoreLock

+ (instancetype)semaphoreLock {
    return [[self alloc] init];
}

#pragma mark - API
- (void)lock {
    dispatch_semaphore_wait(self.lockSemaphore, DISPATCH_TIME_FOREVER);
}

- (void)unlock {
    dispatch_semaphore_signal(self.lockSemaphore);
}

#pragma mark - getter
- (dispatch_semaphore_t)lockSemaphore {
    if (!_lockSemaphore) {
        _lockSemaphore = dispatch_semaphore_create(1);
    }
    return _lockSemaphore;
}

@end
