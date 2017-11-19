//
//  AppDelegate.h
//  TestForLeftSide
//
//  Created by 李晓飞 on 2017/11/18.
//  Copyright © 2017年 xiaofei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XFLeftSideViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong)XFLeftSideViewController *leftSideVC;
@property (nonatomic, strong)UINavigationController *mainNavigationController;


@end

