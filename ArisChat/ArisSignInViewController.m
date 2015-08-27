//
//  ArisSignInViewController.m
//  ArisChat
//
//  Created by Wuchen Wang on 7/30/14.
//  Copyright (c) 2014 Wuchen Wang. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ArisSignInViewController.h"
#import "KeychainItemWrapper.h"
@interface ArisSignInViewController (){
    UIImageView *tailHolder;
    UIImageView *imgHolder;
}

@property (nonatomic,strong) UITextField *jidField;
@property (nonatomic,strong) UITextField *passwordField;
@end

@implementation ArisSignInViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.hidesBackButton=YES;
    
    
	// Do any additional setup after loading the view.
    self.view.backgroundColor=[UIColor whiteColor];
    self.title = @"Sign in";
    
    UIImage *tail = [UIImage imageNamed:@"tail.png"];
    UIImage *img = [UIImage imageNamed:@"dog2.jpg"];
    imgHolder = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,[self.view bounds].size.width, [self.view bounds].size.height)];
    tailHolder = [[UIImageView alloc] initWithFrame:CGRectMake([self.view bounds].size.width*0.09375,[self.view bounds].size.height*0.572916,[self.view bounds].size.width*0.766*0.3, [self.view bounds].size.height*0.427*0.2)];
    imgHolder.image = img;
    tailHolder.image = tail;
    [self.view addSubview:imgHolder];
    [self.view addSubview:tailHolder];
    tailHolder.layer.anchorPoint = CGPointMake(0,1);
    
    
    self.jidField = [[UITextField alloc] initWithFrame:CGRectMake(20.0, 80.0, 280, 40.0)];
	self.jidField.borderStyle = UITextBorderStyleNone;
    self.jidField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	self.jidField.tag = 1;
	self.jidField.keyboardType = UIKeyboardTypeDefault;
	self.jidField.backgroundColor = [UIColor whiteColor];
	self.jidField.font = [UIFont systemFontOfSize:16.0];
	self.jidField.autocorrectionType = UITextAutocorrectionTypeNo;
	self.jidField.placeholder = @"Enter username";
	self.jidField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	self.jidField.returnKeyType = UIReturnKeyNext;
    self.jidField.borderStyle = UITextBorderStyleRoundedRect;
    self.jidField.layer.borderWidth = 1.0f;
    self.jidField.layer.borderColor = [[UIColor grayColor] CGColor];
    self.jidField.layer.cornerRadius = 5.0f;
    [self.view addSubview:self.jidField ];
    
    self.passwordField = [[UITextField alloc] initWithFrame:CGRectMake(20.0, 135.0, 280, 40.0)];
	self.passwordField.borderStyle = UITextBorderStyleNone;
    self.passwordField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	self.passwordField.tag = 2;
	self.passwordField.keyboardType = UIKeyboardTypeDefault;
	self.passwordField.backgroundColor = [UIColor whiteColor];
	self.passwordField.font = [UIFont systemFontOfSize:16.0];
	self.passwordField.autocorrectionType = UITextAutocorrectionTypeNo;
	self.passwordField.placeholder = @"Enter the password";
    self.passwordField.secureTextEntry = YES;
	self.passwordField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	self.passwordField.returnKeyType = UIReturnKeyNext;
    self.passwordField.borderStyle = UITextBorderStyleRoundedRect;
    self.passwordField.layer.borderWidth = 1.0f;
    self.passwordField.layer.borderColor = [[UIColor grayColor] CGColor];
    self.passwordField.layer.cornerRadius = 5.0f;
    [self.view addSubview:self.passwordField ];
    
    //Sign in
    UIButton* signInButton = [[UIButton alloc] initWithFrame:CGRectMake(20,190,280,45)];
    signInButton.backgroundColor=[ArisHelper colorWithHexString:@"0x663300" ];
    signInButton.layer.borderWidth = 1.0f;
    signInButton.layer.borderColor = [[UIColor grayColor] CGColor];
    signInButton.layer.cornerRadius = 5.0f;
    [signInButton addTarget:self action:@selector(saveCredentials:) forControlEvents:UIControlEventTouchUpInside];
    UILabel *signInLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,280,45)];
    signInLabel.backgroundColor=[UIColor clearColor];
    [signInLabel setFont:[UIFont systemFontOfSize:20]];
    signInLabel.text=@"Sign in";
    signInLabel.adjustsFontSizeToFitWidth=YES;
    signInLabel.textAlignment=NSTextAlignmentCenter;
    signInLabel.textColor=[UIColor whiteColor];
    [signInButton addSubview:signInLabel];
    [self.view addSubview:signInButton];
    //Cancel
    UIButton* cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(20,250,280,45)];
    cancelButton.backgroundColor=[ArisHelper colorWithHexString:@"0x663300" ];
    cancelButton.layer.borderWidth = 1.0f;
    cancelButton.layer.borderColor = [[UIColor grayColor] CGColor];
    cancelButton.layer.cornerRadius = 5.0f;
    [cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    UILabel *cancelLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,280,45)];
    cancelLabel.backgroundColor=[UIColor clearColor];
    [cancelLabel setFont:[UIFont systemFontOfSize:20]];
    cancelLabel.text=@"Cancel";
    cancelLabel.adjustsFontSizeToFitWidth=YES;
    cancelLabel.textAlignment=NSTextAlignmentCenter;
    cancelLabel.textColor=[UIColor whiteColor];
    [cancelButton addSubview:cancelLabel];
    [self.view addSubview:cancelButton];
    
    
}
-(IBAction)saveCredentials:(UIButton *)sender
{
    if (([self.jidField.text length] == 0) ||([self.passwordField.text length] == 0) )
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops"
                                                        message:@"Both fields are mandatory"
                                                       delegate:self cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    else
    {
        KeychainItemWrapper* keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"ArisCHAT" accessGroup:nil];
        NSString *jid = [NSString stringWithFormat:@"%@@%@",self.jidField.text,kXMPPServer];
        [[NSUserDefaults standardUserDefaults] setValue:jid forKey:kXMPPmyJID];
        [[NSUserDefaults standardUserDefaults]  synchronize];
        [keychain setObject:self.passwordField.text forKey:(__bridge id)kSecValueData];
        [self.navigationController popToRootViewControllerAnimated:NO];
        [self.delegate credentialsStored];
    }
    
}
-(IBAction)cancel:(UIButton *)sender
{
    [self.navigationController popToRootViewControllerAnimated:NO];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end