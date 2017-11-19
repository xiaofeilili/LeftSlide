//
//  XFLeftSideViewController.h
//  TestForLeftSide
//
//  Created by 李晓飞 on 2017/11/18.
//  Copyright © 2017年 xiaofei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView_extra.h"

#define vDeckCanNotPanViewTag           987654

@interface XFLeftSideViewController : UIViewController

// 滑动速度系数  0.5-1之间 默认0.5
@property (nonatomic, assign)CGFloat speedf;

// 左侧窗控制器
@property (nonatomic, strong)UIViewController *leftVC;
// 主窗控制器
@property (nonatomic, strong)UIViewController *mainVC;
// 点击手势控制器，是否允许点击视图恢复视图位置。默认是YES
@property (nonatomic, strong)UITapGestureRecognizer *sideSlipTapGes;
// 滑动手势控制器
@property (nonatomic, strong)UIPanGestureRecognizer *pan;
// 侧滑窗是否关闭（关闭时显示为主页）
@property (nonatomic, assign)BOOL isClosed;


- (instancetype)initWithLeftView:(UIViewController *)leftVc
                     andMainView:(UIViewController *)mainVc;

@end
