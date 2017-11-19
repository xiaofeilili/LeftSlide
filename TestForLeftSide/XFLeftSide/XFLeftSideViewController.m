//
//  XFLeftSideViewController.m
//  TestForLeftSide
//
//  Created by 李晓飞 on 2017/11/18.
//  Copyright © 2017年 xiaofei. All rights reserved.
//

#import "XFLeftSideViewController.h"

@interface XFLeftSideViewController ()<UIGestureRecognizerDelegate>
{
    CGFloat _scalef;            // 实时横向位移
}

@property (nonatomic, strong)UITableView *leftTableView;
@property (nonatomic, assign)CGFloat leftTableViewW;
@property (nonatomic, strong)UIView *contentView;

@end

@implementation XFLeftSideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.leftVC.view.hidden = NO;
}

- (instancetype)initWithLeftView:(UIViewController *)leftVc
                     andMainView:(UIViewController *)mainVc {
    if (self = [super init]) {
        self.speedf = vSpeedFloat;
        self.leftVC = leftVc;
        self.mainVC = mainVc;
        
        // 滑动手势
        self.pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self.mainVC.view addGestureRecognizer:self.pan];
        
        [self.pan setCancelsTouchesInView:YES];             // 不太懂怎么用
        self.pan.delegate = self;
        
        self.leftVC.view.hidden = YES;
        [self.view addSubview:self.leftVC.view];
        
        // 蒙版
        UIView *view = [[UIView alloc] init];
        view.frame = self.leftVC.view.bounds;
        view.backgroundColor = [UIColor blackColor];
        view.alpha = 0.5;
        self.contentView = view;
        [self.leftVC.view addSubview:view];
        
        // 获取左侧tableView
        for (UIView *obj in self.leftVC.view.subviews) {
            if ([obj isKindOfClass:[UITableView class]]) {
                self.leftTableView = (UITableView *)obj;
            }
        }
        self.leftTableView.backgroundColor = [UIColor clearColor];
        self.leftTableView.frame = CGRectMake(0, 0, kScreenWidth - kMainPageDistance, kScreenHeight);
        // 设置左侧tableView的初始位置和缩放系数
        self.leftTableView.transform = CGAffineTransformMakeScale(kLeftScale, kLeftScale);
        self.leftTableView.center = CGPointMake(kLeftCenterX, kScreenHeight/2.0);
        
        [self.view addSubview:self.mainVC.view];
        self.isClosed = YES;        // 初始侧滑关闭
        
    }
    return self;
}

