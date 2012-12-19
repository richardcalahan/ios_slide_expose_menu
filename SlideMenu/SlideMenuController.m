//
//  SlideMenuController.m
//  SlideMenu
//
//  Created by Richard Calahan on 12/17/12.
//  Copyright (c) 2012 Richard Calahan. All rights reserved.
//

#define DEFAULT_VELOCITY 800
#define DEFAULT_THRESHOLD_VELOCITY 200
#define DEFAULT_ANIMATION_DURATION 0.3
#define DEFAULT_NAVIGATION_EXPOSURE 0.7

#import "SlideMenuController.h"

@interface SlideMenuController ()

@property (nonatomic)               CGFloat touchX;                           // Updates X coordinate of current/last touch in view
@property (nonatomic, strong)       UITableView *navView;                     // Pointer to navView, (UITableView)
@property (nonatomic, strong)       UIView *contentView;                      // Pointer to contentView (UIView)
@property (nonatomic, readonly)     CGPoint contentViewCenterStart;
@property (nonatomic, readonly)     CGPoint contentViewCenterEnd;
@property (nonatomic, readonly)     CGPoint contentViewCenterMax;
@property (nonatomic, strong)       NSMutableArray *controllersStack;
@property (nonatomic, strong)       id activeViewController;

@end

@implementation SlideMenuController

@synthesize touchX               = _touchX;
@synthesize activeViewController = _activeViewController;
@synthesize controllersStack     = _controllersStack;
@synthesize velocity             = _velocity;
@synthesize thresholdVelocity    = _thresholdVelocity;
@synthesize animationDuration    = _animationDuration;
@synthesize navigationExposure   = _navigationExposure;


- (id) initWithViewControllers: (NSMutableArray *) childViewControllers {
    if ( self = [super init]) {
        // Set viewControllers stack and initialize first in array
        self.controllersStack = childViewControllers;
        [self addChildViewController: [self.controllersStack objectAtIndex: 0]];
    }
    return self;
}

- (void) loadView {
    UIView *view = [[UIView alloc] initWithFrame: [[UIScreen mainScreen] applicationFrame]];
    self.view = view;
}

- (void) viewDidLoad {
    [super viewDidLoad];
        
    // Nav View
    self.navView = [[UITableView alloc] initWithFrame: self.view.bounds style: UITableViewStylePlain];
    self.navView.dataSource = self;
    self.navView.delegate = self;
    self.navView.frame = self.view.bounds;
    self.navView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.navView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.navView];
    
    // Content View
    self.contentView = [[UIView alloc] initWithFrame: self.view.bounds];
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview: self.contentView];
    
    // Gesture Recognizer on contentView
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget: self action: @selector(handlePan:)];
    [self.contentView addGestureRecognizer: pan];
    
    [self setActiveViewController: [ self.childViewControllers objectAtIndex: 0 ]];

}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    [self.view setFrame: [[UIScreen mainScreen] bounds]];

}

- (CGFloat) velocity {
    if ( !_velocity ) _velocity = DEFAULT_VELOCITY;
    return _velocity;
}

- (CGFloat) thresholdVelocity {
    if ( !_thresholdVelocity ) _thresholdVelocity = DEFAULT_THRESHOLD_VELOCITY;
    return _thresholdVelocity;
}

- (CGFloat) animationDuration {
    if ( !_animationDuration ) _animationDuration = DEFAULT_ANIMATION_DURATION;
    return _animationDuration;
}

- (CGFloat) navigationExposure {
    if ( !_navigationExposure ) _navigationExposure = DEFAULT_NAVIGATION_EXPOSURE;
    return _navigationExposure;
}

- (CGPoint) contentViewCenterStart {
    CGFloat x = self.view.bounds.size.width / 2;
    CGFloat y = self.view.bounds.size.height / 2;
    return CGPointMake(x, y);
}

- (CGPoint) contentViewCenterEnd {
    CGFloat max = self.view.bounds.size.width + (self.contentView.bounds.size.width / 2);
    CGFloat x = max * self.navigationExposure;
    CGFloat y = self.view.bounds.size.height / 2;
    return CGPointMake(x, y);
}

- (CGPoint) contentViewCenterMax {
    CGFloat x = self.view.bounds.size.width + self.contentView.bounds.size.width / 2;
    CGFloat y = self.view.bounds.size.height / 2;
    return CGPointMake(x, y);
}

- (CGFloat) openCloseThreshold {
    return self.view.bounds.size.width;
}

