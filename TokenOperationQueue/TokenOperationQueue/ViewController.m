//
//  ViewController.m
//  TokenOperationQueue
//
//  Created by 武嘉晟 on 2019/7/7.
//  Copyright © 2019 Token. All rights reserved.
//

#import "ViewController.h"
#import "TokenOperationHeader.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self serialQueue];
}

#pragma mark - queue

- (void)runOperation {
    TokenOperationQueue
    .sharedQueue
    .chain_setMaxConcurrent(2)
    .chain_runOperation(^{
        NSLog(@"1s");
        sleep(1);
        NSLog(@"1e");
    })
    .chain_runOperation(^{
        NSLog(@"2s");
        sleep(2);
        NSLog(@"2e");
    })
    .chain_runOperation(^{
        NSLog(@"3s");
        sleep(3);
        NSLog(@"3e");
    })
    .chain_runOperation(^{
        NSLog(@"4s");
        sleep(3);
        NSLog(@"4e");
    })
    .chain_runOperation(^{
        NSLog(@"5s");
        sleep(2);
        NSLog(@"5e");
    })
    .chain_runOperation(^{
        NSLog(@"6s");
        sleep(1);
        NSLog(@"6e");
    });
}

- (void)runOperationWithPriority {
    TokenOperationQueue
    .sharedQueue
    .chain_runOperationWithPriority(TokenQueuePriorityBackground, ^{
        NSLog(@"1s");
        sleep(3);
        NSLog(@"1e");
    })
    .chain_runOperationWithPriority(TokenQueuePriorityBackground, ^{
        NSLog(@"1s");
        sleep(3);
        NSLog(@"1e");
    })
    .chain_runOperationWithPriority(TokenQueuePriorityBackground, ^{
        NSLog(@"1s");
        sleep(3);
        NSLog(@"1e");
    })
    .chain_runOperationWithPriority(TokenQueuePriorityLow, ^{
        NSLog(@"2s");
        sleep(5);
        NSLog(@"2e");
    })
    .chain_runOperationWithPriority(TokenQueuePriorityLow, ^{
        NSLog(@"2s");
        sleep(5);
        NSLog(@"2e");
    })
    .chain_runOperationWithPriority(TokenQueuePriorityLow, ^{
        NSLog(@"2s");
        sleep(5);
        NSLog(@"2e");
    })
    .chain_runOperationWithPriority(TokenQueuePriorityDefault, ^{
        NSLog(@"3s");
        sleep(1);
        NSLog(@"3e");
    })
    .chain_runOperationWithPriority(TokenQueuePriorityDefault, ^{
        NSLog(@"3s");
        sleep(1);
        NSLog(@"3e");
    })
    .chain_runOperationWithPriority(TokenQueuePriorityDefault, ^{
        NSLog(@"3s");
        sleep(1);
        NSLog(@"3e");
    })
    .chain_runOperationWithPriority(TokenQueuePriorityHigh, ^{
        NSLog(@"4s");
        sleep(1);
        NSLog(@"4e");
    })
    .chain_runOperationWithPriority(TokenQueuePriorityHigh, ^{
        NSLog(@"4s");
        sleep(1);
        NSLog(@"4e");
    })
    .chain_runOperationWithPriority(TokenQueuePriorityHigh, ^{
        NSLog(@"4s");
        sleep(1);
        NSLog(@"4e");
    });
}

- (void)changeMaxConcurrent {
    TokenOperationQueue
    .sharedQueue
    .chain_setMaxConcurrent(1)
    .chain_runOperation(^{
        NSLog(@"1s");
        sleep(1);
        NSLog(@"1e");
    })
    .chain_runOperation(^{
        NSLog(@"2s");
        sleep(2);
        NSLog(@"2e");
    })
    .chain_runOperation(^{
        NSLog(@"3s");
        sleep(3);
        NSLog(@"3e");
    })
    .chain_runOperation(^{
        NSLog(@"4s");
        sleep(3);
        NSLog(@"4e");
    })
    .chain_runOperation(^{
        NSLog(@"5s");
        sleep(2);
        NSLog(@"5e");
    })
    .chain_runOperation(^{
        NSLog(@"6s");
        sleep(1);
        NSLog(@"6e");
    });
}

