//
//  JFPaperScrollerView.m
//  FiveWeiNews
//
//  Created by 五维科技 on 16/8/1.
//  Copyright © 2016年 五维科技. All rights reserved.
//

#import "JFPaperScrollView.h"
#import "UIView+JFPaperView.h"

@interface JFPaperScrollView ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView*mainScrollView;//主滚动视图

@property (nonatomic, assign) CGPoint lastOffet;//滚动视图上一次的偏移量(停止状态的)

@property (nonatomic, assign) CGPoint dragLastOffset;//滚动视图被拖动结束后的上一次偏移量

@property (nonatomic, assign) NSInteger lastPage;//上一次停留的页码

@property (nonatomic, assign) JFPaperScrollDirection currentScrollDirection;//当前分页视图的滚动方向

@property (nonatomic, assign) CGPoint scrollViewLastOffset;//滚动视图实时滚动纪录的上一次偏移量

@property (nonatomic, assign) BOOL isDragingMode;//是否为用户拖动模式

@end

#define pPaperScrollAnimationTime 0.3

@implementation JFPaperScrollView

+(JFPaperScrollView*)createPaperScrollViewWithFrame:(CGRect)frame
{
    
    JFPaperScrollView*paperScrollView = [[JFPaperScrollView alloc] initWithFrame:frame];
    
    paperScrollView.canDrag = YES;
    
    paperScrollView.lastOffet = paperScrollView.mainScrollView.contentOffset;
    
    paperScrollView.dragLastOffset = paperScrollView.mainScrollView.contentOffset;
    
    paperScrollView.currentScrollDirection = PaperScrollNoMove;
    
    paperScrollView.scrollViewLastOffset = CGPointMake(0, 0);
    
    [paperScrollView addSubview: paperScrollView.mainScrollView];
    
    paperScrollView.mainScrollView.showsHorizontalScrollIndicator = NO;
    
    paperScrollView.mainScrollView.showsVerticalScrollIndicator = NO;
    
    paperScrollView.mainScrollView.scrollsToTop = NO;
    
    return paperScrollView;
    
}
-(void)scrollToPageAtIndex:(NSUInteger)index
{
    
    if (index == 0) {
        
        [self loadPaperViewAtIndex:index andCleanCache:YES];
        
    }
    
    if ([self.dataSource respondsToSelector:@selector(numberOfPaperScrollViewPages)]) {
        
        if (index>=[self.dataSource numberOfPaperScrollViewPages]) {
            
            NSLog(@"%@ : 分页视图所要滚动到的偏移量超出预设范围!。",NSStringFromClass([JFPaperScrollView class]));
            
        }
        
    }else{
        
        NSLog(@"%@ : 请设置数据源代理方！",NSStringFromClass([JFPaperScrollView class]));
        
    }
    
    [self.mainScrollView setContentOffset:CGPointMake(index*1.0*self.bounds.size.width, 0) animated:self.scrollWithAnimation];
    
}
-(UIView*)viewInPaperScrollViewAtIndex:(NSUInteger)index
{
    
    UIView*resultView = nil;
    
    for (UIView*subView in self.allPageViews) {
        
        if (subView.paperIndex == index) {
            
            resultView = subView;
            
            break;
            
        }
        
    }
    
    return resultView;
    
}
-(void)reloadView
{
    
    for (UIView*subView in self.allPageViews) {
        
        [subView removeFromSuperview];
        
    }
    
    [self.allPageViews removeAllObjects];
    
    self.allPageViews = nil;
    
    NSInteger index = (NSInteger)self.mainScrollView.contentOffset.x/self.bounds.size.width;
    
    if (index<0) {
        
        index = 0;
        
    }
    
    NSInteger maxLoadPageNumbers = 0;
    
    if ([self.dataSource respondsToSelector:@selector(numberOfPaperScrollViewPages)]) {
        
        maxLoadPageNumbers = [self.dataSource numberOfPaperScrollViewPages];
        
    }else{
        
        NSLog(@"%@ : 请设置数据源代理方！",NSStringFromClass([JFPaperScrollView class]));
        
        return;
        
    }
    
    //重置滚动视图的容量
    self.mainScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bounds)*maxLoadPageNumbers, 0);
    
    [self loadPaperViewAtIndex:index andCleanCache:YES];
    
}
-(void)reloadViewAndMoveToViewAtIndex:(NSInteger)targetIndex
{
    
    for (UIView*subView in self.allPageViews) {
        
        [subView removeFromSuperview];
        
    }
    
    [self.allPageViews removeAllObjects];
    
    self.allPageViews = nil;
    
    NSInteger maxLoadPageNumbers = 0;
    
    if ([self.dataSource respondsToSelector:@selector(numberOfPaperScrollViewPages)]) {
        
        maxLoadPageNumbers = [self.dataSource numberOfPaperScrollViewPages];
        
    }else{
        
        NSLog(@"%@ : 请设置数据源代理方！",NSStringFromClass([JFPaperScrollView class]));
        
        return;
        
    }
    
    //重置滚动视图的容量
    self.mainScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bounds)*maxLoadPageNumbers, 0);
    
    [self scrollToPageAtIndex:targetIndex];
    
    [self loadPaperViewAtIndex:targetIndex andCleanCache:YES];
    
}
-(void)preLoadAllViews
{
    
    NSInteger maxLoadPageNumbers = 0;
    
    if ([self.dataSource respondsToSelector:@selector(numberOfPaperScrollViewPages)]) {
        
        maxLoadPageNumbers = [self.dataSource numberOfPaperScrollViewPages];
        
    }else{
        
        NSLog(@"%@ : 请设置数据源代理方！",NSStringFromClass([JFPaperScrollView class]));
        
        return;
        
    }
    
    if (maxLoadPageNumbers<=0) {
        
        NSLog(@"%@ : 页码数必须设置大于0的数!",NSStringFromClass([JFPaperScrollView class]));
        
        return;
        
    }
    
    for (UIView*subView in self.allPageViews) {
        
        [subView removeFromSuperview];
        
    }
    
    self.allPageViews = nil;
    
    //重置滚动视图的容量
    self.mainScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bounds)*maxLoadPageNumbers, 0);
    
    //这里需要考虑设置的缓存数量
    if (self.maxCachePage>0 && self.maxCachePage>maxLoadPageNumbers) {
        
        for (NSInteger i = 0; i<maxLoadPageNumbers; i++) {
            
            [self loadPaperViewAtIndex:i andCleanCache:YES];
            
        }
        
    }else if (self.maxCachePage>0 && self.maxCachePage<=maxLoadPageNumbers){
        
        for (NSInteger i = 0; i<self.maxCachePage; i++) {
            
            [self loadPaperViewAtIndex:i andCleanCache:YES];
            
        }
        
    }else if (self.maxCachePage<=0){
        
        for (NSInteger i = 0; i<maxLoadPageNumbers; i++) {
            
            [self loadPaperViewAtIndex:i andCleanCache:YES];
            
        }
        
    }
    
}
-(void)preLoadViewsInRange:(NSRange)range
{
    
    NSInteger maxLoadPageNumbers = 0;
    
    if ([self.dataSource respondsToSelector:@selector(numberOfPaperScrollViewPages)]) {
        
        maxLoadPageNumbers = [self.dataSource numberOfPaperScrollViewPages];
        
    }else{
        
        NSLog(@"%@ : 请设置数据源代理方！",NSStringFromClass([JFPaperScrollView class]));
        
        return;
        
    }
    
    for (UIView*subView in self.allPageViews) {
        
        [subView removeFromSuperview];
        
    }
    
    self.allPageViews = nil;
    
    //重置滚动视图的容量
    self.mainScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bounds)*maxLoadPageNumbers, 0);
    
    NSRange resultRange = range;
    
    if (self.maxCachePage) {
        
        if (resultRange.length>self.maxCachePage) {
            
            resultRange.length = self.maxCachePage;
            
        }
        
    }
    
    for (NSInteger i = resultRange.location; i<resultRange.location + resultRange.length; i++) {
        
        [self loadPaperViewAtIndex:i andCleanCache:YES];
        
    }
    
}
-(void)loadPaperViewAtIndex:(NSUInteger)index andCleanCache:(BOOL)needClean
{
    
    if (![self.dataSource numberOfPaperScrollViewPages]) {
        
        return;
        
    }
    
    if ([self.dataSource respondsToSelector:@selector(viewForPaperScrollViewAtIndex:)]) {
        
        //验证该位置的视图是否加载过
        BOOL hasLoadedView = NO;
        
        UIView*loadedView = nil;
        
        for (UIView*loadedPageView in self.allPageViews) {
            
            if (loadedPageView.paperIndex == index) {
                
                hasLoadedView = YES;
                
                loadedView = loadedPageView;
                
                break;
                
            }
            
        }
        
        if (!hasLoadedView) {
            
            //未曾加载，就将该视图添加到滚动视图上
            UIView*pageView = [self.dataSource viewForPaperScrollViewAtIndex:index];
            
            pageView.paperIndex = index;
            
            CGRect frame = pageView.frame;
            
            frame.origin.x = index*self.bounds.size.width;
            
            pageView.frame = frame;
            
            [self.mainScrollView addSubview:pageView];
            
            [self.allPageViews addObject:pageView];
            
            if ([self.delegate respondsToSelector:@selector(paperScrollViewDidLoadView:atIndex:)]) {
                
                [self.delegate paperScrollViewDidLoadView:pageView atIndex:pageView.paperIndex];
                
            }
            
            loadedView = pageView;
            
        }
        
        //回调已经加载分页视图及页码下标
        if ([self.delegate respondsToSelector:@selector(paperScrollViewDidShowView:atIndex:)]) {
            
            [self.delegate paperScrollViewDidShowView:loadedView atIndex:index];
            
        }
        
        //再来进行视图队列操作（依照缓存的视图量来判定移除哪一个分页滚动视图上的视图）
        //小于等于0表示无限制，默认为0
        if (self.maxCachePage>0) {
            
            //不一定每次加载分页视图都清除缓存，看用户设置（要预先加载的情况下，缓存暂时不清除）
            if (self.allPageViews.count>self.maxCachePage && needClean) {
                
                //向前滚动时
                if (self.currentScrollDirection == PaperScrollForward) {
                    
                    //找到页码最小的那个分页视图
                    NSInteger minIndex = index;
                    
                    for (UIView*subView in self.allPageViews) {
                        
                        if (subView.paperIndex<minIndex) {
                            
                            minIndex = subView.paperIndex;
                            
                        }
                        
                    }
                    
                    //找到之后移除这个视图
                    for (UIView*subView in self.allPageViews) {
                        
                        if (subView.paperIndex == minIndex) {
                            
                            [subView removeFromSuperview];
                            
                            [self.allPageViews removeObject:subView];
                            
                            break;
                            
                        }
                        
                    }
                    
                    //向后滚动时（不滚动就不需要做释放操作）
                }else if (self.currentScrollDirection == PaperScrollBack){
                    
                    
                    //找到页码最大的那个分页视图
                    NSInteger maxIndex = index;
                    
                    for (UIView*subView in self.allPageViews) {
                        
                        if (subView.paperIndex>maxIndex) {
                            
                            maxIndex = subView.paperIndex;
                            
                        }
                        
                    }
                    
                    //找到之后移除这个视图
                    for (UIView*subView in self.allPageViews) {
                        
                        if (subView.paperIndex == maxIndex) {
                            
                            [subView removeFromSuperview];
                            
                            [self.allPageViews removeObject:subView];
                            
                            break;
                            
                        }
                        
                    }
                    
                }else{
                    
                    
                    
                }
                
            }
            
        }
        
    }
    
}
#pragma mark ---- scrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    if ([self.delegate respondsToSelector:@selector(paperScrollViewDidScroll:)]) {
        
        [self.delegate paperScrollViewDidScroll:scrollView];
        
    }
    
    if (scrollView == self.mainScrollView) {
        
        NSInteger index = (NSInteger)scrollView.contentOffset.x/self.bounds.size.width;
        
        if (index<0) {
            
            index = 0;
            
        }
        
        //根据页码来回调页码的跳转信息//
        if (scrollView.contentOffset.x == index*self.bounds.size.width) {
            
            //回调页码数
            if ([self.delegate respondsToSelector:@selector(paperScrollViewDidMoveToPageIndex:andMoveDirection:)]) {
                
                //计算方向(此为按照上次停留的偏移量来判断的滚动方向,就是抵达当前页是如何滚动过来的)
                JFPaperScrollDirection direc;
                
                if (self.lastOffet.x<scrollView.contentOffset.x) {
                    
                    direc = PaperScrollForward;
                    
                }else if (self.lastOffet.x>scrollView.contentOffset.x){
                    
                    direc = PaperScrollBack;
                    
                }else{
                    
                    direc = PaperScrollNoMove;
                    
                }
                
                //重置纪录的上次偏移量
                self.lastOffet = scrollView.contentOffset;
                
                self.currentScrollDirection = direc;
                
                [self.delegate paperScrollViewDidMoveToPageIndex:index andMoveDirection:direc];
                
            }
            
            self.lastPage = index;
            
            //显示分页视图//
            [self loadPaperViewAtIndex:index andCleanCache:YES];
            
        }
        
        //仅表示滚动视图的滚动方向（实时）
        JFPaperScrollDirection scrollDirection;
        
        if (self.scrollViewLastOffset.x>scrollView.contentOffset.x) {
            
            scrollDirection = PaperScrollBack;
            
            //向后翻页，如果需要预先加载出视图，那么加载第index页就行
            if (self.preloadPageView) {
                
                [self loadPaperViewAtIndex:index andCleanCache:NO];
                
            }
            
        }else if (self.scrollViewLastOffset.x<scrollView.contentOffset.x){
            
            scrollDirection = PaperScrollForward;
            
            //向前翻页，如果需要预先加载出视图，那么加载第index＋1页(判断是否越界先)
            if (self.preloadPageView) {
                
                if (index+1<[self.dataSource numberOfPaperScrollViewPages]) {
                    
                     [self loadPaperViewAtIndex:index+1 andCleanCache:NO];
                    
                }
                
            }
            
        }else{
            
            scrollDirection = PaperScrollNoMove;
            
        }
        
        self.scrollViewLastOffset = scrollView.contentOffset;
        
        
        //回调滚动视图的滚动信息//
        if ([self.delegate respondsToSelector:@selector(paperScrollViewCurrentOffset:andDirection:)]) {
            
            [self.delegate paperScrollViewCurrentOffset:scrollView.contentOffset andDirection:scrollDirection];
            
        }
        
        //用户拖动模式下回调拖动状态//
        if (self.isDragingMode) {
            
            //确定滚动方向（根据上次停留的页码下标来判断的滚动方向）
            JFPaperScrollDirection resultDirec;
            
            if (scrollView.contentOffset.x>self.lastPage*self.bounds.size.width) {
                
                resultDirec = PaperScrollForward;
                
            }else if (scrollView.contentOffset.x<self.lastPage*self.bounds.size.width){
                
                resultDirec = PaperScrollBack;
                
            }else{
                
                resultDirec = PaperScrollNoMove;
                
            }
            
            if ([self.delegate respondsToSelector:@selector(paperScrollViewUserDragCurrentOffset:andDirection:)]) {
                
                [self.delegate paperScrollViewUserDragCurrentOffset:scrollView.contentOffset andDirection:resultDirec];
                
            }
            
        }
        
    }
    
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    
    self.isDragingMode = YES;
    
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    if (self.isDragingMode) {
        
        self.isDragingMode = NO;
        
    }
    
    if (scrollView == self.mainScrollView) {
        
        NSInteger index = (NSInteger)scrollView.contentOffset.x/self.bounds.size.width;
        
        if (index<0) {
            
            index = 0;
            
        }
        
        //回调页码数
        if ([self.delegate respondsToSelector:@selector(paperScrollViewDidDragEndToPageIndex:andMoveDirection:)]) {
            
            //计算方向
            JFPaperScrollDirection direc;
            
            if (self.dragLastOffset.x<scrollView.contentOffset.x) {
                
                direc = PaperScrollForward;
                
            }else if (self.dragLastOffset.x>scrollView.contentOffset.x){
                
                direc = PaperScrollBack;
                
            }else{
                
                direc = PaperScrollNoMove;
                
            }
            
            //重置纪录的上次惯性结束时的偏移量
            self.dragLastOffset = scrollView.contentOffset;
            
            [self.delegate paperScrollViewDidDragEndToPageIndex:index andMoveDirection:direc];
            
        }
        
    }
    
}
#pragma mark ---- setter

