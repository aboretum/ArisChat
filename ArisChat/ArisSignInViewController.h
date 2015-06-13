//
//  ArisSignInViewController.h
//  ArisChat
//
//  Created by Wuchen Wang on 7/30/14.
//  Copyright (c) 2014 Wuchen Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ArisSignInViewControllerDelegate <NSObject>

-(void)credentialsStored;

@end
@interface ArisSignInViewController : UIViewController
@property (nonatomic, strong) id<ArisSignInViewControllerDelegate>  delegate;
@end

