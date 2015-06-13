//
//  ArisConversationViewController.m
//  ArisChat
//
//  Created by Peter van de Put on 15/12/2013.
//  Copyright (c) 2013 YourDeveloper. All rights reserved.
//

#import "ArisConversationViewController.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#if DEBUG
//static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif
@interface ArisConversationViewController ()<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate>
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
@property (nonatomic,strong) UIView *sendView;
@property (nonatomic,strong) UITextView *msgText;
@end

@implementation ArisConversationViewController
- (AppDelegate *)appDelegate
{
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
	self.view.backgroundColor=[UIColor whiteColor];
    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,60,ScreenWidth,20)];
    self.statusLabel.backgroundColor = [UIColor colorWithRed:230/255.0f green:230/255.0f blue:231/255.0f alpha:1.0f];
    self.statusLabel.textColor=[ArisHelper colorWithHexString:@"0x663300" ];
    self.statusLabel.textAlignment=NSTextAlignmentCenter;
    self.statusLabel.text = self.cleanName;
    [self.statusLabel setFont:[UIFont systemFontOfSize:14]];
    [self.view addSubview:self.statusLabel];
    
    
    //Add a UITableView
    self.mtableView = [[UITableView alloc] initWithFrame:CGRectMake(0,80,ScreenWidth,ScreenHeight-80-56) style:UITableViewStylePlain];
    self.mtableView.delegate=self;
    self.mtableView.dataSource=self;
    self.mtableView.rowHeight=100;
    self.mtableView.scrollsToTop = NO;
    self.mtableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    self.mtableView.backgroundColor = [UIColor clearColor];
    [self.mtableView setSeparatorColor:[ArisHelper colorWithHexString:@"#F2F2F2"]];
    [self.view addSubview:self.mtableView];
    //need a view for sending messages with controls
    self.sendView = [[UIView alloc] initWithFrame:CGRectMake(0,ScreenHeight-56,ScreenWidth,86)];
    self.sendView.backgroundColor=[ArisHelper colorWithHexString:@"#F2F2F2"];
    self.sendView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.sendView.layer.borderWidth = 0.5;
    
    self.msgText = [[UITextView alloc] initWithFrame:CGRectMake(47,55,220,22)];
    self.msgText.backgroundColor = [UIColor whiteColor];
    self.msgText.textColor=[UIColor grayColor];
    self.msgText.font=[UIFont boldSystemFontOfSize:13];
    //self.msgText.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin;
    self.msgText.layer.cornerRadius = 5.0f;
    self.msgText.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.msgText.layer.borderWidth = 0.5;
    self.msgText.returnKeyType=UIReturnKeyDone;
    self.msgText.showsHorizontalScrollIndicator=NO;
    self.msgText.showsVerticalScrollIndicator=NO;
    
    self.msgText.delegate=self;
    
    [self.sendView addSubview:self.msgText];
    
    self.msgText.contentInset = UIEdgeInsetsMake(0,0,0,0);
    self.msgText.textContainerInset = UIEdgeInsetsMake(3,0,0,0);
     
    prevLines=0.9375f;
    //Add the send button
    sendButton = [[UIButton alloc] initWithFrame:CGRectMake(180,7,77,42)];
    sendButton.backgroundColor=[UIColor clearColor];
    [sendButton setBackgroundImage:[UIImage imageNamed:@"home1.jpg"] forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];
    sendButton.autoresizingMask=UIViewAutoresizingFlexibleTopMargin;
    [sendButton.layer setMasksToBounds:YES];
    sendButton.layer.cornerRadius = 10.0f;
    sendButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    sendButton.layer.borderWidth = 0.5;
    
    
    sendButton2 = [[UIButton alloc] initWithFrame:CGRectMake(57,7,77,42)];
    sendButton2.backgroundColor=[UIColor clearColor];
    [sendButton2 setBackgroundImage:[UIImage imageNamed:@"eat.jpg"] forState:UIControlStateNormal];
    [sendButton2 addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];
    sendButton2.autoresizingMask=UIViewAutoresizingFlexibleTopMargin;
    [sendButton2.layer setMasksToBounds:YES];
    sendButton2.layer.cornerRadius = 10.0f;
    sendButton2.layer.borderColor = [UIColor lightGrayColor].CGColor;
    sendButton2.layer.borderWidth = 0.5;
    [self.sendView addSubview:sendButton];
    [self.sendView addSubview:sendButton2];
    circleButton = [[UIButton alloc] initWithFrame:CGRectMake(275,8,36,36)];
    circleButton.backgroundColor=[UIColor clearColor];
    [circleButton addTarget:self action:@selector(callForKeyBoard:) forControlEvents:UIControlEventTouchUpInside];
    circleButton.autoresizingMask=UIViewAutoresizingFlexibleTopMargin;
    [circleButton setBackgroundImage:[UIImage imageNamed:@"smiley-face.png"] forState:UIControlStateNormal];
    circleButton.layer.cornerRadius=18.0f;
    circleButton.layer.borderColor=[UIColor clearColor].CGColor;
    circleButton.layer.borderWidth = 0.5;
    [self.sendView addSubview:circleButton];
    
    
    /*
    UILabel *sendLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,77,36)];
    sendLabel.backgroundColor=[UIColor clearColor];
    sendLabel.textAlignment = NSTextAlignmentCenter;
    sendLabel.font=[UIFont systemFontOfSize:14];
    sendLabel.textColor=[UIColor whiteColor];
    sendLabel.text = @"Home";
    sendLabel.adjustsFontSizeToFitWidth=YES;
    sendLabel.autoresizingMask=UIViewAutoresizingFlexibleTopMargin;
    
    [sendButton addSubview:sendLabel];
    sendLabel.text = @"Eat";
    [sendButton2 addSubview:sendLabel];
     */
    
    [self.view addSubview:self.sendView];
    
}
#pragma mark view appearance
-(void)viewWillAppear:(BOOL)animated
{
    //Add Observer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newMessageReceived:) name:kNewMessage  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusUpdateReceived:) name:kChatStatus  object:nil];
}
-(void)viewWillDisappear:(BOOL)animated
{
    //Remove notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kChatStatus  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNewMessage object:nil];
    
}
-(void)statusUpdateReceived:(NSNotification *)aNotification
{
    NSString *msgStr=  [[aNotification userInfo] valueForKey:@"msg"] ;
    msgStr = [msgStr stringByReplacingOccurrencesOfString:@"@" withString:@""];
    self.statusLabel.text = [NSString stringWithFormat:@"%@ %@",self.cleanName,msgStr];
}
-(void)newMessageReceived:(NSNotification *)aNotification
{
    //reload our data
    [self loadData];
}
-(void)showConversationForJIDString:(NSString *)jidString
{
    self.conversationJidString = jidString;
    self.cleanName = [jidString stringByReplacingOccurrencesOfString:kXMPPServer withString:@""];
    self.cleanName=[self.cleanName stringByReplacingOccurrencesOfString:@"@" withString:@""];
    self.statusLabel.text = self.cleanName;
    [self loadData];
}


