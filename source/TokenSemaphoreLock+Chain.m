/**
* Copyright (c) 2018-present, 陈雄 & 武嘉晟
*
* This source code is licensed under the MIT license found in the
* LICENSE file in the root directory
*/

#import "TokenSemaphoreLock+Chain.h"

@implementation TokenSemaphoreLock (Chain)

- (TokenSemaphoreLockOperation)runLockOperation {
    return ^(dispatch_block_t _Nonnull operation) {
        NSAssert(operation, @"operation cannot be nil, please check your code");
        if (!operation) {
            return;
        }
        [self lock];
        operation();
        [self unlock];
    };
}
@end
