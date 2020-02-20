/**
* Copyright (c) 2018-present, 陈雄 & 武嘉晟
*
* This source code is licensed under the MIT license found in the
* LICENSE file in the root directory
*/

#import "TokenOperationQueue.h"
#import "TokenOperationTool.h"
#import <stdatomic.h>
#import <pthread.h>

void TokenOperationRunOnMainThread(dispatch_block_t _Nonnull operation) {
    assert(operation);
    if (!operation) {
        return;
    }
    if (TokenIsMainThread()) {
        operation();
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            operation();
        });
    }
}

void TokenDispatchApply(size_t count,
                        dispatch_queue_t _Nonnull queue,
                        NSUInteger threadCount,
                        void(^ _Nonnull work)(size_t i)) {
    assert(queue && work);
    if (!queue || !work) {
        return;
    }
    if (threadCount == 0) {
        threadCount = 2;
    }
    dispatch_group_t group = dispatch_group_create();
    __block atomic_size_t counter = ATOMIC_VAR_INIT(0);
    for (NSUInteger t = 0; t < threadCount; t++) {
        dispatch_group_async(group, queue, ^{
            size_t i;
            while ((i = atomic_fetch_add(&counter, 1)) < count) {
                work(i);
            }
        });
    }
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
}

BOOL TokenIsMainThread(void) {
    return (0 != pthread_main_np());
}
