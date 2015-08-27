//
//  ArisImageOnlyConversationViewController.m
//  ArisChat
//
//  Created by Wuchen Wang on 6/22/15.
//  Copyright (c) 2015 Wuchen Wang. All rights reserved.
//

#import "ArisImageOnlyConversationViewController.h"
#import "AppDelegate.h"

@interface ArisImageOnlyConversationViewController ()

@end

@implementation ArisImageOnlyConversationViewController

- (AppDelegate *)appDelegate
{
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor=[ArisHelper colorWithHexString:@"FBF6E9"];
    
    UIImage *scroll = [UIImage imageNamed:@"paper-scroll.png"];

    UIImageView *imgHolder = [[UIImageView alloc] initWithFrame:CGRectMake(0,58,ScreenWidth,ScreenHeight-58)];
    
    imgHolder.image = scroll;
  
    [self.view addSubview:imgHolder];
    
    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,60,ScreenWidth,20)];
    self.statusLabel.backgroundColor = [UIColor clearColor];
    self.statusLabel.textColor=[ArisHelper colorWithHexString:@"0x663300" ];
    self.statusLabel.textAlignment=NSTextAlignmentCenter;
    self.statusLabel.text = self.cleanName;
    [self.statusLabel setFont:[UIFont systemFontOfSize:14]];
    [self.view addSubview:self.statusLabel];
    
    self.mtableView.frame = CGRectMake(0,80,ScreenWidth,ScreenHeight-80-20);
    self.mtableView.rowHeight=100;
    self.mtableView.scrollsToTop = NO;
    
    self.mtableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.mtableView.backgroundColor = [UIColor clearColor];
    [self.mtableView setSeparatorColor:[ArisHelper colorWithHexString:@"#F2F2F2"]];
    [self.view addSubview:self.mtableView];
    //need a view for sending messages with controls
    self.sendView = [[SendView alloc] initWithFrame:CGRectMake(0,ScreenHeight,ScreenWidth,ScreenWidth/4+20)];
    self.sendView.conversationViewController = self;
    self.sendView.backgroundColor=[UIColor clearColor];
    self.sendView.layer.borderColor = [UIColor clearColor].CGColor;
  
    
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
    
    circleButton = [[UIButton alloc] initWithFrame:CGRectMake(0,ScreenHeight-20,ScreenWidth,20)];
    circleButton.backgroundColor=[UIColor clearColor];
    [circleButton addTarget:self action:@selector(callForSendView:) forControlEvents:UIControlEventTouchUpInside];
    
    /**
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [circleButton addGestureRecognizer:longPress];
     **/
    
    circleButton.autoresizingMask=UIViewAutoresizingFlexibleTopMargin;
    circleButton.selected=NO;
    [self.view addSubview:circleButton];
    
    [self loadData];
    
}

-(void)callForSendView:(id)sender
{
    if([sender isKindOfClass:[UIButton class]] ){
        UIButton *button = sender;
        if(button.selected==NO){
            [UIView beginAnimations:@"moveView" context:nil];
            [UIView setAnimationDuration:0.2];
            self.sendView.frame = CGRectMake(0,ScreenHeight-ScreenWidth/4-20,ScreenWidth,ScreenWidth/4+20);
            [UIView commitAnimations];
            button.selected = YES;
            
        }else{
            [UIView beginAnimations:@"moveView" context:nil];
            [UIView setAnimationDuration:0.2];
            self.sendView.frame = CGRectMake(0,ScreenHeight,ScreenWidth,ScreenWidth/4+20);
            [UIView commitAnimations];
            button.selected=NO;
        }
    }
    
}


