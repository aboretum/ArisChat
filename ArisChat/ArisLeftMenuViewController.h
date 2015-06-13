//
//  ArisLeftMenuViewController.h
//  ArisChat
//
//  Created by Wuchen Wang on 7/25/14.
//  Copyright (c) 2014 Wuchen Wang. All rights reserved.
//

#import <UIKit/UIkit.h>
#import "ArisMenuItem.h"

@protocol ArisLeftMenuViewControllerDelegate <NSObject>

-(void)leftMenuSelectionItemClick:(ArisMenuItem *)item;

@end
@interface ArisLeftMenuViewController : UIViewController

@property (nonatomic, strong) id<ArisLeftMenuViewControllerDelegate>  delegate;

@property(nonatomic,strong)NSArray* menuItems;



@end