#pragma mark    ----Action
// 滑动手势
- (void)handlePan:(UIPanGestureRecognizer *)pan {
    CGPoint point = [pan translationInView:self.view];
    _scalef = point.x * self.speedf + _scalef;
    
    BOOL needMoveWithTap = YES;                             // 是否还需要跟随手指移动
    if (((self.mainVC.view.x <= 0) && (_scalef <= 0)) || ((self.mainVC.view.x >= (kScreenWidth - kMainPageDistance)) && (_scalef >= 0))) {
        // 边界值管控
        _scalef = 0;
        needMoveWithTap = NO;
    }
    
    // 根据视图位置判断是左滑还是右滑
    if (needMoveWithTap && (pan.view.frame.origin.x >= 0) && (pan.view.frame.origin.x <= (kScreenWidth - kMainPageDistance))) {
        CGFloat recCenterX = pan.view.center.x + point.x * self.speedf;
        if (recCenterX < kScreenWidth * 0.5 - 2) {
            recCenterX = kScreenWidth * 0.5;
        }
        
        CGFloat recCenterY = pan.view.center.y;
        // mainVc 中心点位置
        pan.view.center = CGPointMake(recCenterX, recCenterY);
        
        CGFloat scale = 1- (1-kMainPageScale) * (pan.view.frame.origin.x / (kScreenWidth - kMainPageDistance));
        
        pan.view.transform = CGAffineTransformMakeScale(scale, scale);
        [pan setTranslation:CGPointMake(0, 0) inView:self.view];
        
        CGFloat leftTabCenterX = kLeftCenterX + ((kScreenWidth - kMainPageDistance) * 0.5 - kLeftCenterX) * (pan.view.frame.origin.x / (kScreenWidth - kMainPageDistance));
        
        CGFloat leftScale = kLeftScale + (1 - kLeftScale) * (pan.view.frame.origin.x / (kScreenWidth - kMainPageDistance));
        
        self.leftTableView.center = CGPointMake(leftTabCenterX, kScreenHeight * 0.5);
        self.leftTableView.transform = CGAffineTransformScale(CGAffineTransformIdentity, leftScale, leftScale);
        
        CGFloat tempAlpha = kLeftAlpha - kLeftAlpha * (pan.view.frame.origin.x / (kScreenWidth - kMainPageDistance));
        self.contentView.alpha = tempAlpha;
    }else {
        // 超出范围
        if (self.mainVC.view.x < 0) {
            [self closeLeftView];    
            _scalef = 0;
        }else if (self.mainVC.view.x > (kScreenWidth - kMainPageDistance)) {
            [self openLeftView];
            _scalef = 0;
        }
    }
    
//    手势结束后修正位置，超过约一半时向多出的一半偏移
    if (pan.state == UIGestureRecognizerStateEnded) {
        if (fabs(_scalef) > vCouldChangeDeckStateDistance) {
            if (self.isClosed) {
                [self openLeftView];
            }else {
                [self closeLeftView];
            }
        }else {
            if (self.isClosed) {
                [self closeLeftView];
            }else {
                [self openLeftView];
            }
        }
        _scalef = 0;
    }
}
// 单击手势
- (void)handleTap:(UITapGestureRecognizer *)tap {
    if ((!self.isClosed) && (tap.state == UIGestureRecognizerStateEnded)) {
        [UIView beginAnimations:nil context:nil];
        tap.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
        tap.view.center = CGPointMake(kScreenWidth/2.0, kScreenHeight/2.0);
        self.isClosed = YES;
        
        
        
        /////////////////////
        self.leftTableView.center = CGPointMake(kLeftCenterX, kScreenHeight * 0.5);
        self.leftTableView.transform = CGAffineTransformScale(CGAffineTransformIdentity,kLeftScale,kLeftScale);
        self.contentView.alpha = kLeftAlpha;
        
        [UIView commitAnimations];
        _scalef = 0;
        [self removeSingleTap];
    }
}

#pragma mark    ----修改视图位置
- (void)closeLeftView {
    [UIView beginAnimations:nil context:nil];
    self.mainVC.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
    self.mainVC.view.center = CGPointMake(kScreenWidth / 2.0, kScreenHeight / 2.0);
    self.isClosed = YES;
    
    self.leftTableView.center = CGPointMake(kLeftCenterX, kScreenHeight * 0.5);
    self.leftTableView.transform = CGAffineTransformScale(CGAffineTransformIdentity, kLeftScale, kLeftScale);
    self.contentView.alpha = kLeftAlpha;
    
    [UIView commitAnimations];
    [self removeSingleTap];
}

- (void)openLeftView {
    [UIView beginAnimations:nil context:nil];
    self.mainVC.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, kMainPageScale, kMainPageScale);
    self.mainVC.view.center = kMainPageCenter;
    self.isClosed = NO;
    
    self.leftTableView.center = CGPointMake((kScreenWidth - kMainPageDistance) * 0.5, kScreenHeight * 0.5);
    self.leftTableView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
    self.contentView.alpha = 0;
    
    [UIView commitAnimations];
    [self disableTapButton];
    
}

#pragma mark    ---行为收敛控制
- (void)removeSingleTap {
    for (UIButton *tempButton in [self.mainVC.view subviews]) {
        [tempButton setUserInteractionEnabled:YES];
    }
    [self.mainVC.view removeGestureRecognizer:self.sideSlipTapGes];
    self.sideSlipTapGes = nil;
}

- (void)disableTapButton {
    for (UIButton *tempButton in [self.mainVC.view subviews]) {
        [tempButton setUserInteractionEnabled:NO];
    }
    // 单击
    if (!self.sideSlipTapGes) {
        // 单击手势
        self.sideSlipTapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self.sideSlipTapGes setNumberOfTapsRequired:1];    // 设置手指数
        
        [self.mainVC.view addGestureRecognizer:self.sideSlipTapGes];
        self.sideSlipTapGes.cancelsTouchesInView = YES;//点击事件盖住其它响应事件,但盖不住Button;
    }
}

/**
 * 设置滑动开关是否开启
 * 
 * @param enabled   YES:支持滑动手势 NO:不支持滑动手势
 */
- (void)setPanEnabled:(BOOL)enabled {
    [self.pan setEnabled:enabled];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (touch.view.tag == vDeckCanNotPanViewTag) {
        return NO;
    }else {
        return YES;
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
