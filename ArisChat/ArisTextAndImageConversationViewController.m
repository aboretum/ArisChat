//
//  ArisTextAndImageConversationViewController.m
//  ArisChat
//
//  Created by Wuchen Wang on 6/22/15.
//  Copyright (c) 2015 Wuchen Wang. All rights reserved.
//

#import "ArisTextAndImageConversationViewController.h"

@interface ArisTextAndImageConversationViewController ()

@end

@implementation ArisTextAndImageConversationViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor=[UIColor whiteColor];
    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,60,ScreenWidth,20)];
    self.statusLabel.backgroundColor = [UIColor colorWithRed:230/255.0f green:230/255.0f blue:231/255.0f alpha:1.0f];
    self.statusLabel.textColor=[ArisHelper colorWithHexString:@"0x663300" ];
    self.statusLabel.textAlignment=NSTextAlignmentCenter;
    self.statusLabel.text = self.cleanName;
    [self.statusLabel setFont:[UIFont systemFontOfSize:14]];
    [self.view addSubview:self.statusLabel];
    
    self.mtableView.rowHeight=100;
    self.mtableView.scrollsToTop = NO;
    self.mtableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    self.mtableView.backgroundColor = [UIColor clearColor];
    [self.mtableView setSeparatorColor:[ArisHelper colorWithHexString:@"#F2F2F2"]];
    [self.view addSubview:self.mtableView];
    //need a view for sending messages with controls
    self.sendView = [[SendView alloc] initWithFrame:CGRectMake(0,ScreenHeight-ScreenWidth/4,ScreenWidth,ScreenWidth/4+60)];
    self.sendView.conversationViewController = self;
    self.sendView.backgroundColor=[ArisHelper colorWithHexString:@"#F2F2F2"];
    self.sendView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.sendView.layer.borderWidth = 0.5;
    
    
    
    self.msgText.contentInset = UIEdgeInsetsMake(0,0,0,0);
    self.msgText.textContainerInset = UIEdgeInsetsMake(3,0,0,0);
    
    prevLines=0.9375f;
    
    
    /**
     //Add the send button
     sendButton = [[UIButton alloc] initWithFrame:CGRectMake(180,7,77,42)];
     sendButton.backgroundColor=[UIColor clearColor];
     [sendButton setBackgroundImage:[UIImage imageNamed:@"home1.png"] forState:UIControlStateNormal];
     [sendButton addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];
     sendButton.autoresizingMask=UIViewAutoresizingFlexibleTopMargin;
     [sendButton.layer setMasksToBounds:YES];
     sendButton.layer.cornerRadius = 10.0f;
     sendButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
     sendButton.layer.borderWidth = 0.5;
     
     
     sendButton2 = [[UIButton alloc] initWithFrame:CGRectMake(57,7,77,42)];
     sendButton2.backgroundColor=[UIColor clearColor];
     [sendButton2 setBackgroundImage:[UIImage imageNamed:@"eat.png"] forState:UIControlStateNormal];
     [sendButton2 addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];
     sendButton2.autoresizingMask=UIViewAutoresizingFlexibleTopMargin;
     [sendButton2.layer setMasksToBounds:YES];
     sendButton2.layer.cornerRadius = 10.0f;
     sendButton2.layer.borderColor = [UIColor lightGrayColor].CGColor;
     sendButton2.layer.borderWidth = 0.5;
     
     
     
     [self.sendView addSubview:sendButton];
     [self.sendView addSubview:sendButton2];
     **/
    
    [self.view addSubview:self.sendView];
    [self loadData];
    
    circleButton = [[UIButton alloc] initWithFrame:CGRectMake(275,8,36,36)];
    circleButton.backgroundColor=[UIColor clearColor];
    [circleButton addTarget:self action:@selector(callForKeyBoard:) forControlEvents:UIControlEventTouchUpInside];
    circleButton.autoresizingMask=UIViewAutoresizingFlexibleTopMargin;
    [circleButton setBackgroundImage:[UIImage imageNamed:@"smiley-face.png"] forState:UIControlStateNormal];
    circleButton.layer.cornerRadius=18.0f;
    circleButton.layer.borderColor=[UIColor clearColor].CGColor;
    circleButton.layer.borderWidth = 0.5;
    [self.sendView addSubview:circleButton];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
    {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
	Chat* chat = [self.chats objectAtIndex:indexPath.row];
    UIFont* systemFont = [UIFont boldSystemFontOfSize:12];
    int width = 185.0, height = 10000.0;
    NSMutableDictionary *atts = [[NSMutableDictionary alloc] init];
    [atts setObject:systemFont forKey:NSFontAttributeName];
    
    CGRect textSize = [chat.messageBody boundingRectWithSize:CGSizeMake(width, height)
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:atts
                                                     context:nil];
    float textHeight = textSize.size.height;
    
    //Body
    UITextView *body = [[UITextView alloc] initWithFrame:CGRectMake(70,0,240,textHeight+5)];
    body.backgroundColor = [UIColor clearColor];
    body.editable = NO;
    body.scrollEnabled = NO;
    body.backgroundColor=[UIColor clearColor];
    body.textColor=[UIColor blackColor];
    body.textAlignment=NSTextAlignmentLeft;
    [body setFont:[UIFont  boldSystemFontOfSize:12]];
    body.text = chat.messageBody;
    //[body sizeToFit];
    //SenderLabel
    UILabel *senderLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,textHeight +10 ,300,20)];
    senderLabel.backgroundColor=[UIColor clearColor];
    senderLabel.font = [UIFont systemFontOfSize:12];
    senderLabel.textColor=[UIColor blackColor];
    senderLabel.textAlignment=NSTextAlignmentLeft;
    UIImage *bgImage;
    UIImage *msgImage;
    float senderStartX;
    if([chat.messageBody isEqualToString:@"Aris1"]||[chat.messageBody isEqualToString:@"Aris2"]){
        chat.messageBody = @"";
    }
    if ([chat.messageBody isEqualToString:@""]) {
        if ([chat.direction isEqualToString:@"IN"])
        { // left aligned
            
            if([chat.messageID isEqualToString:@"Aris1"]){
                bgImage = [UIImage imageNamed:@"torn-paper.jpg"] ;
                msgImage = [UIImage imageNamed:@"home1.png"] ;
                body.frame=CGRectMake(10,13,240.0,textHeight+5);
                senderLabel.frame=CGRectMake(68,textHeight+15,250,13);
                senderLabel.text= [NSString stringWithFormat:@"%@: %@",self.cleanName ,[ArisHelper dayLabelForMessage:chat.messageDate]];
                senderStartX=19;
            }else if([chat.messageID isEqualToString:@"Aris2"]){
                bgImage = [UIImage imageNamed:@"torn-paper.jpg"] ;
                msgImage = [UIImage imageNamed:@"eat.png"] ;
                body.frame=CGRectMake(10,13,240.0,textHeight+5);
                senderLabel.frame=CGRectMake(68,textHeight+15,250,13);
                senderLabel.text= [NSString stringWithFormat:@"%@: %@",self.cleanName ,[ArisHelper dayLabelForMessage:chat.messageDate]];
                senderStartX=19;
            }
        }
        else
        {
            //right aligned
            if([chat.messageID isEqualToString:@"Aris1"]){
                bgImage = [UIImage imageNamed:@"torn-paper4.png"] ;
                msgImage = [UIImage imageNamed:@"home1.png"] ;
                body.frame=CGRectMake(45,13,240.0,textHeight+5);
                senderLabel.frame=CGRectMake(55,textHeight+15,250,13);
                senderLabel.text= [NSString stringWithFormat:@"You %@" ,[ArisHelper dayLabelForMessage:chat.messageDate]];
                senderStartX=55;
            }else if([chat.messageID isEqualToString:@"Aris2"]){
                bgImage = [UIImage imageNamed:@"torn-paper4.png"] ;
                msgImage = [UIImage imageNamed:@"eat.png"] ;
                body.frame=CGRectMake(45,13,240.0,textHeight+5);
                senderLabel.frame=CGRectMake(55,textHeight+15,250,13);
                senderLabel.text= [NSString stringWithFormat:@"You %@" ,[ArisHelper dayLabelForMessage:chat.messageDate]];
                senderStartX=55;
            }
        }
        
    }else{
        if ([chat.direction isEqualToString:@"IN"])
        { // left aligned
            bgImage = [[UIImage imageNamed:@"torn-paper.jpg"] stretchableImageWithLeftCapWidth:0  topCapHeight:15];
            body.frame=CGRectMake(10,8,240.0,textHeight+10 );
            senderLabel.frame=CGRectMake(15,textHeight+15,250,13);
            senderLabel.text= [NSString stringWithFormat:@"%@: %@",self.cleanName,[ArisHelper dayLabelForMessage:chat.messageDate]];
            senderStartX=19;
        }
        else
        {
            //right aligned
            bgImage = [UIImage imageNamed:@"torn-paper4.png"] ;
            body.frame=CGRectMake(45,8,240.0,textHeight+10);
            senderLabel.frame=CGRectMake(65,textHeight+15,250,13);
            senderLabel.text= [NSString stringWithFormat:@"You %@" ,[ArisHelper dayLabelForMessage:chat.messageDate]];
            senderStartX=55;
            
        }
        
    }
    
    CGFloat heightForThisCell =  textHeight + 1000;
    UIImageView *balloonHolder;
    UIImageView *messageImageHolder;
    if([chat.direction isEqualToString:@"IN"]){
        if([chat.messageBody isEqualToString:@""]){
            messageImageHolder = [[UIImageView alloc] initWithFrame:CGRectMake(5,5,textHeight+40,textHeight+40 )];
            messageImageHolder.image = msgImage;
            balloonHolder = [[UIImageView alloc] initWithFrame:CGRectMake(5+textHeight+40,5,200,textHeight+40 )];
        }else{
            balloonHolder = [[UIImageView alloc] initWithFrame:CGRectMake(5,5,285,textHeight+40 )];
        }
    }else{
        if([chat.messageBody isEqualToString:@""]){
            messageImageHolder = [[UIImageView alloc] initWithFrame:CGRectMake(235,5,textHeight+40,textHeight+40 )];
            messageImageHolder.image = msgImage;
            balloonHolder = [[UIImageView alloc] initWithFrame:CGRectMake(35,5,285,textHeight+40 )];
        }else{
            balloonHolder = [[UIImageView alloc] initWithFrame:CGRectMake(35,5,285,textHeight+40 )];
        }
        
    }
    
    balloonHolder.image = bgImage;
    balloonHolder.backgroundColor=[UIColor clearColor];
    //Create the content holder
    UIView *cellContentView = [[UIView alloc] initWithFrame:CGRectMake(0,5,320,heightForThisCell)];
    [cellContentView addSubview:balloonHolder];
    [cellContentView addSubview:body];
    [cellContentView addSubview:senderLabel];
    [cellContentView addSubview:messageImageHolder];
    cell.backgroundView = cellContentView;
    cell.backgroundColor = [ArisHelper colorWithHexString:@"#F2F2F2"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
	return cell;
}




-(IBAction)callForKeyBoard:(id)sender{
    [UIView beginAnimations:@"moveView" context:nil];
    [UIView setAnimationDuration:0.3];
    self.sendView.frame = CGRectMake(0,ScreenHeight-300,ScreenWidth,86);
    [UIView commitAnimations];
    [self shortenTableView];
    [self.msgText becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
   
}


@end
