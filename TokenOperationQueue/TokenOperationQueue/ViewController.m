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
}
- (IBAction)buttonOne:(UIButton *)sender {
    [self testThree];
}

- (void)testOne {
    TokenOperationQueue
    .sharedQueue
    .chain_setMaxConcurrent(20)
    .chain_runOperation(^{
        sleep(2);
        NSLog(@"1");
    })
    .chain_runOperation(^{
        sleep(1);
        NSLog(@"2");
    })
    .chain_runOperation(^{
        sleep(10);
        NSLog(@"3");
    })
    .chain_runOperation(^{
        sleep(1);
        NSLog(@"4");
    })
    .chain_runOperation(^{
        sleep(2);
        NSLog(@"5");
    })
    .chain_waitUntilFinished();

    NSLog(@"next");
}

- (void)textTwo {
    [TokenOperationQueue.sharedQueue runOperation:^{
        NSLog(@"1");
    }];
    [TokenOperationQueue.sharedQueue runOperation:^{
        NSLog(@"2");
    }];
    [TokenOperationQueue.sharedQueue runOperation:^{
        NSLog(@"3");
    }];
    [TokenOperationQueue.sharedQueue runOperation:^{
        NSLog(@"4");
    }];
    [TokenOperationQueue.sharedQueue runOperation:^{
        NSLog(@"5");
    }];
    [TokenOperationQueue.sharedQueue waitUntilFinished];
}

- (void)testThree {
    TokenOperationQueue
    .sharedQueue
    .chain_setMaxConcurrent(3);
    __block TokenOperationGroup *group = TokenOperationGroup.group;
    group
    .chain_addOperation(^{
        sleep(1);
        NSLog(@"1");
    })
    .chain_addOperation(^{
        sleep(2);
        NSLog(@"2");
    })
    .chain_addOperation(^{
        sleep(3);
        NSLog(@"3");
    })
    .chain_addOperation(^{
        sleep(1);
        NSLog(@"4");
    })
    .chain_addOperation(^{
        sleep(2);
        NSLog(@"5");
    })
    .chain_addOperation(^{
        sleep(3);
        NSLog(@"6");
    })
    .chain_setCompletion(^{
        NSLog(@"finish");
    })
    .chain_run();
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (ino64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        group.chain_cancel();
    });
}

- (void)functionOne {
    NSBlockOperation *blockOp = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"1");
    }];
    [blockOp addExecutionBlock:^{
        NSLog(@"2");
    }];
    [blockOp addExecutionBlock:^{
        NSLog(@"3");
    }];
    [blockOp addExecutionBlock:^{
        NSLog(@"4");
    }];
    [blockOp addExecutionBlock:^{
        NSLog(@"5");
    }];
    [blockOp start];
}

- (void)functionTwo {
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"1");
    }];
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"2");
    }];
    NSBlockOperation *op3 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"3");
    }];
    NSBlockOperation *op4 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"4");
    }];
    NSBlockOperation *op5 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"5");
    }];
    NSBlockOperation *op6 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"6");
    }];
    NSOperationQueue *queue = NSOperationQueue.mainQueue;
    [queue addOperations:@[op1, op2, op3, op4, op5, op6] waitUntilFinished:YES];
    NSLog(@"all down");
}
@end
