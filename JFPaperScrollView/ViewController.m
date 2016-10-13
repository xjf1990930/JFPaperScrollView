//
//  ViewController.m
//  JFPaperScrollView
//
//  Created by 五维科技 on 16/10/13.
//  Copyright © 2016年 JF. All rights reserved.
//

#import "ViewController.h"
#import "JFPaperScrollView.h"

@interface ViewController ()<JFPaperScrollViewDataSource,JFPaperScrollViewDelegate>

@property (nonatomic, strong)JFPaperScrollView*paperScrollView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.view addSubview:self.paperScrollView];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark ---- JFPaperScrollViewDataSource
-(UIView*)viewForPaperScrollViewAtIndex:(NSUInteger)index
{
    
    UIView*testView = [[UIView alloc]initWithFrame:self.view.bounds];

    testView.backgroundColor = [UIColor colorWithRed:(arc4random()%255*1.0)/255.0 green:(arc4random()%255*1.0)/255.0 blue:(arc4random()%255*1.0)/255.0 alpha:1];
    
    return testView;
    
}
-(NSUInteger)numberOfPaperScrollViewPages
{
    
    return 10;
    
}
#pragma mark ---- JFPaperScrollViewDelegate
-(void)paperScrollViewDidScroll:(UIScrollView *)scrollView
{
    
    
    
}
-(void)paperScrollViewCurrentOffset:(CGPoint)offset andDirection:(JFPaperScrollDirection)direc
{
    
    
}
-(void)paperScrollViewUserDragCurrentOffset:(CGPoint)offset andDirection:(JFPaperScrollDirection)direc
{
    
    
    
}
-(void)paperScrollViewDidMoveToPageIndex:(NSUInteger)index andMoveDirection:(JFPaperScrollDirection)moveDirection
{
    
    NSLog(@"移动到的页码：%@,方向：%@",@(index),@(moveDirection));
    
}
-(void)paperScrollViewDidDragEndToPageIndex:(NSUInteger)index andMoveDirection:(JFPaperScrollDirection)moveDirection
{
    
    NSLog(@"用户拖动后停留的页码：%@,方向：%@",@(index),@(moveDirection));
    
}
-(void)paperScrollViewDidShowView:(UIView *)showView atIndex:(NSUInteger)index
{
    
    
    
}
#pragma mark ---- getter

-(JFPaperScrollView*)paperScrollView
{
    
    if (!_paperScrollView) {
        
        _paperScrollView = [JFPaperScrollView createPaperScrollViewWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
        
        _paperScrollView.delegate = self;
        
        _paperScrollView.dataSource = self;
        
        _paperScrollView.canDrag = YES;
        
        _paperScrollView.maxCachePage = 2;
        
        _paperScrollView.preloadPageView = YES;
        
        [_paperScrollView scrollToPageAtIndex:0];
        
    }
    
    return _paperScrollView;
    
}
@end
