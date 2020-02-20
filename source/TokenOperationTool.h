/**
* Copyright (c) 2018-present, 陈雄 & 武嘉晟
*
* This source code is licensed under the MIT license found in the
* LICENSE file in the root directory
*/

#import <Foundation/Foundation.h>

#ifndef TokenOperationTool_h
#define TokenOperationTool_h

void TokenOperationRunOnMainThread(dispatch_block_t _Nonnull operation);
void TokenTranscationCommit(dispatch_block_t _Nonnull operation);
void TokenDispatchApply(size_t count,
                        dispatch_queue_t _Nonnull queue,
                        NSUInteger threadCount,
                        void(^ _Nonnull work)(size_t i));
BOOL TokenIsMainThread(void);

#endif  /* TokenOperationTool_h*/
