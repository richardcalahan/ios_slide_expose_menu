//
//  SlideMenuController.h
//  SlideMenu
//
//  Created by Richard Calahan on 12/17/12.
//  Copyright (c) 2012 Richard Calahan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SlideMenuController : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic)               CGFloat velocity;                     // Velocity (points/second) of programmatic movement of contentView
@property (nonatomic)               CGFloat thresholdVelocity;            // Velocity (points/second) threshold to trigger opening/closing of contentView
@property (nonatomic)               CGFloat animationDuration;            // Minumum duration of animtaion of contentView (calculated by velocity of pan gesture)
@property (nonatomic)               CGFloat navigationExposure;           // Percent of navigation screen (x axis) that will be visible when exposed

- (id) initWithViewControllers: (NSMutableArray *) childViewControllers;  // Sets initial array of child view controllers

@end
