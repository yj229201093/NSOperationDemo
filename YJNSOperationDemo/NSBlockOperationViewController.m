//
//  NSBlockOperationViewController.m
//  YJNSOperationDemo
//
//  Created by GongHui_YJ on 16/8/22.
//  Copyright © 2016年 YangJian. All rights reserved.
//

#import "NSBlockOperationViewController.h"
#import "ImageData.h"

#define ROW_COUNT 5
#define COLUMN_COUNT 3
#define ROW_HEIGHT 100
#define ROW_WIDTH ROW_HEIGHT
#define CELL_SPACING 10
#define IMAGE_COUNT 15

@interface NSBlockOperationViewController (){
    NSMutableArray *_imageViews;
    NSMutableArray *_imageNames;
}
@end

@implementation NSBlockOperationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self layoutUI];
    self.view.backgroundColor = [UIColor lightGrayColor];
}

/**
 *  UI
 */
- (void)layoutUI {
    //创建多个图片控件用于显示图片
    _imageViews=[NSMutableArray array];
    for (int r=0; r<ROW_COUNT; r++) {
        for (int c=0; c<COLUMN_COUNT; c++) {
            UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(c*ROW_WIDTH+(c*CELL_SPACING), r*ROW_HEIGHT+(r*CELL_SPACING                           ), ROW_WIDTH, ROW_HEIGHT)];
            imageView.contentMode=UIViewContentModeScaleAspectFit;
            //            imageView.backgroundColor=[UIColor redColor];
            [self.view addSubview:imageView];
            [_imageViews addObject:imageView];

        }
    }

    UIButton *button=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame=CGRectMake(50, 500, 220, 25);
    [button setTitle:@"加载图片" forState:UIControlStateNormal];
    //添加方法
    [button addTarget:self action:@selector(loadImageWithMultiThread) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];

    //创建图片链接
    _imageNames=[NSMutableArray array];
    for (int i=0; i<IMAGE_COUNT; i++) {
        [_imageNames addObject:@"http://h.hiphotos.baidu.com/image/h%3D200/sign=fc55a740f303918fc8d13aca613c264b/9213b07eca80653893a554b393dda144ac3482c7.jpg"];
    }
}

- (void)updateImageWithData:(NSData *)data andIndex:(int)index {
    UIImage *image = [UIImage imageWithData:data];
    UIImageView *imageView = _imageViews[index];
    imageView.image = image;
}

/**
 *  请求图片数据
 *
 *  @param index
 */
- (NSData *)requestData:(int)index {
    NSURL *url = [NSURL URLWithString:_imageNames[index]];
    NSData *data = [NSData dataWithContentsOfURL:url];
    return data;
}

/**
 *  加载图片
 *
 *  @param index
 */
- (void)loadImage:(NSNumber *)index {
    int i = [index intValue];

    // 请求数据
    NSData *data = [self requestData:i];
//    NSLog(@"%@", [NSThread currentThread]);

    // 更新UI界面 此处调用了主线程队列的方法（mainQueue是UI主线程）
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self updateImageWithData:data andIndex:i];
    }];

}


/**
 *  多线程下载图片
 */
- (void)loadImageWithMultiThread {
    int count = ROW_COUNT * COLUMN_COUNT;

    // 创建操作队列
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    operationQueue.maxConcurrentOperationCount = 5; //设置最大并发线程数

    // 创建多个线程用于填充图片
    for (int i = 0; i < count; i++) {
//        // 方法一 创建操作块添加到队列
//        // 创建多线程操作
//        NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
//            [self loadImage:[NSNumber numberWithInt:i]];
//        }];
//
//        // 创建操作队列
//        [operationQueue addOperation:blockOperation];

        // 方法二 直接使用操作队列添加操作
        [operationQueue addOperationWithBlock:^{
            [self loadImage:[NSNumber numberWithInt:i]];
        }];
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
