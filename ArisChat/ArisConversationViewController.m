//
//  ArisContactsViewController.h
//  ArisChat
//
//  Created by Wuchen Wang on 9/18/14.
//  Copyright (c) 2014 Wuchen Wang. All rights reserved.
//

#import "ArisConversationViewController.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "ContentButton.h"

#if DEBUG
//static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif
@interface ArisConversationViewController ()<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate>

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
    //Add a UITableView
    self.mtableView = [[UITableView alloc] initWithFrame:CGRectMake(0,80,ScreenWidth,ScreenHeight-80-ScreenWidth/4) style:UITableViewStylePlain];
    self.mtableView.delegate=self;
    self.mtableView.dataSource=self;
    
    self.msgText = [[UITextView alloc] initWithFrame:CGRectMake(47,ScreenWidth/4,220,22)];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  //abstract cell configuration method
{
    return nil;
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
    self.sendView.frame = CGRectMake(0,ScreenHeight-ScreenWidth/4,ScreenWidth,ScreenWidth/4+60);
    self.mtableView.frame=CGRectMake(0,80,ScreenWidth,ScreenHeight-80-ScreenWidth/4);
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

-(IBAction)sendMessage:(id)sender
{
    NSString *messageID = nil;
    if([sender isKindOfClass:[ContentButton class]]){
        ContentButton *button = (ContentButton *)sender;
        if(button.type){
            if([button.type isEqualToString:@"home"]){
                messageID = [NSString stringWithFormat:@"Aris1"];
            }else if([button.type isEqualToString:@"eat"]){
                messageID = [NSString stringWithFormat:@"Aris2"];
            }else if([button.type isEqualToString:@"yes"]){
                messageID = [NSString stringWithFormat:@"Aris3"];
            }else if([button.type isEqualToString:@"no"]){
                messageID = [NSString stringWithFormat:@"Aris4"];
            }
        }
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
