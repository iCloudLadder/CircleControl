//
//  ViewController.m
//  CircleControl
//
//  Created by syweic on 14/11/5.
//  Copyright (c) 2014年 ___iSoftStone___. All rights reserved.
//

#import "ViewController.h"
#import "CircleControl.h"

@interface ViewController ()<CircleControlDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    CGRect frame = CGRectMake(0, 0, 400, 400);
    
    CircleControl *circle = [[CircleControl alloc] initWithFrame:frame redius:140.0 count:6 buttonSize:CGSizeMake(100, 50)];
    circle.delegate = self;
    circle.center = self.view.center;
    
    [self.view addSubview:circle];
    
    
}

-(void)selectedFinished:(NSInteger)selectedIndex
{
    NSLog(@"select %ld",selectedIndex);
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
