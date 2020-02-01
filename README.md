#TokenOperationQueue 

TokenOperationQueue provides an easy way to use threads with priority and to solve the problem with too many threads.

## Installation with CocoaPods(TODO)

[CocoaPods](http://cocoapods.org/) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries like TokenOperationQueue in your projects. You can install it with the following command:

```
$ gem install cocoapods
```

 ### podfile

To integrate TokenOperationQueue into your Xcode project using CocoaPods, specify it in your Podfile:

```
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '11.0'

target 'TargetName' do
pod 'TokenOperationQueue'
end
```

Then, run the following command:

```
$ pod install
```

## Architecture

- TokenOperationGroup

- - TokenOperationGroup+Chain

- TokenOperationQueue

- - TokenOperationQueue+Chain

- TokenOperationTool

- TokenRenderQueue

- TokenSemaphore

### TokenOperationGroup

a group tasks solution based on NSOperationQueue

### TokenOperationQueue

A GCD wrapper that allow you set the max number of concurrent. So easy to use!

You can also run operation serially.

### TokenOperationTool

Some useful tools.

### TokenSemaphore

dispatch_semaphore_t wrapper that allow you use semaphore elegantly.

## Usage

### Queue

#### run operation concurrently

code

```
TokenOperationQueue
  .sharedQueue
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
```

Output

```
**1s**
**3s**
**2s**
**4s**
**5s**
**6s**
**1e**
**6e**
**5e**
**2e**
**4e**
**3e**
```

#### run operation concurrently with priority

Code

```
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
```

Output

```
**4s**
**4s**
**4s**
**4e**
**4e**
**4e**
**3s**
**3s**
**3s**
**3e**
**3e**
**3e**
**2s**
**2s**
**2s**
**2e**
**2e**
**2e**
**1s**
**1s**
**1s**
**1e**
**1e**
**1e**
```

#### changeMaxConcurrent

Code

```
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
```

Output

```
**1s**
**1e**
**2s**
**2e**
**3s**
**3e**
**4s**
**4e**
**5s**
**5e**
**6s**
**6e**
```

#### waitUntilFinished

Code

```
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
  .chain_waitUntilFinished()
  .chain_runOperation(^{
    NSLog(@"6");
  })
  .chain_runOperation(^{
    NSLog(@"7");
  })
  .chain_runOperation(^{
    sleep(5);
    NSLog(@"8");
  })
  .chain_waitUntilFinished()
  .chain_runOperation(^{
    sleep(5);
    NSLog(@"9");
  })
  .chain_waitUntilFinished();
  NSLog(@"done");
```

Output

```
**4**
**5**
**3**
**2**
**1**
**6**
**7**
**8**
**9**
**done**
```

#### cancelAllOperations

Code

```
__block TokenOperationQueue *queue = TokenOperationQueue
  .queue
  .chain_setMaxConcurrent(1)
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
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    NSLog(@"ready to cancel");
    queue.chain_cancelAllOperations();
    NSLog(@"canceled");
  });
  NSLog(@"done");
```

Output

```
**1s**
**done**
**1e**
**2s**
**2e**
**3s**
**ready to cancel**
**canceled**
**3e**
```

### Group

#### use group

Code

```
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
```

Output

```
**1s**
**2**
**3**
**4**
**1e**
**done**
```

#### groupWithPriority

Code

```
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
```

Output

```
**4**
**5**
**2**
**3**
**1**
**done**
```

#### groupCancel

Code

```
**__block** TokenOperationGroup *group = TokenOperationGroup
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
```

Output

```
**1s**
**1e**
**2s**
**2e**
**3s**
**ready to cancel**
**canceled**
**3e**
```