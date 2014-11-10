//
//  CircleControl.m
//  CircleControl
//
//  Created by syweic on 14/11/5.
//  Copyright (c) 2014年 ___iSoftStone___. All rights reserved.
//

#import "CircleControl.h"

#define kBasePi (M_PI_2)
// 默认
#define kDefaultCount 6
#define kDefaultControlWidth 100.0

#define kDefaultDuration 1

#define kMinLength(frame) MIN(CGRectGetHeight(frame), CGRectGetWidth(frame))
// 计算半径的 除数
#define kDivisor 2.5

#define kCenter CGPointMake(CGRectGetWidth(self.frame)/2, CGRectGetHeight(self.frame)/2)

@interface CircleControl ()
{
    // 选择视图的 宽度 默认 40.0
    CGFloat _buttonWith;
    // 选择视图的 大小
    CGSize _buttonSize;
    // 视图 数组
    NSArray *_buttons;
    // 初始 中心点数组
    NSMutableArray *_buttonsCenter;
    // 改变后 中心点数组
    NSMutableArray *_afterChangeCenters;
}

@end

@implementation CircleControl



-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _count = kDefaultCount;
        _redius = kMinLength(frame)/kDivisor;
        _buttonWith = kDefaultControlWidth;
        _duration = kDefaultDuration;
        _animationStyle = CircleControlAnimationStyleDefault;
        //_isAddSwipeGestureRecognizer = YES;
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor orangeColor];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame redius:(CGFloat)redius count:(int)count buttonSize:(CGSize)size
{
    self = [[CircleControl alloc] initWithFrame:frame];
    if (self) {
        if (redius > 0) {
            _redius = redius;
            _buttonSize = CGSizeMake(_buttonWith, _buttonWith);
        }
        if (size.width && size.height) {
            _buttonSize = size;
        }
        if (count) {
            _count = count;
        }
        if (_isAddSwipeGestureRecognizer) {
            [self addSwipeGestureRecognizer];
        }
        [self getButtonsCenter];
        [self creatButtons];
    }
    return self;
}

#pragma mark - add swipe GestureRecognizer

-(void)setIsAddSwipeGestureRecognizer:(BOOL)isAddSwipeGestureRecognizer
{
    if (!isAddSwipeGestureRecognizer) {
        [self removeAllGestureRecognizer];
    }else if (!_isAddSwipeGestureRecognizer){
        [self addSwipeGestureRecognizer];
    }
    _isAddSwipeGestureRecognizer = isAddSwipeGestureRecognizer;
}


-(void)addSwipeGestureRecognizer
{
    [self addGestureRecognizer:[self getSwipeGestureRecognizerWith:UISwipeGestureRecognizerDirectionRight]];
    [self addGestureRecognizer:[self getSwipeGestureRecognizerWith:UISwipeGestureRecognizerDirectionLeft]];
}

-(void)removeAllGestureRecognizer
{
    [self.gestureRecognizers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self removeGestureRecognizer:obj];
    }];
}


-(UISwipeGestureRecognizer*)getSwipeGestureRecognizerWith:(UISwipeGestureRecognizerDirection)direction
{
    UISwipeGestureRecognizer *sgr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureRecognizerAction:)];
    sgr.direction = direction;
    return sgr;
}

