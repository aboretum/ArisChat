//
//  ArisBaseViewController.m
//  ArisChat
//
//  Created by Wuchen Wang on 7/26/14.
//  Copyright (c) 2014 Wuchen Wang. All rights reserved.
//



#import "ArisBaseViewController.h"
#import "AppDelegate.h"
@interface ArisBaseViewController ()
@property (nonatomic,strong) UILabel *statusLabel;
@end

@implementation ArisBaseViewController

- (AppDelegate *)appDelegate
{
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [ArisHelper colorWithHexString:@"FBF6E9"];
    //if you dont want the menu buttons remove the following code
    //Create left menu button
    UIBarButtonItem *leftRevealButtonItem = [[UIBarButtonItem alloc] initWithImage:
                                             [UIImage imageNamed:@"reveal-icon.png"]
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:self action:@selector(toggleLeftMenu:)];
    self.navigationItem.leftBarButtonItem = leftRevealButtonItem;
}

-(void)updateStatus:(NSString *)newStatus
{
    self.statusLabel.text = newStatus;
}

-(void)toggleLeftMenu:(id)sender
{
    
    [[self appDelegate] toggleLeftMenu];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