- (void)waitUntilFinished {
    TokenOperationQueue
    .sharedQueue
    .chain_runOperation(^{
        sleep(6);
        NSLog(@"1");
    })
    .chain_runOperation(^{
        sleep(2);
        NSLog(@"2");
    })
    .chain_runOperation(^{
        sleep(1);
        NSLog(@"3");
    })
    .chain_runOperation(^{
        sleep(1);
        NSLog(@"4");
    })
    .chain_runOperation(^{
        sleep(1);
        NSLog(@"5");
    })
    .chain_waitUntilFinished();
    NSLog(@"done");
}

- (void)cancelAllOperations {
    __block TokenOperationQueue *queue = TokenOperationQueue
    .sharedQueue
    .chain_setMaxConcurrent(2)
    .chain_runOperationWithPriority(TokenQueuePriorityBackground, ^{
        NSLog(@"1s");
        sleep(3);
        NSLog(@"1e");
    })
    .chain_runOperation(^{
        NSLog(@"1s");
        sleep(2);
        NSLog(@"1e");
    })
    .chain_runOperation(^{
        NSLog(@"2s");
        sleep(2);
        NSLog(@"2e");
    })
    .chain_runOperation(^{
        NSLog(@"3s");
        sleep(2);
        NSLog(@"3e");
    })
    .chain_runOperation(^{
        NSLog(@"4s");
        sleep(2);
        NSLog(@"4e");
    })
    .chain_runOperation(^{
        NSLog(@"5s");
        sleep(2);
        NSLog(@"5e");
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"ready to cancel");
        queue.chain_cancelAllOperations();
        NSLog(@"canceled");
    });
    NSLog(@"done");
}

#pragma mark - group

- (void)group {
    TokenOperationGroup
    .group
    .chain_setMaxConcurrent(2)
    .chain_addOperation(^{
        NSLog(@"1s");
        sleep(1);
        NSLog(@"1e");
    })
    .chain_addOperation(^{
        NSLog(@"2");
    })
    .chain_addOperation(^{
        NSLog(@"3");
    })
    .chain_addOperation(^{
        NSLog(@"4");
    })
    .chain_setCompletion(^{
        NSLog(@"done");
    })
    .chain_run();
}

- (void)groupWithPriority {
    TokenOperationGroup
    .group
    .chain_setMaxConcurrent(2)
    .chain_addOperationWithPriority(NSOperationQueuePriorityVeryLow, ^{
        NSLog(@"1");
    })
    .chain_addOperationWithPriority(NSOperationQueuePriorityLow, ^{
        NSLog(@"2");
    })
    .chain_addOperationWithPriority(NSOperationQueuePriorityNormal, ^{
        NSLog(@"3");
    })
    .chain_addOperationWithPriority(NSOperationQueuePriorityHigh, ^{
        NSLog(@"4");
    })
    .chain_addOperationWithPriority(NSOperationQueuePriorityVeryHigh, ^{
        NSLog(@"5");
    })
    .chain_setCompletion(^{
        NSLog(@"done");
    })
    .chain_run();
}

- (void)groupCancel {
    __block TokenOperationGroup *group = TokenOperationGroup
    .group
    .chain_setMaxConcurrent(1)
    .chain_addOperation(^{
        NSLog(@"1s");
        sleep(1);
        NSLog(@"1e");
    })
    .chain_addOperation(^{
        NSLog(@"2s");
        sleep(1);
        NSLog(@"2e");
    })
    .chain_addOperation(^{
        NSLog(@"3s");
        sleep(1);
        NSLog(@"3e");
    })
    .chain_addOperation(^{
        NSLog(@"4s");
        sleep(1);
        NSLog(@"4e");
    })
    .chain_addOperation(^{
        NSLog(@"5s");
        sleep(1);
        NSLog(@"5e");
    })
    .chain_setCompletion(^{
        NSLog(@"done");
    })
    .chain_run();
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"ready to cancel");
        group.chain_cancel();
        NSLog(@"canceled");
    });
}

#pragma mark - serialQueue

- (void)serialQueue {
    TokenSerialQueue *queue = TokenSerialQueue.queue;
    [queue runOperation:^{
        NSLog(@"1s");
        sleep(1);
        NSLog(@"1e");
    }];
    [queue runOperation:^{
        NSLog(@"2s");
        sleep(1);
        NSLog(@"2e");
    }];
    [queue runOperation:^{
        NSLog(@"3s");
        sleep(1);
        NSLog(@"3e");
    }];
    [queue runOperation:^{
        NSLog(@"4s");
        sleep(1);
        NSLog(@"4e");
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"ready to cancel");
        [queue stop];
        NSLog(@"canceled");
    });
}

@end
