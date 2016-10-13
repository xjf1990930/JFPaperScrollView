//
//  UIView+JFPaperView.m
//  FiveWeiNews
//
//  Created by 五维科技 on 16/8/1.
//  Copyright © 2016年 五维科技. All rights reserved.
//

#import "UIView+JFPaperView.h"
#import <objc/runtime.h>

@implementation UIView (JFPaperView)

-(NSInteger)paperIndex
{
    
    return [objc_getAssociatedObject(self, @selector(paperIndex)) integerValue];
    
}
-(void)setPaperIndex:(NSInteger)paperIndex
{
    
    objc_setAssociatedObject(self, @selector(paperIndex), @(paperIndex), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}

@end