-(void)swipeGestureRecognizerAction:(UISwipeGestureRecognizer*)sgr
{
    if (sgr.state == UIGestureRecognizerStateEnded) {
        if (sgr.direction == UISwipeGestureRecognizerDirectionRight) {
            [self changeCenterIndexWith:[[_buttonsCenter objectAtIndex:1] CGPointValue] left:YES];
        }else if (sgr.direction == UISwipeGestureRecognizerDirectionLeft){
            [self changeCenterIndexWith:[[_buttonsCenter objectAtIndex:_afterChangeCenters.count-1] CGPointValue] left:NO];
        }
    }
   
}
#pragma mark - creat buttons
-(void)getButtonsCenter
{
    _buttonsCenter = [[NSMutableArray alloc] init];
    _afterChangeCenters = [[NSMutableArray alloc] init];
    for (int i = 0; i < _count; i++) {
        CGFloat x = cos(i*2*M_PI/_count + kBasePi)*_redius +kCenter.x;
        CGFloat y = sin(i*2*M_PI/_count + kBasePi)*_redius +kCenter.y;
        [_buttonsCenter addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
        [_afterChangeCenters addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
    }
}

-(void)creatButtons
{
    NSMutableArray *buttonsArr = [NSMutableArray array];
    for (int i = 0; i < _count; i++) {
        [buttonsArr addObject:[self creatButtonWith:i]];
    }
    _buttons = [[NSArray alloc] initWithArray:buttonsArr];
}

-(void)setBackgroundImage
{
    if ([_imageNames count]) {
        [_imageNames enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *imageName = obj;
            UIImage *image = [UIImage imageNamed:imageName];
            if (idx < [_buttons count]) {
                UIButton *button = [_buttons objectAtIndex:idx];
                [button setBackgroundImage:image forState:UIControlStateNormal];
                [button setBackgroundImage:image forState:UIControlStateHighlighted];
            }
        }];
    }
}

-(UIButton*)creatButtonWith:(NSInteger)tag
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, _buttonSize.width, _buttonSize.height);
    button.tag = tag;
    [button setTitle:[NSString stringWithFormat:@"%d",(int)tag] forState:UIControlStateNormal];
    button.backgroundColor = [UIColor greenColor];
    [button addTarget:self action:@selector(buttonBeClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    CGPoint center = [[_buttonsCenter objectAtIndex:tag] CGPointValue];
    button.layer.transform = [self getScaleRatioWith:tag left:(center.x <= kCenter.x)];
    button.center = center;
    //button.layer.cornerRadius = _buttonWith/2;
    button.layer.masksToBounds = YES;
    [self addSubview:button];
    return button;
}

// 根据 视图中心点 在 初始中心点数组中的 下标 计算 缩放比例
-(CATransform3D)getScaleRatioWith:(NSInteger)index left:(BOOL)left
{
    CGFloat distaceNumber = [self getDistanceNumberWith:index left:left];
    CGFloat scale = (distaceNumber/_count)*1.5+0.5;
    return CATransform3DMakeScale(scale, scale, scale);
}

#pragma mark - button clicked event

-(void)buttonBeClicked:(UIButton*)sender
{
    CGPoint center = sender.center;
    if (center.x == kCenter.x && center.y > kCenter.y) {
        // 相应点击事件
        if (_delegate && [_delegate respondsToSelector:@selector(selectedFinished:)]){
            [_delegate selectedFinished:sender.tag];
        }
    }else{
        // 设置视图位置
        [self changeCenterIndexWith:center left:(center.x <= kCenter.x)];
    }
}

#pragma mark - reSet centers index
-(void)changeCenterIndexWith:(CGPoint)center left:(BOOL)left
{
    // 获取 被选择 视图 的中心点，在 中心点数组中的 下标
    NSInteger index = [self getIndexClickedButtonCenterWith:[NSValue valueWithCGPoint:center]];
    NSMutableArray *centersArr = [NSMutableArray array];
    NSInteger count = [_buttonsCenter count];
    // 改变 中心点数组 中 中心点的位置
    for (int i = 0; i < count; i++) {
        [centersArr addObject:_afterChangeCenters[(count+i-index)%count]];
    }
    // 对 改变后的 中心点数组 从新赋值
    [_afterChangeCenters removeAllObjects];
    [_afterChangeCenters addObjectsFromArray:centersArr];
    // 计算动画的时间
    CFTimeInterval duration =  [self getDistanceRatioWith:index left:left]*_duration;
    // 从新设置 视图的 中心点，并开始执行动画
    // left 指当前位置 是否在左侧
    [self setButtonsCenterWith:_afterChangeCenters duration:duration left:left];
}

#pragma mark - 计算  距离比例

-(CGFloat)getDistanceRatioWith:(NSInteger)selectedIndex left:(BOOL)left
{
    /* 以圆 最高点 为基点,距离基点最近的视图 动画时间最长 为 _duration(self.duration)
     * 距离 基点 越远动画时间 越短
     * 距离 最低点 最近的视图 动画时间 最短
     */
    
    // 对 基点 的相差的 个数
    CGFloat distanceNumber = [self getDistanceNumberWith:selectedIndex left:left];
    return 1 - distanceNumber/(_count/2);
}

-(CGFloat)getDistanceNumberWith:(NSInteger)index left:(BOOL)left
{
    int divisor = [self getDivisorWith:left];
    // 对 基点 的相差的 个数
    return abs((int)index-divisor)*1.0;
}

-(int)getDivisorWith:(BOOL)left
{
    // 计算总数的 一半
    int halfOfCount = _count/2;
    // ,_count 奇偶 不同
    return (!left && _count%2)?halfOfCount+1:halfOfCount;
}

#pragma mark - get pointValue's index in _buttonsCenter
-(NSInteger)getIndexClickedButtonCenterWith:(NSValue*)centerValue
{
    __block NSInteger index = 0;
    [_buttonsCenter enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([centerValue isEqualToValue:obj]) {
            index = idx;
        }
    }];
    return index;
}