-(void)setDelegate:(id<JFPaperScrollViewDelegate>)delegate
{
    
    _delegate = delegate;
    
}
-(void)setDataSource:(id<JFPaperScrollViewDataSource>)dataSource
{
    
    
    
    _dataSource = dataSource;
    
    if ([_dataSource respondsToSelector:@selector(numberOfPaperScrollViewPages)]) {
        
        self.mainScrollView.contentSize = CGSizeMake([_dataSource numberOfPaperScrollViewPages]*self.bounds.size.width, 0);
        
    }else{
        
        NSLog(@"%@ : 请设置数据源代理方！",NSStringFromClass([JFPaperScrollView class]));
        
    }
    
}
#pragma mark ---- getter

-(UIScrollView*)mainScrollView
{
    
    if (!_mainScrollView) {
        
        _mainScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        
        _mainScrollView.delegate = self;
        
        _mainScrollView.pagingEnabled = YES;
        
        _mainScrollView.bounces = NO;
        
    }
    
    return _mainScrollView;
    
}
-(NSMutableArray*)allPageViews
{
    
    if (!_allPageViews) {
        
        _allPageViews = [NSMutableArray new];
        
    }
    
    return _allPageViews;
    
}
#pragma mark ---- getter
-(void)setCanDrag:(BOOL)canDrag
{
    
    _canDrag = canDrag;
    
    self.mainScrollView.scrollEnabled = _canDrag;
    
}
@end
