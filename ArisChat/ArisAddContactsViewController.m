//
//  ArisAddContactsViewController.m
//  ArisChat
//
//  Created by Wuchen Wang on 5/27/15.
//  Copyright (c) 2015 Wuchen Wang. All rights reserved.
//

#import "ArisAddContactsViewController.h"
#import "AppDelegate.h"

@interface ArisAddContactsViewController (){
    
    UIImageView *tailHolder;
    UIImageView *imgHolder;
    UITextField *username;
}



@end

@implementation ArisAddContactsViewController

#define BOX_WIDTH 0.5
#define BOX_HEIGHT 0.3

- (AppDelegate *)appDelegate
{
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor=[UIColor whiteColor];
    
    UIImage *tail = [UIImage imageNamed:@"tail.png"];
    UIImage *img = [UIImage imageNamed:@"dog2.jpg"];
    imgHolder = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,[self.view bounds].size.width, [self.view bounds].size.height)];
    tailHolder = [[UIImageView alloc] initWithFrame:CGRectMake([self.view bounds].size.width*0.09375,[self.view bounds].size.height*0.572916,[self.view bounds].size.width*0.766*0.3, [self.view bounds].size.height*0.427*0.2)];
    //NSLog(@"%f", [self.view bounds].size.width);
    //NSLog(@"%f", [self.view bounds].size.height);
    imgHolder.image = img;
    tailHolder.image = tail;
    [self.view addSubview:imgHolder];
    [self.view addSubview:tailHolder];
    tailHolder.layer.anchorPoint = CGPointMake(0,1);
    
    //Add chat label
    UILabel *chatLabel = [[UILabel alloc] initWithFrame:CGRectMake((ScreenWidth-50)/2,25,70,30)];
    chatLabel.text = [NSString stringWithFormat:@"Add"];
    chatLabel.backgroundColor = [UIColor clearColor];
    chatLabel.font =   [UIFont fontWithName:@"Helvetica-Bold" size:16.0];
    chatLabel.textColor = [UIColor blackColor];
    [self.view addSubview:chatLabel];
    
    //Add a cancel button
    UIButton *cancelButton = [[UIButton alloc] initWithFrame: CGRectMake(10,25,50,86)];
    
    cancelButton.backgroundColor=[UIColor clearColor];
    cancelButton.layer.cornerRadius = 5.0f;
    [cancelButton addTarget:self action:@selector(cancelOperation:) forControlEvents:UIControlEventTouchUpInside];
    UILabel *cancelLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,70,30)];
    cancelLabel.backgroundColor=[UIColor clearColor];
    [cancelLabel setFont:[UIFont systemFontOfSize:16]];
    cancelLabel.text=@"Cancel";
    cancelLabel.adjustsFontSizeToFitWidth=YES;
    cancelLabel.textAlignment=NSTextAlignmentCenter;
    cancelLabel.textColor= [ArisHelper colorWithHexString:@"0x663300" ];
    [cancelButton addSubview:cancelLabel];
    [self.view addSubview:cancelButton];
    
    UIButton *tailButton = [[UIButton alloc] initWithFrame: CGRectMake([self.view bounds].size.width*0.09375,[self.view bounds].size.height*0.572916,[self.view bounds].size.width*0.766*0.3, [self.view bounds].size.height*0.427*0.2)];
    tailButton.backgroundColor = [UIColor clearColor];
    [tailButton addTarget:self action:@selector(addFriends:) forControlEvents:UIControlEventTouchUpInside];
    tailButton.layer.anchorPoint = CGPointMake(0,1);
    [self.view addSubview:tailButton];
}


- (void)rotateImage:(UIImageView *)image duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay
              curve:(int)curve rotations:(CGFloat)rotations
{
    [UIView animateWithDuration:duration
                          delay:delay
                        options:0
                     animations:^{
                         [UIView setAnimationCurve:curve];
                         image.transform = CGAffineTransformMakeRotation(rotations);
                         
                     }
                     completion:^(BOOL finished){
                         [self rotateImage2:image duration:duration delay:0 curve:curve rotations:rotations];
                         ;
                     }];
    [UIView commitAnimations];
    
}