-(void)loadData
{
    if (self.chats)
        self.chats =nil;
    self.chats = [[NSMutableArray alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Chat"
                                              inManagedObjectContext:[self appDelegate].managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"jidString == %@",self.conversationJidString];
    [fetchRequest setPredicate:predicate];
    NSError *error=nil;
    NSArray *fetchedObjects = [[self appDelegate].managedObjectContext executeFetchRequest:fetchRequest error:&error];
    for (NSManagedObject *obj in fetchedObjects)
    {
        [self.chats addObject:obj];
        //Since they are now visible set the isNew to NO
        Chat *thisChat = (Chat *)obj;
        if ([thisChat.isNew  boolValue])
            thisChat.isNew = [NSNumber numberWithBool:NO];
    }
    //Save changes
    error = nil;
    if (![[self appDelegate].managedObjectContext save:&error])
    {
        NSLog(@"error saving");
    }
    
    //reload the table view
    [self.mtableView reloadData];
    [self scrollToBottomAnimated:YES];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITableView
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Chat *currentChatMessage = (Chat *)[self.chats objectAtIndex:indexPath.row];
    
    if (![currentChatMessage.hasMedia boolValue])
    {
        
        UIFont* systemFont = [UIFont boldSystemFontOfSize:12];
        int width = 185.0, height = 10000.0;
        NSMutableDictionary *atts = [[NSMutableDictionary alloc] init];
        [atts setObject:systemFont forKey:NSFontAttributeName];
        
        CGRect textSize = [currentChatMessage.messageBody boundingRectWithSize:CGSizeMake(width, height)
                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:atts
                                                          context:nil];
        float textHeight = textSize.size.height;
        return textHeight+50;
    }
    else
    {
        return 200;
    }
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
	return self.chats.count;
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



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.msgText isFirstResponder])
        [self.msgText resignFirstResponder];
    [self showFullTableView];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark screenupdates
