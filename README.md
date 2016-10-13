# JFPaperScrollView
一个简单的可多页滚动的分页视图，支持路灯队列。

可以应用于单个控制器加载多页视图的场景

视图代理

/**
 分页滚动视图停止滚动的下标及方向
 **/
 
-(void)paperScrollViewDidMoveToPageIndex:(NSUInteger)index andMoveDirection:(JFPaperScrollDirection)moveDirection;

/**
 分页滚动视图停止滚动的下标及方向(用户手动拖动滚动视图导致的回调)
 **/

-(void)paperScrollViewDidDragEndToPageIndex:(NSUInteger)index andMoveDirection:(JFPaperScrollDirection)moveDirection;


/**
 分页滚动视图当前的偏移量
 **/
-(void)paperScrollViewCurrentOffset:(CGPoint)offset andDirection:(JFPaperScrollDirection)direc;


/**
 分页滚动视图当前的偏移量(用户拖动引起)
 **/
-(void)paperScrollViewUserDragCurrentOffset:(CGPoint)offset andDirection:(JFPaperScrollDirection)direc;


/**
 分页滚动视图已经加载了某个分页视图的回调
 **/
-(void)paperScrollViewDidLoadView:(UIView*)loadedView atIndex:(NSUInteger)index;


/**
 分页视图已经显示了某个分区视图的回调
 **/
-(void)paperScrollViewDidShowView:(UIView*)showView atIndex:(NSUInteger)index;


/**
 分页视图滚动回调（比paperScrollViewDidMoveToPageIndex早回调）
 **/
-(void)paperScrollViewDidScroll:(UIScrollView*)scrollView;

数据源代理

/**
 分页滚动视图不同分页上需要加载的视图对象
 **/
-(UIView*)viewForPaperScrollViewAtIndex:(NSUInteger)index;

/**
 分页滚动视图的页数
 **/
-(NSUInteger)numberOfPaperScrollViewPages;
