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
@end
