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

void TokenOperationRunOnMainThread(dispatch_block_t operation);
void TokenTranscationCommit(dispatch_block_t operation);
void TokenDispatchApply(size_t count,
                        dispatch_queue_t queue,
                        NSUInteger threadCount,
                        void(^work)(size_t i));
BOOL TokenIsMainThread(void);

#endif  /* TokenOperationTool_h*/
