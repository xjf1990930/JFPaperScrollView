//
//  JFPaperScrollerView.h
//  FiveWeiNews
//
//  Created by 五维科技 on 16/8/1.
//  Copyright © 2016年 五维科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+JFPaperView.h"

typedef NS_ENUM(NSInteger, JFPaperScrollDirection) {
    
    PaperScrollForward = 1,//向更大页码滚动
    
    PaperScrollBack,//向更小页码滚动
    
    PaperScrollNoMove,//没有动(页码没有变)
    
};

@protocol JFPaperScrollViewDelegate <NSObject>

@optional
/**
 分页滚动视图停止滚动的下标及方向
 **/
-(void)paperScrollViewDidMoveToPageIndex:(NSUInteger)index andMoveDirection:(JFPaperScrollDirection)moveDirection;

@optional
/**
 分页滚动视图停止滚动的下标及方向(用户手动拖动滚动视图导致的回调)
 **/
-(void)paperScrollViewDidDragEndToPageIndex:(NSUInteger)index andMoveDirection:(JFPaperScrollDirection)moveDirection;

@optional
/**
 分页滚动视图当前的偏移量
 **/
-(void)paperScrollViewCurrentOffset:(CGPoint)offset andDirection:(JFPaperScrollDirection)direc;

@optional
/**
 分页滚动视图当前的偏移量(用户拖动引起)
 **/
-(void)paperScrollViewUserDragCurrentOffset:(CGPoint)offset andDirection:(JFPaperScrollDirection)direc;

@optional
/**
 分页滚动视图已经加载了某个分页视图的回调
 **/
-(void)paperScrollViewDidLoadView:(UIView*)loadedView atIndex:(NSUInteger)index;

@optional
/**
 分页视图已经显示了某个分区视图的回调
 **/
-(void)paperScrollViewDidShowView:(UIView*)showView atIndex:(NSUInteger)index;

@optional
/**
 分页视图滚动回调（比paperScrollViewDidMoveToPageIndex早回调）
 **/
-(void)paperScrollViewDidScroll:(UIScrollView*)scrollView;

@end

@protocol JFPaperScrollViewDataSource <NSObject>

/**
 分页滚动视图不同分页上需要加载的视图对象
 **/
-(UIView*)viewForPaperScrollViewAtIndex:(NSUInteger)index;

/**
 分页滚动视图的页数
 **/
-(NSUInteger)numberOfPaperScrollViewPages;

@end

@interface JFPaperScrollView : UIView

@property (nonatomic, weak) id<JFPaperScrollViewDelegate>delegate;

@property (nonatomic, weak) id<JFPaperScrollViewDataSource>dataSource;

/**
 分页滚动视图最大保持缓存的视图页面数量(默认是0,代表无限制)
 **/
@property (nonatomic, assign) NSUInteger maxCachePage;

/**
 是否支持用户拖动(默认为YES)
 **/
@property (nonatomic, assign) BOOL canDrag;

/**
 滚动的时候是不是以动画形式滚动
 **/
@property (nonatomic, assign) BOOL scrollWithAnimation;

/**
 是否在分页出现之前就加载视图（默认为NO）
 **/
@property (nonatomic, assign) BOOL preloadPageView;

/**
 所有的分页视图
 **/
@property (nonatomic, strong) NSMutableArray*allPageViews;

/**
 重新加载视图
 **/
-(void)reloadView;

/**
 重新加载视图并挪动到某页视图
 **/
-(void)reloadViewAndMoveToViewAtIndex:(NSInteger)targetIndex;

/**
 从第一页开始预加载所有的分页视图(默认是懒加载模式,已考虑最大缓存视图数)
 **/
-(void)preLoadAllViews;

/**
 预加载指定范围内的分页视图(包含range的起始值页)
 **/
-(void)preLoadViewsInRange:(NSRange)range;

/**
 获取分页滚动视图某页的视图对象（超出缓存的视图将会为nill）
 **/
-(UIView*)viewInPaperScrollViewAtIndex:(NSUInteger)index;

/**
 移动到某一个分页
 **/
-(void)scrollToPageAtIndex:(NSUInteger)index;

/**
 创建分页滚动视图
 **/
+(JFPaperScrollView*)createPaperScrollViewWithFrame:(CGRect)frame;

@end
