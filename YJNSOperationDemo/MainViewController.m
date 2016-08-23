//
//  MainViewController.m
//  YJNSOperationDemo
//
//  Created by GongHui_YJ on 16/8/22.
//  Copyright © 2016年 YangJian. All rights reserved.
//

#import "MainViewController.h"
#import "NSInvocationOperationViewController.h"
#import "NSBlockOperationViewController.h"
#import "NSOperationQueueViewController.h"

/**
    demo 类 说明
    NSInvocationOperationViewController: NSOperation 的子类 NSInvocationOperation 线程的基本使用
    NSBlockOperationViewController: NSOperation 的子类 NSBlockOperation 线程的基本使用
    NSOperationQueueViewController: 线程的依赖关系

    一、NSOperation

        1、NSOperation比NSThread用起来方便许多，也更多的满足了我们的需求。
    
        2、NSOpertion 与 NSOperationQueue 结合使用; NSOperationQueue 相当于一个管理器， 来管理线程操作，只要将一个NSOperation（实际开发中需要使用其子类 NSInvocationOperation、NSBlockOperation）放到NSOperationQueue这个队列中线程就会依次启动，NSOperationQueue负责管理、执行所有的NSOperation，在这个过程中可以更加容易的管理线程总数和控制线程之间的依赖关系。

        3、NSOperation是一个抽象类，有两个常用子类用于创建线程操作：NSInvocationOperation 和 NSBlockOperation 两种方式本质没有区别，但是后者使用Block形式进行代码组织，使用对象方便。

        4、NSOperation对象可以通过调用start方法来执行任务，默认是同步执行的。也可以将NSOperation添加到一个NSOperationQueue(操作队列)中执行，系统会自动异步执行NSOperation中的操作。添加操作到NSOperationQueue中，自动执行操作，自动开启线程。

    二、NSInvocationOperation
        1、简介：基于一个对象和selector来创建操作。如果你已经有现有的方法来执行需要的任务，就可以使用这个类
        2、创建并行操作
            // 方法一  这个操作是：调用self的loadImage方法  创建完NSInvocationOperation对象并不会调用，它由一个start方法启动操作，但是注意如果调用start方法,则此操作会在主线程中调用，一般不会这么操作，而是添加到NSOperationQueue中
            NSInvocationOperation *invocationOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadImage) object:nil];
            // 开始执行任务（同步执行）
            [operation start];
 
            // 方法二 创建操作队列，更新UI需要在主线程更新
            // 创建操作队列
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            // 把线程添加到操作队列
            [queque addOperation:invocationOperation]
            
            // 更新UI需要回到主线程 （mainQueue是UI主线程）
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                NSLog(@"执行了一个线程 --- %@", [NSThread currentThread]);
                // 更新UI
            }];

    三、NSBlockOperation
        1、能够并发地执行一个或多个block对象，所有相关的block都执行完之后，操作才算完成
        2、创建并行操作
            // 方法一 直接使用NSBlockOperation创建线程
            NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^(){
                NSLog(@"执行了一个线程 --- %@", [NSThread currentThread]);
            }];
            // 开始执行任务（这里还是同步执行）
            [blockOperation start];
 
            // 方法二 创建操作队列
            NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
              
            // 创建
            NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^(){
                NSLog(@"执行了一个线程 --- %@", [NSThread currentThread]);
            }];
            // 将线程添加到队列
            [operationQueue addOperation:blockOperation];
            
            // 更新UI需要回到主线程 （mainQueue是UI主线程）
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                NSLog(@"执行了一个线程 --- %@", [NSThread currentThread]);
                // 更新UI
            }];

        3、  通过addExecutionBlock方法添加block操作
            NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^(){
                NSLog(@"执行第1次操作，线程：%@", [NSThread currentThread]);
            }];
            
            [operation addExecutionBlock:^(){
                NSLog(@"又执行第1次操作，线程：%@", [NSThread currentThread]);
            }];
 
            [operation addExecutionBlock:^(){
                NSLog(@"又执行第1次操作，线程：%@", [NSThread currentThread]);
            }];
        
            [operation addExecutionBlock:^(){
                NSLog(@"又执行第1次操作，线程：%@", [NSThread currentThread]);
            }];

            // 开始执行任务
            [operation start];

    四、依赖关系 addDependency
        使用NSThread很难控制线程的执行顺序，但是使用NSOperation就容易多了，每个NSOperation可以设置依赖线程。假设操作A依赖于操作B，线程操作队列在启动线程时就会首先执行B操作，然后执行A。
        // 创建操作队列
        NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
        operationQueue.maxConcurrentOperationCount = 5; //设置最大并发线程数

        // 创建操作线程
        NSBlockOperation *lastBlockOperation = [NSBlockOperation blockOperationWithBlock:^{
            [self loadImage:[NSNumber numberWithInt:(count - 1)]];
            NSLog(@"lastBlockOperation111111当前线程是： %@", [NSThread currentThread]);
        }];

        // 创建操作线程
        NSBlockOperation *beginBlockOperation = [NSBlockOperation blockOperationWithBlock:^{
            NSLog(@"beginBlockOperation22222当前线程是： %@", [NSThread currentThread]);
            [self loadImage:[NSNumber numberWithBool:0]];
        }];

        // 设置依赖 lastBlockOperation 依赖于 beginBlockOperation 先执行 beginBlockOperation 在执行 lastBlockOperation
        [lastBlockOperation addDependency:beginBlockOperation];

        for (int i = 1; i < count - 1; i++) {
            // 方法一 创建操作块添加队列
            // 创建多线程操作
            NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
                NSLog(@"blockOperation当前线程是： %@", [NSThread currentThread]);
                [self loadImage:[NSNumber numberWithInt:i]];
            }];

            // 设置依赖操作作为最后一张图片加载操作 blockOperation 依赖于 lastBlockOperation 先执行lastBlockOperation 在支持  blockOperation
            [blockOperation addDependency:lastBlockOperation];

            // 将线程加入队列
            [operationQueue addOperation:blockOperation];
        }

        // 讲最后一个图片的加载操作加入线程队列
        [operationQueue addOperation:lastBlockOperation];
        [operationQueue addOperation:beginBlockOperation];
 
        看依赖demo打印的线程日志
 
        注：但这边注意的是：不能创建循环依赖，比如A依赖B，B依赖A，这是错误的。

    五、总结
        使用NSOperation用起来比NSThread舒服多了，也对多线程有进一步的了解，NSOperation强大的还可以自定义， 只要继承NSOperation 然后重写几个方法几个。



 */

@interface MainViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"Cell";
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellId];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];

    if (indexPath.row == 0) {
        cell.textLabel.text = @"NSInvocationOperation";
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"NSBlockOperation";
    } else {
        cell.textLabel.text = @"线程依赖";
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        NSInvocationOperationViewController *vc = [[NSInvocationOperationViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];

    } else if (indexPath.row == 1) {
        NSBlockOperationViewController *vc = [[NSBlockOperationViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        NSOperationQueueViewController *vc = [[NSOperationQueueViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