- (void)rotateImage2:(UIImageView *)image duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay
               curve:(int)curve rotations:(CGFloat)rotations
{
    [UIView animateWithDuration:duration
                          delay:delay
                        options:0
                     animations:^{
                         [UIView setAnimationCurve:curve];
                         image.transform = CGAffineTransformMakeRotation(-rotations);
                     }
                     completion:^(BOOL finished){
                         [self rotateImage3:image duration:duration delay:delay curve:curve rotations:rotations];
                         ;
                     }];
    [UIView commitAnimations];
    
}

- (void)rotateImage3:(UIImageView *)image duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay
               curve:(int)curve rotations:(CGFloat)rotations
{
    [UIView animateWithDuration:duration
                          delay:delay
                        options:0
                     animations:^{
                         [UIView setAnimationCurve:curve];
                         image.transform = CGAffineTransformMakeRotation(rotations);
                         
                     }
                     completion:^(BOOL finished){
                         [self rotateImage4:image duration:duration delay:delay curve:curve rotations:rotations];
                         ;
                     }];
    [UIView commitAnimations];
    
}


- (void)rotateImage4:(UIImageView *)image duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay
               curve:(int)curve rotations:(CGFloat)rotations
{
    [UIView animateWithDuration:duration
                          delay:delay
                        options:0
                     animations:^{
                         [UIView setAnimationCurve:curve];
                         image.transform = CGAffineTransformMakeRotation(-rotations);
                     }
                     completion:^(BOOL finished){
                         
                         ;
                     }];
    [UIView commitAnimations];
    
}

#pragma button events
-(void)cancelOperation:(id*)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)addFriends:(id*)sender{
    [self rotateImage:tailHolder duration:0.15 delay:0.8 curve:UIViewAnimationCurveLinear rotations:(M_1_PI)];
    UIView * addView = [[UIView alloc]initWithFrame:CGRectMake([self.view bounds].size.width*0.09375,[self.view bounds].size.height*0.372916,[self.view bounds].size.width*0.4, [self.view bounds].size.height*0.3)];
    addView.backgroundColor = [UIColor clearColor];
    addView.layer.cornerRadius = 5.0f;
    addView.layer.anchorPoint = CGPointMake(0,1);
    username = [[UITextField alloc] initWithFrame:CGRectMake(0, [addView bounds].size.height*0.4,[addView bounds].size.width, [addView bounds].size.height*0.2)];
    username.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@" @username"];
    username.layer.masksToBounds = YES;
    username.layer.borderColor = [[UIColor grayColor] CGColor];
    username.layer.cornerRadius = 5.0f;
    username.backgroundColor = [UIColor whiteColor];
    username.textColor = [ArisHelper colorWithHexString:@"0x663300"];
    [addView addSubview:username];
    
    UIButton *okButton = [[UIButton alloc] initWithFrame: CGRectMake([addView bounds].size.width*0.7,[addView bounds].size.height*0.70,[addView bounds].size.width*0.3, [addView bounds].size.height*0.2)];
    
    [okButton setTitle:@"OK" forState:UIControlStateNormal];
    [okButton setTitleColor:[ArisHelper colorWithHexString:@"0x663300"] forState:UIControlStateNormal];
    [okButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15.0]];
    [okButton addTarget:self action:@selector(exitView:) forControlEvents:UIControlEventTouchUpInside];
    [addView addSubview:okButton];
    
    [self.view addSubview:addView];
    // instantaneously make the image view small (scaled to 1% of its actual size)
    addView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    [UIView animateWithDuration:0.2 delay:1.2 options:UIViewAnimationOptionCurveEaseOut animations:^{
        // animate it to the identity transform (100% scale)
        addView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished){
       
    }];
}

-(void)exitView:(id*)sender{
    
    NSString *jidString = [NSString stringWithFormat:@"%@@%@",username.text,kXMPPServer];
    NSLog(@"JID %@",jidString);
    [[self appDelegate] sendInvitationToJID:jidString withNickName:username.text];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
