/**
* Copyright (c) 2018-present, 陈雄 & 武嘉晟
*
* This source code is licensed under the MIT license found in the
* LICENSE file in the root directory
*/

#import "TokenSemaphoreLock+Chain.h"

@implementation TokenSemaphoreLock (Chain)

- (TokenSemaphoreLockOperation)runLockOperation {
    return ^(dispatch_block_t  _Nonnull operation) {
        if (operation) {
            [self lock];
            operation();
            [self unlock];
        }
    };
}
@end
