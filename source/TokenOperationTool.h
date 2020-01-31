//
//  TokenOperationTool.h
//  TokenOperationQueue
//
//  Created by 武嘉晟 on 2020/1/25.
//  Copyright © 2020 Token. All rights reserved.
//

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
