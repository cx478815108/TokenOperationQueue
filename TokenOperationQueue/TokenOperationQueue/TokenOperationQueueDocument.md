/**
TokenOperationQueue provides an easy way to use threads with priority and to solve the problem with too many threads

example:
    TokenOperationQueue.sharedQueue.chain_setMaxConcurrent(3); // max number of threads is 3;
    TokenOperationQueue.sharedQueue
    .runOperation(^{
        NSLog(@"task1");
    })
    .runOperation(^{
        NSLog(@"task2");
    })
    .runOperationwithPriority(TokenQueuePriorityHigh,^{
        NSLog(@"task3");
    });
 
    [TokenOperationQueue.sharedQueue waitUntilDone]; //this will block the current thread until the previous tasks are all finished;
 
 or you can use like this:
     [TokenOperationQueue.sharedQueue .runOperation(^{
         NSLog(@"task1");
     }];
 
     [TokenOperationQueue.sharedQueue .runOperation(^{
        NSLog(@"task2");
     }];
 
     [TokenOperationQueue.sharedQueue .runOperation(^{
        NSLog(@"task3");
     }];
 
 */

/**
do not call like this
    runOperation(^{
           ...
        [TokenOperationQueue.sharedQueue waitUntilDone];
    });
or it will cause a deadlock
*/

/**
a group tasks solution based on TokenOperationQueue
example:

    //all tasks will be executed concurrently. if you want to set the max number of threads,you'd better to use
    //TokenOperationQueue.sharedQueue.chain_setMaxConcurrent(3);

    TokenOperationGroup.group
    .chain_addOperation(^{
       NSLog(@"TASK 1");
    })
    .chain_addOperation(^{
       NSLog(@"TASK 2");
    })
    .chain_addOperation(^{
       NSLog(@"TASK 3");
    })
    .chain_setCompletion(^{
       NSLog(@"done");
    })
    .chain_run();
*/
