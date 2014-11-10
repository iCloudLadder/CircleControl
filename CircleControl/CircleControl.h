//
//  CircleControl.h
//  CircleControl
//
//  Created by syweic on 14/11/5.
//  Copyright (c) 2014年 ___iSoftStone___. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CircleControlAnimationStyle) {
    CircleControlAnimationStyleDefault = 0,
    CircleControlAnimationStyleCircle = 0,
    CircleControlAnimationStyleLine,
    CircleControlAnimationStyleScale
};

@protocol  CircleControlDelegate;

@interface CircleControl : UIView

// 点击 最下方 按钮 相应选中 视图
@property (nonatomic, assign) id<CircleControlDelegate>delegate;

// 圆的半径 默认 自身短边 的 0.8
@property (nonatomic ,assign) CGFloat redius;
// 选择 视图的个数 默认 6
@property (nonatomic ,assign) int count;
// 选择 视图的 背景图
@property (nonatomic ,assign) NSArray *imageNames;
// 动画 的 风格 ,默认 CircleControlAnimationStyleCircle
@property (nonatomic ,assign) CircleControlAnimationStyle animationStyle;
// 动画 的时间 默认 1.0秒
@property (nonatomic ,assign) CFTimeInterval duration;

// 添加 滑动手势 默认 YES(添加)
@property (nonatomic ,assign) BOOL isAddSwipeGestureRecognizer;

-(instancetype)initWithFrame:(CGRect)frame redius:(CGFloat)redius count:(int)count buttonSize:(CGSize)size;

@end

@protocol CircleControlDelegate <NSObject>

-(void)selectedFinished:(NSInteger)selectedIndex;

@end
