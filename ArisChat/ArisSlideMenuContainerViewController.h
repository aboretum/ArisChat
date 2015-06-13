//
//  ArisSlideMenuContainerViewController.h
//  ArisChat
//
//  Created by Wuchen Wang on 7/26/14.
//  Copyright (c) 2014 Wuchen Wang. All rights reserved.
//


#import <UIKit/UIKit.h>


extern NSString * const MFSideMenuStateNotificationEvent;

typedef enum {
    ArisSLideMenuPanModeNone = 0, // pan disabled
    ArisSLideMenuPanModeCenterViewController = 1 << 0, // enable panning on the centerViewController
    ArisSLideMenuPanModeSideMenu = 1 << 1, // enable panning on side menus
    ArisSLideMenuPanModeDefault = ArisSLideMenuPanModeCenterViewController | ArisSLideMenuPanModeSideMenu
} ArisSLideMenuPanMode;

typedef enum {
    ArisSLideMenuStateClosed, // the menu is closed
    ArisSLideMenuStateLeftMenuOpen, // the left-hand menu is open
    ArisSLideMenuStateRightMenuOpen // the right-hand menu is open
} ArisSLideMenuState;

typedef enum {
    ArisSLideMenuStateEventMenuWillOpen, // the menu is going to open
    ArisSLideMenuStateEventMenuDidOpen, // the menu finished opening
    ArisSLideMenuStateEventMenuWillClose, // the menu is going to close
    ArisSLideMenuStateEventMenuDidClose // the menu finished closing
} ArisSLideMenuStateEvent;

@protocol ArisSlideMenuContainerViewControllerDelegate <NSObject>

-(void)menuWillHide;

@end

@interface ArisSlideMenuContainerViewController : UIViewController<UIGestureRecognizerDelegate>

+ (ArisSlideMenuContainerViewController *)containerWithCenterViewController:(id)centerViewController
                                                   leftMenuViewController:(id)leftMenuViewController
                                                  rightMenuViewController:(id)rightMenuViewController;

@property (nonatomic, strong) id<ArisSlideMenuContainerViewControllerDelegate>  delegate;


@property (nonatomic, strong) id centerViewController;
@property (nonatomic, strong) UIViewController *leftMenuViewController;
@property (nonatomic, strong) UIViewController *rightMenuViewController;

@property (nonatomic, assign) ArisSLideMenuState menuState;
@property (nonatomic, assign) ArisSLideMenuPanMode panMode;

// menu open/close animation duration -- user can pan faster than default duration, max duration sets the limit
@property (nonatomic, assign) CGFloat menuAnimationDefaultDuration;
@property (nonatomic, assign) CGFloat menuAnimationMaxDuration;

// width of the side menus
@property (nonatomic, assign) CGFloat menuWidth;
@property (nonatomic, assign) CGFloat leftMenuWidth;
@property (nonatomic, assign) CGFloat rightMenuWidth;



// menu slide-in animation
@property (nonatomic, assign) BOOL menuSlideAnimationEnabled;
@property (nonatomic, assign) CGFloat menuSlideAnimationFactor; // higher = less menu movement on animation


- (void)toggleLeftSideMenuCompletion:(void (^)(void))completion;
- (void)toggleRightSideMenuCompletion:(void (^)(void))completion;
- (void)setMenuState:(ArisSLideMenuState)menuState completion:(void (^)(void))completion;
- (void)setMenuWidth:(CGFloat)menuWidth animated:(BOOL)animated;
- (void)setLeftMenuWidth:(CGFloat)leftMenuWidth animated:(BOOL)animated;
- (void)setRightMenuWidth:(CGFloat)rightMenuWidth animated:(BOOL)animated;

// can be used to attach a pan gesture recognizer to a custom view
- (UIPanGestureRecognizer *)panGestureRecognizer;

@end
