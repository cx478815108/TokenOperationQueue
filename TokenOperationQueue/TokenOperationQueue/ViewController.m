//
//  ViewController.m
//  TokenOperationQueue
//
//  Created by 武嘉晟 on 2019/7/7.
//  Copyright © 2019 Token. All rights reserved.
//

#import "ViewController.h"
#import "TokenOperationHeader.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}
- (IBAction)buttonOne:(UIButton *)sender {
    [self testOne];
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