- (void)longPress:(UILongPressGestureRecognizer*)gesture {
    if ( gesture.state == UIGestureRecognizerStateEnded ) {
        NSLog(@"Long Press");
    }
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
        //Since they are now visible set the isNew to NO
        Chat *thisChat = (Chat *)obj;
        if([thisChat.messageBody isEqualToString:@"Aris1"]||[thisChat.messageBody isEqualToString:@"Aris2"]){
            thisChat.messageBody = @"";
        }
        if ([thisChat.isNew  boolValue])
            thisChat.isNew = [NSNumber numberWithBool:NO];
        if([thisChat.messageBody isEqualToString:@""])
            [self.chats addObject:obj];
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

#pragma mark screenupdates

//override super class UI update method to keep consistentcy.
-(void)showFullTableView
{
    [self scrollToBottomAnimated:YES];
    
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITableView
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return ScreenWidth*0.33+20;
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
    NSMutableDictionary *atts = [[NSMutableDictionary alloc] init];
    [atts setObject:systemFont forKey:NSFontAttributeName];
    
    XMPPUserCoreDataStorageObject *user = [[self appDelegate ].xmppRosterStorage userForJID:
                                           [XMPPJID jidWithString:chat.jidString]
                                                                                 xmppStream:[self appDelegate ].xmppStream
                                                                       managedObjectContext:[self appDelegate ]. managedObjectContext_roster];
    
    
    float textHeight = ScreenWidth*0.33;
    
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
    UITextView *senderLabel = [[UITextView alloc] init];
    senderLabel.backgroundColor=[UIColor clearColor];
    senderLabel.editable=NO;
    senderLabel.scrollEnabled=NO;
    senderLabel.font = [UIFont italicSystemFontOfSize:10.0f];
    senderLabel.textColor=[UIColor blackColor];
    senderLabel.textAlignment = NSTextAlignmentLeft;
    [senderLabel sizeToFit];
    
    UIImage *bgImage;
    UIImage *msgImage;
    if([chat.messageBody isEqualToString:@"Aris1"]||[chat.messageBody isEqualToString:@"Aris2"]){
        chat.messageBody = @"";
    }
    if ([chat.messageBody isEqualToString:@""]) {
        if ([chat.direction isEqualToString:@"IN"])
        { // left aligned
            
            if([chat.messageID isEqualToString:@"Aris1"]){
                
                msgImage = [UIImage imageNamed:@"home1.png"] ;
                body.frame=CGRectMake(10,13,240.0,textHeight+5);
            }else if([chat.messageID isEqualToString:@"Aris2"]){
                                msgImage = [UIImage imageNamed:@"eat.png"] ;
                body.frame=CGRectMake(10,13,240.0,textHeight+5);
            }
            
            senderLabel.frame=CGRectMake(ScreenWidth*0.2,ScreenWidth*0.21,textHeight*0.4,textHeight*0.4);
            senderLabel.text= [NSString stringWithFormat:@"%@",[ArisHelper dayLabelForMessage:chat.messageDate]];
            
        }
        else
        {
            //right aligned
            if([chat.messageID isEqualToString:@"Aris1"]){
               
                msgImage = [UIImage imageNamed:@"home1.png"] ;
                body.frame=CGRectMake(45,13,240.0,textHeight+5);
            }else if([chat.messageID isEqualToString:@"Aris2"]){
               
                msgImage = [UIImage imageNamed:@"eat.png"] ;
                body.frame=CGRectMake(45,13,240.0,textHeight+5);
            }
            
            senderLabel.frame=CGRectMake(ScreenWidth*0.66,ScreenWidth*0.21,textHeight*0.4,textHeight*0.4);
            senderLabel.text= [NSString stringWithFormat:@"%@",[ArisHelper dayLabelForMessage:chat.messageDate]];
        }
    }
    
    CGFloat heightForThisCell =  textHeight + 1000;
    UIImageView *balloonHolder;
    UIImageView *messageImageHolder;
    if([chat.direction isEqualToString:@"IN"]){
        if([chat.messageBody isEqualToString:@""]){
            bgImage = [self configurePhotoForCell:cell user:user];
            messageImageHolder = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth*0.33,5,textHeight,textHeight)];
            messageImageHolder.image = msgImage;
            balloonHolder = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth*0.065,ScreenWidth*0.21,textHeight*0.4,textHeight*0.4)];
        }
    }else{
        if([chat.messageBody isEqualToString:@""]){
            
            bgImage = [UIImage imageWithData:[[NSUserDefaults standardUserDefaults]valueForKey:@"userAvatar"]];
            if(!bgImage){
                bgImage = [UIImage imageNamed:@"emptyavatar.jpg"];
            }
            
            messageImageHolder = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth*0.33,5,textHeight,textHeight)];
            messageImageHolder.image = msgImage;
            balloonHolder = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth*0.805,ScreenWidth*0.21,textHeight*0.4,textHeight*0.4)];
        }
        
    }
    
    balloonHolder.image = bgImage;
    balloonHolder.backgroundColor=[UIColor clearColor];
    balloonHolder.layer.cornerRadius = 5.0;
    balloonHolder.layer.masksToBounds = YES;
    balloonHolder.layer.borderColor = [UIColor lightGrayColor].CGColor;
    balloonHolder.layer.borderWidth = 1.0;

    
    
    //Create the content holder
    UIView *cellContentView = [[UIView alloc] initWithFrame:CGRectMake(0,5,320,heightForThisCell)];
    [cellContentView addSubview:balloonHolder];
    [cellContentView addSubview:body];
    [cellContentView addSubview:senderLabel];
    [cellContentView addSubview:messageImageHolder];
    cell.backgroundView = cellContentView;
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
	return cell;
}

- (UIImage *)configurePhotoForCell:(UITableViewCell *)cell user:(XMPPUserCoreDataStorageObject *)user
{
    if (user.photo != nil)
    {
        return  user.photo;
    }
    else
    {
        NSData *photoData = [[[self appDelegate] xmppvCardAvatarModule] photoDataForJID:user.jid];
        
        if (photoData != nil)
            return  [UIImage imageWithData:photoData];
        else
            return  [UIImage imageNamed:@"emptyavatar.jpg"];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
