//
//  NSInvocationOperationViewController.m
//  YJNSOperationDemo
//
//  Created by GongHui_YJ on 16/8/22.
//  Copyright © 2016年 YangJian. All rights reserved.
//

#import "NSInvocationOperationViewController.h"

@interface NSInvocationOperationViewController ()
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIImageView *imageView1;
@end

@implementation NSInvocationOperationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self layoutUI];
    self.view.backgroundColor = [UIColor lightGrayColor];
}

/**
 *  UI
 */
- (void)layoutUI {
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 50, 200, 200)];
    [self.view addSubview:_imageView];

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(10, _imageView.frame.origin.y + _imageView.frame.size.height + 20, 80, 44);
    [button setTitle:@"下载图片" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(loadImageWithMultiInvocationOperation) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];

    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    button1.frame = CGRectMake(button.frame.origin.x + button.frame.size.width + 20, _imageView.frame.origin.y + _imageView.frame.size.height + 20, 80, 44);
    [button1 setTitle:@"下载图片1" forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(loadImageWithMultiInvocationOperation1) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button1];

    self.imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(10, button.frame.origin.y + button.frame.size.height + 20, 200, 200)];
    [self.view addSubview:_imageView1];
}

/**
 *  更新UI
 *
 *  @param data data
 */
- (void)updateImage:(NSData *)data {
    UIImage *image = [UIImage imageWithData:data];
    self.imageView.image = image;
}

/**
 *  图片请求
 */
- (NSData *)requestData{
    NSURL *url = [NSURL URLWithString:@"http://h.hiphotos.baidu.com/image/h%3D200/sign=fc55a740f303918fc8d13aca613c264b/9213b07eca80653893a554b393dda144ac3482c7.jpg"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    return data;
}


/**
 *  创建线程
 */
- (void)loadImageWithMultiInvocationOperation {
    // 创建一个调用操作
    // object 调用方法参数
    NSInvocationOperation *invocationOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadImage:) object:nil];
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    [operationQueue addOperation:invocationOperation];
//    [invocationOperation start];
}


/**
 *  执行线程操作
 *
 *  @param sender
 */
- (void)loadImage:(NSInvocationOperation *)sender{
    NSLog(@"sender - %@", sender);

    // 此段代码没有任何意义， 为了体现多线程的意义
    for (int i = 0; i < 10000; i++) {
        NSLog(@"==== - %i", i);
    }

    NSLog(@"NSInvocationOperation---1 --- %@", [NSThread currentThread]);
    NSData *data = [self requestData];

    // 调用主线程更新UI
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self updateImage:data];
        NSLog(@"NSInvocationOperation---2000 --- %@", [NSThread currentThread]);
    }];

    
}

/**
 *  创建线程1
 */
- (void)loadImageWithMultiInvocationOperation1 {
    NSInvocationOperation *invocationOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadImage) object:nil];
    // 创建完NSInvocationOperation对象并不会调用，它由一个start方法启动操作，但是注意如果调用start方法,则此操作会在主线程中调用，一般不会这么操作，而是添加到NSOperationQueue中
//    [invocationOperation start];
    // 创建操作队列
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    // 注意添加到操作队列后，队列会开启一个线程执行此操作
    [operationQueue addOperation:invocationOperation];

}

/**
 *  执行线程操作
 */
- (void)loadImage {
    NSLog(@"NSInvocationOperation---2 --- %@", [NSThread currentThread]);
    NSData *data = [self requestData];


    // 更新UI界面 调用主线程队列的方法（mainQueue是UI主线程）
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSLog(@"NSInvocationOperation---2111 --- %@", [NSThread currentThread]);
        [self updateImage1:data];
    }];

}


/**
 *  更新UI
 *
 *  @param data data
 */
- (void)updateImage1:(NSData *)data {
    UIImage *image = [UIImage imageWithData:data];
    self.imageView1.image = image;
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
