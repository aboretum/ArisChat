//
//  ArisConversationViewController.h
//  ArisChat
//
//  Created by Wuchen Wang on 10/19/14.
//  Copyright (c) 2014 Wuchen Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SendView.h"

@interface ArisConversationViewController : UIViewController
{
    float prevLines;
    UIButton *sendButton;
    UIButton *sendButton2;
    UIButton *circleButton;
}
@property (nonatomic,strong) NSString *cleanName;
@property (nonatomic,strong) NSString *conversationJidString;
@property (nonatomic,strong) UITableView *mtableView;
@property (nonatomic,strong) NSMutableArray* chats;
@property (nonatomic,strong) UILabel *statusLabel;
@property (nonatomic,strong) SendView *sendView;
@property (nonatomic,strong) UITextView *msgText;

-(void)showConversationForJIDString:(NSString *)jidString;
-(void)shortenTableView;
-(void)scrollToBottomAnimated:(BOOL)animated;
-(void)loadData;
-(IBAction)sendMessage:(id)sender;

@end