#pragma mark - reSet center and start animation

-(void)setButtonsCenterWith:(NSArray*)centers duration:(CFTimeInterval)duration left:(BOOL)left
{
    [CATransaction begin];
    self.userInteractionEnabled = NO;
    [CATransaction setAnimationDuration:_duration];
    [CATransaction setCompletionBlock:^{
        self.userInteractionEnabled = YES;
    }];
    
    if (_animationStyle == CircleControlAnimationStyleLine) {
        [self addLineAnimationWith:centers];
        [CATransaction commit];
        return;
    }
    
    for (int i = 0 ; i < [_buttons count]; i++) {
        // 获取 执行动画的 视图
        UIButton *button = [_buttons objectAtIndex:i];
        // 获取 最终 中心点
        CGPoint center = [[centers objectAtIndex:i] CGPointValue];
        // 获取 视图 中心点， 在初始 中心点数组中的 下标
        NSInteger startIndex = [self getIndexClickedButtonCenterWith:[NSValue valueWithCGPoint:button.center]];
        // 获取 最终 中心点， 在初始 中心点数组中的 下标
        NSInteger endIndex = [self getIndexClickedButtonCenterWith:[NSValue valueWithCGPoint:center]];
        // 获取 贝塞尔曲线 (动画路径)
        UIBezierPath *path = [self getBezierPathWith:startIndex endIndex:endIndex left:left];
        
        [self addPositionAnimationWith:path duration:duration layer:button.layer];
        button.layer.position = center;
        // left 指的是 最终坐标 是否在左侧
        [self addScaleAnimationWith:startIndex endIndex:endIndex left:(center.x <= kCenter.x) duration:duration layer:button.layer];
    }
   
    [CATransaction commit];
}

#pragma mark - get bezierPath
// 获取 贝塞尔曲线
-(UIBezierPath*)getBezierPathWith:(NSInteger)startIndex endIndex:(NSInteger)endIndex left:(BOOL)left
{
    return [UIBezierPath bezierPathWithArcCenter:kCenter radius:_redius startAngle:[self getAngleWith:startIndex] endAngle:[self getAngleWith:endIndex] clockwise:!left];
}

-(CGFloat)getAngleWith:(NSInteger)index
{
    return index*2*M_PI/_count + kBasePi;
}


#pragma mark - animation

-(void)addPositionAnimationWith:(UIBezierPath*)path duration:(CFTimeInterval)duration layer:(CALayer*)layer
{
    CAKeyframeAnimation *position = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    position.path = path.CGPath;
    position.duration = duration;
    position.removedOnCompletion = NO;
    [layer addAnimation:position forKey:@"position"];
    
}

-(void)addScaleAnimationWith:(NSInteger)startIndex endIndex:(NSInteger)endIndex left:(BOOL)left duration:(CFTimeInterval)duration layer:(CALayer*)layer
{
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.duration = duration;
    scaleAnimation.fromValue = [NSValue valueWithCATransform3D:[self getScaleRatioWith:startIndex left:left]];
    CATransform3D endTransform3D = [self getScaleRatioWith:endIndex left:left];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:endTransform3D];
    [layer addAnimation:scaleAnimation forKey:@"scaleAnimation"];
    layer.transform = endTransform3D;
}

-(void)addLineAnimationWith:(NSArray*)centers
{
    [UIView animateWithDuration:_duration animations:^{
        for (int i = 0 ; i < [_buttons count]; i++) {
            UIButton *button = [_buttons objectAtIndex:i];
            CGPoint center = [[centers objectAtIndex:i] CGPointValue];
            button.center = center;
        }
    }];
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