- (void) setActiveViewController:(id)activeViewController {
    UIViewController *oldVC = (UIViewController *) _activeViewController;
    UIViewController *newVC = (UIViewController *) activeViewController;
    // Remove old view controller and view
    [oldVC willMoveToParentViewController:nil];
    [oldVC.view removeFromSuperview];
    [oldVC removeFromParentViewController];    
    // Prepare new view controller view
    [self addChildViewController: newVC];
    newVC.view.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2);
    newVC.view.bounds = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    [self.contentView addSubview: newVC.view];
    [newVC didMoveToParentViewController: self];
    // Set new active view controller
    _activeViewController = activeViewController;    
}

- (void) handlePan: (UIPanGestureRecognizer *) gesture {
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            [self panStateBegan:gesture];
            break;
        case UIGestureRecognizerStateChanged:
            [self panStateChanged:gesture];
            break;
        case UIGestureRecognizerStateEnded:
            [self panStateEnded:gesture];
            break;
        case UIGestureRecognizerStatePossible:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            break;
    }
}

- (void) panStateBegan: (UIPanGestureRecognizer *) gesture {

    self.touchX = [gesture locationInView:self.view].x;
}

- (void) panStateChanged: (UIPanGestureRecognizer *) gesture {
    CGFloat delta = [gesture locationInView:self.view].x - self.touchX;
    CGPoint center = self.contentView.center;
    CGFloat x = center.x + delta > self.contentViewCenterStart.x ? center.x + delta : self.contentViewCenterStart.x;
    self.contentView.center = CGPointMake(x, self.contentViewCenterStart.y);
    self.touchX = [gesture locationInView:self.view].x;
}

- (void) panStateEnded: (UIPanGestureRecognizer *) gesture {
    CGFloat xpos = self.contentView.center.x;
    CGFloat xvel = [gesture velocityInView:self.contentView].x;
    
    // Enough velocity to open
    if ( xvel > self.thresholdVelocity ) {
        [self openNavigationWithVelocity: xvel];
    }
    // Enough velocity to close
    else if ( xvel < -self.thresholdVelocity ) {
        [self closeNavigationWithVelocity: xvel];
    }
    // Not enough velocity, but passes the threshold
    else if ( xpos > self.openCloseThreshold ) {
        [self openNavigationWithVelocity: xvel];
    }
    // Not enough velocity and doesnt pass the threshold
    else {
        [self closeNavigationWithVelocity: xvel];
    }        
        
}

- (void) openNavigation {
    [self openNavigationWithVelocity: self.velocity];
}

- (void) openNavigationWithVelocity: (CGFloat) velocity {
    CGFloat xdistance = fabs(self.contentView.center.x - self.contentViewCenterEnd.x);
    CGFloat duration = xdistance / fabs(velocity) > self.animationDuration ? self.animationDuration : xdistance / fabs(velocity);
    [self animateContentViewToCenter:self.contentViewCenterEnd withDuration:duration];
}

- (void) closeNavigation {
    [self closeNavigationWithVelocity: self.velocity];
}

- (void) closeNavigationWithVelocity: (CGFloat) velocity {
    CGFloat xdistance = fabs(self.contentView.center.x - self.contentViewCenterStart.x);
    CGFloat duration = xdistance / fabs(velocity) > self.animationDuration ? self.animationDuration : xdistance / fabs(velocity);
    [self animateContentViewToCenter:self.contentViewCenterStart withDuration: duration];
}

- (void) animateContentViewToCenter: (CGPoint) center withDuration: (NSTimeInterval) duration {
    [self animateContentViewToCenter: center withDuration: duration callback: ^{}];
}

- (void) animateContentViewToCenter: (CGPoint) center withDuration: (NSTimeInterval) duration callback: (void(^)()) callback {
    // Animate center
    [UIView animateWithDuration:duration animations:^ (void) {
        self.contentView.center = center;
    } completion:^(BOOL finished) {
        callback();
    }];
}

- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView {
    return 1;
}

- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section {
    return [self.controllersStack count];
}

- (UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath {
    static NSString *identifier = @"MyReuseIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewStyleGrouped reuseIdentifier:identifier];
    }
    UIViewController *viewController = (UIViewController *)[self.controllersStack objectAtIndex:indexPath.row];
    cell.textLabel.text = viewController.title;
    return cell;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    UIViewController *viewController = [self.controllersStack objectAtIndex:indexPath.row];
    if ( viewController == self.activeViewController ) {
        [self closeNavigation];
    } else {
        [self animateContentViewToCenter:self.contentViewCenterMax withDuration: .2 callback:^{
            [self setActiveViewController:viewController];
            [self closeNavigation];
        }];
        
    }
}

- (void) willRotateToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation duration: (NSTimeInterval) duration {
    // TODO: when child view controllers are their own class, see if NOT calling this method effects anything.
    [self.activeViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void) willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation duration: (NSTimeInterval) duration {
    self.contentView.center = self.contentViewCenterStart;
}

@end