//when you start entering text, the table view should be shortened
-(void)shortenTableView
{
    [UIView beginAnimations:@"moveView" context:nil];
    [UIView setAnimationDuration:0.2];
    self.mtableView.frame=CGRectMake(0,80,ScreenWidth,210);
    [self scrollToBottomAnimated:YES];
    [UIView commitAnimations];
    prevLines=0.9375f;
}
//when finished entering text the table view should change to normal size
-(void)showFullTableView
{
    
    [UIView beginAnimations:@"moveView" context:nil];
    [UIView setAnimationDuration:0.2];
    self.sendView.frame = CGRectMake(0,ScreenHeight-56,ScreenWidth,86);
    self.mtableView.frame=CGRectMake(0,80,ScreenWidth,ScreenHeight-80-56);
    [self scrollToBottomAnimated:YES];
    [UIView commitAnimations];
    
}
- (void)scrollToBottomAnimated:(BOOL)animated {
    NSInteger bottomRow = [self.chats count] - 1;
    if (bottomRow >= 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:bottomRow inSection:0];
        [self.mtableView scrollToRowAtIndexPath:indexPath
                               atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}

#pragma mark UITextView Delegate
-(void)textViewDidChange:(UITextView *)textView
{
    
    UIFont* systemFont = [UIFont boldSystemFontOfSize:12];
    int width = 185.0, height = 10000.0;
    NSMutableDictionary *atts = [[NSMutableDictionary alloc] init];
    [atts setObject:systemFont forKey:NSFontAttributeName];
    
    CGRect textSize = [self.msgText.text boundingRectWithSize:CGSizeMake(width, height)
                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                   attributes:atts
                                                      context:nil];
    float textHeight = textSize.size.height;
    float lines = textHeight / lineHeight;
    // NSLog(@"textViewDidChange h: %0.f  lines %0.f ",textHeight,lines);
    if (lines >=4)
        lines=4;
    if (lines < 1.0)
        lines = 1.0;
    //Send your chat state
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    [message addAttributeWithName:@"type" stringValue:@"chat"];
    [message addAttributeWithName:@"to" stringValue:self.conversationJidString];
    NSXMLElement *status = [NSXMLElement elementWithName:@"composing" xmlns:@"http://jabber.org/protocol/chatstates"];
    [message addChild:status];
    [[self appDelegate].xmppStream sendElement:message];
    
    if (prevLines!=lines)
        [self shortenTableView];
    
    prevLines=lines;
}
-(void)textViewDidBeginEditing:(UITextView *)textView
{ [UIView beginAnimations:@"moveView" context:nil];
    [UIView setAnimationDuration:0.3];
    self.sendView.frame = CGRectMake(0,ScreenHeight-300,ScreenWidth,86);
    [UIView commitAnimations];
    [self shortenTableView];
    [self.msgText becomeFirstResponder];
    
    [self performSelector:@selector(setCursorToBeginning:) withObject:textView afterDelay:0.01];
    
    //Send your chat state
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    [message addAttributeWithName:@"type" stringValue:@"chat"];
    [message addAttributeWithName:@"to" stringValue:self.conversationJidString];
    NSXMLElement *status = [NSXMLElement elementWithName:@"composing" xmlns:@"http://jabber.org/protocol/chatstates"];
    [message addChild:status];
    [[self appDelegate].xmppStream sendElement:message];
    
}

- (void)setCursorToBeginning:(UITextView *)inView
{
    //you can change first parameter in NSMakeRange to wherever you want the cursor to move
    inView.selectedRange = NSMakeRange(0, 5);
}

#pragma mark send message
-(IBAction)callForKeyBoard:(id)sender{
    [UIView beginAnimations:@"moveView" context:nil];
    [UIView setAnimationDuration:0.3];
    self.sendView.frame = CGRectMake(0,ScreenHeight-300,ScreenWidth,86);
    [UIView commitAnimations];
    [self shortenTableView];
    [self.msgText becomeFirstResponder];
}
-(IBAction)sendMessage:(id)sender
{
    NSString *messageID = nil;
    
    if(sender == sendButton)
    {
        messageID = [NSString stringWithFormat:@"Aris1"];
    }else if(sender == sendButton2){
        messageID = [NSString stringWithFormat:@"Aris2"];
    }
    
    
    NSString *messageStr = self.msgText.text;
   
        //send chat message
        
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:messageID];
        NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
        [message addAttributeWithName:@"type" stringValue:@"chat"];
        [message addAttributeWithName:@"to" stringValue:self.conversationJidString];
        [message addChild:body];
        NSXMLElement *status = [NSXMLElement elementWithName:@"active" xmlns:@"http://jabber.org/protocol/chatstates"];
        [message addChild:status];
        
        [[self appDelegate].xmppStream sendElement:message];
        // We need to put our own message also in CoreData of course and reload the data
        Chat *chat = [NSEntityDescription
                      insertNewObjectForEntityForName:@"Chat"
                      inManagedObjectContext:[self appDelegate].managedObjectContext];
        chat.messageBody = messageStr;
        chat.messageDate = [NSDate date];
        chat.hasMedia=[NSNumber numberWithBool:NO];
        chat.isNew=[NSNumber numberWithBool:NO];
        chat.messageStatus=@"send";
        chat.direction = @"OUT";
        chat.messageID = messageID;
        chat.groupNumber=@"";
        chat.isGroupMessage=[NSNumber numberWithBool:NO];
        chat.jidString =  self.conversationJidString;
        
        NSError *error = nil;
        if (![[self appDelegate].managedObjectContext save:&error])
        {
            NSLog(@"error saving");
        }
    
    self.msgText.text=@"";
    if ([self.msgText isFirstResponder])
        [self.msgText resignFirstResponder];
    
    //Reload our data
    [self loadData];
    //Restore the Screen
    [self showFullTableView];
   
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
