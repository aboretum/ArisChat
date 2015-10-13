
#import "DDLog.h"
#import "DDTTYLogger.h"
#import <CoreData/CoreData.h>
#import "ArisChatOverViewController.h"
#import "AppDelegate.h"
#import "ArisConversationViewController.h"
#import "ArisTextAndImageConversationViewController.h"
#import "ArisImageOnlyConversationViewController.h"
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif
@interface ArisChatOverViewController()<UITableViewDelegate,UITableViewDataSource>
{
    
}
@property (nonatomic,strong) ArisConversationViewController *conversationVC;
@property (nonatomic,strong) UITableView *mtableView;
@property (nonatomic,strong) NSMutableArray* chats;
@end
@implementation ArisChatOverViewController
- (AppDelegate *)appDelegate
{
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
	self.view.backgroundColor= [ArisHelper colorWithHexString:@"FBF6E9"];
    //Add chat label
    UILabel *chatLabel = [[UILabel alloc] initWithFrame:CGRectMake((ScreenWidth-50)/2,25,50,86)];
    chatLabel.text = [NSString stringWithFormat:@"Chats"];
    chatLabel.backgroundColor = [UIColor clearColor];
    chatLabel.font =   [UIFont fontWithName:@"Helvetica-Bold" size:16.0];
    chatLabel.textColor = [UIColor blackColor] ;
    [self.view addSubview:chatLabel];

    //Add a UITableView
    self.mtableView = [[UITableView alloc] initWithFrame:CGRectMake(0,86,ScreenWidth,ScreenHeight - 86) style:UITableViewStylePlain];
    self.mtableView.delegate=self;
    self.mtableView.dataSource=self;
    self.mtableView.rowHeight=86;
    self.mtableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    self.mtableView.backgroundColor = [ArisHelper colorWithHexString:@"#F2F2F2"];
    [self.mtableView setSeparatorColor:[UIColor whiteColor]];
    [self.view addSubview:self.mtableView];
    [self loadData];
    //Add Observer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newMessageReceived:) name:kNewMessage  object:nil];
    
}
-(IBAction)startNewConversation:(id)sender
{
    DDLogVerbose(@"startNewConversation");
}
-(void)newMessageReceived:(NSNotification *)aNotification
{
    DDLogVerbose(@"newMessageReceived in ArisChatOverViewController");
    //reload our data
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
    //skip Group messages
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isGroupMessage == %@",[NSNumber numberWithBool:NO]];
    //fetch distinct only jidString attribute
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    [fetchRequest setReturnsDistinctResults:YES];
    [fetchRequest setResultType:NSDictionaryResultType];
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:@"jidString"]];
    [fetchRequest setFetchBatchSize:50];
    
    NSError *error=nil;
    NSArray *fetchedObjects = [[self appDelegate].managedObjectContext executeFetchRequest:fetchRequest error:&error];
    for (NSManagedObject *obj in fetchedObjects)
    {
        NSMutableDictionary *found = (NSMutableDictionary *)obj;
        NSString *jid = [found valueForKey:@"jidString"];
        //only add the latest one
        [self.chats addObject:[self LatestChatRecordForJID:jid]];
    }
    //reload the table view
    [self.mtableView reloadData];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITableView
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

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
    
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                  reuseIdentifier:CellIdentifier];
    
	Chat* chat = [self.chats objectAtIndex:indexPath.row];
    
    XMPPUserCoreDataStorageObject *user = [[self appDelegate ].xmppRosterStorage userForJID:
                                           [XMPPJID jidWithString:chat.jidString]
                                                                                 xmppStream:[self appDelegate ].xmppStream
                                                                       managedObjectContext:[self appDelegate ]. managedObjectContext_roster];
    
 	UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,60)];
    bgView.backgroundColor=[ArisHelper colorWithHexString:@"FBF6E9"];
    if (![[chat isGroupMessage] boolValue])
    {
        UIImageView *avatarImage = [[UIImageView alloc] initWithFrame:CGRectMake(6,25,45,45)];
        avatarImage.backgroundColor=[UIColor clearColor];
        avatarImage.contentMode=UIViewContentModeScaleAspectFill;
        UIImage *avImage = [self configurePhotoForCell:cell user:user];
        avatarImage.image = avImage;
        avatarImage.layer.cornerRadius = 5.0;
        avatarImage.layer.masksToBounds = YES;
        avatarImage.layer.borderColor = [UIColor lightGrayColor].CGColor;
        avatarImage.layer.borderWidth = 1.0;
        [bgView addSubview:avatarImage];
        
        UIImageView *arrowView = [[UIImageView alloc] initWithFrame:CGRectMake(286,24,27,45)];
        arrowView.backgroundColor=[UIColor clearColor];
        arrowView.image=[UIImage imageNamed:@"arrow.png"];
        [bgView addSubview:arrowView];
        
        UIImageView *imageView= [[UIImageView alloc] initWithFrame:CGRectMake(200,12,60,60)];
        
        
        if([chat.messageID isEqualToString:@"Aris1"]){
            imageView.image = [UIImage imageNamed:@"home1.png"] ;
            
        }else if([chat.messageID isEqualToString:@"Aris2"]){
            imageView.image = [UIImage imageNamed:@"eat.png"] ;
            
        }else if([chat.messageID isEqualToString:@"Aris3"]){
            imageView.image = [UIImage imageNamed:@"YES.png"] ;
            
        }else if([chat.messageID isEqualToString:@"Aris4"]){
            imageView.image = [UIImage imageNamed:@"NO.png"] ;
            
        }
        
        [bgView addSubview:imageView];
        [self rotateImage:imageView duration:0.15 delay:0.0 curve:UIViewAnimationCurveLinear rotations:0.5*M_1_PI];
        
        UILabel *line1 = [[UILabel alloc] initWithFrame:CGRectMake(65,19,220,25)];
        line1.backgroundColor = [UIColor clearColor];
        NSString *cleanName = [chat.jidString stringByReplacingOccurrencesOfString:kXMPPServer withString:@""];
        cleanName=[cleanName stringByReplacingOccurrencesOfString:@"@" withString:@""];
        line1.text=cleanName;
        line1.font =   [UIFont fontWithName:@"Helvetica-Bold" size:16.0];
        line1.textColor = [UIColor blackColor] ;
        [bgView addSubview:line1];
        if ([chat.isNew  boolValue])
        {
            UIImageView *newImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"new.png"]];
            newImageView.backgroundColor=[UIColor clearColor];
            newImageView.frame=CGRectMake(248,16,28,14);
            [bgView addSubview:newImageView];
            //int numberOfNewMessages = [self countNewMessagesForJID:currentChatThread.jidString];
            UILabel *numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(257,13,30,15)];
            numberLabel.backgroundColor = [UIColor clearColor];
            numberLabel.textAlignment=NSTextAlignmentRight;
            numberLabel.font=[UIFont fontWithName:@"Helvetica-Bold" size:16.0];
            numberLabel.textColor=[UIColor blackColor];
            numberLabel.text=[NSString stringWithFormat:@"%i",[self countNewMessagesForJID:chat.jidString]];
            [bgView addSubview:numberLabel];
        }
        if([chat.messageID isEqualToString:@"Aris1"]||[chat.messageID isEqualToString:@"Aris2"]||[chat.messageID isEqualToString:@"Aris3"]||[chat.messageID isEqualToString:@"Aris4"]){
            chat.messageBody = @"";
        }
        NSString *textForSecondLine = [NSString stringWithFormat:@"%@: %@",[ArisHelper dayLabelForMessage:chat.messageDate],chat.messageBody];
        
        UILabel *line2 = [[UILabel alloc] initWithFrame:CGRectMake(65,49,220,16)];
        line2.backgroundColor = [UIColor clearColor];
        line2.text=textForSecondLine;
        line2.font =  [UIFont systemFontOfSize:12];
        line2.textColor = [UIColor blackColor] ;
        [bgView addSubview:line2];
    }
    
    //Adding a dropshadow. Not sure about size and radius
    [cell.layer setMasksToBounds:NO];
    [cell.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [cell.layer setShadowOffset:CGSizeMake(6,1)];
    [cell.layer setShadowRadius:0.6];
    [cell.layer setShadowOpacity:0.2];
    cell.clipsToBounds = NO;
    
    cell.layer.zPosition = -indexPath.row;

    cell.backgroundView = bgView;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		
		// Delete the conversation.
        Chat* chat = [self.chats objectAtIndex:indexPath.row];
        //this is only the latest chat within a conversation but we need to delete all chats in the conversation
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Chat"
                                                  inManagedObjectContext:[self appDelegate].managedObjectContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"jidString == %@",chat.jidString];
        [fetchRequest setPredicate:predicate];
        [fetchRequest setEntity:entity];
        NSError *error=nil;
        NSArray *fetchedObjects = [[self appDelegate].managedObjectContext executeFetchRequest:fetchRequest error:&error];
        for (NSManagedObject *obj in fetchedObjects)
        {
            //Delete this object
            [[self appDelegate].managedObjectContext deleteObject:obj];
        }
        //Save to CoreData
        error = nil;
        if (![[self appDelegate].managedObjectContext save:&error])
        {
            DDLogError(@"error saving");
        }
        //reload the array with data
        [self loadData];
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.conversationVC)
        self.conversationVC = nil;
    Chat* chat = [self.chats objectAtIndex:indexPath.row];
    if([[NSUserDefaults standardUserDefaults] valueForKey:@"chattingStyleSetting"]){
        self.conversationVC = [[ArisTextAndImageConversationViewController alloc]init];
    }else{
        self.conversationVC = [[ArisImageOnlyConversationViewController alloc]init];
    }
    
    [self.conversationVC showConversationForJIDString:chat.jidString];
    [self.navigationController pushViewController:self.conversationVC animated:YES];
    
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
#pragma mark helper methods
-(int)countNewMessagesForJID:(NSString *)jidString
{
    int ret=0;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Chat"
                                              inManagedObjectContext:[self appDelegate].managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"jidString == %@",jidString];
    [fetchRequest setPredicate:predicate];
    NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:@"messageDate" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sd,nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    NSError *error = nil;
    NSArray *fetchedObjects = [[self appDelegate].managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if ([fetchedObjects count]>0)
    {
        for (int i=0; i<[fetchedObjects count]; i++) {
            Chat *thisChat = (Chat *)[fetchedObjects objectAtIndex:i];
            if ([thisChat.isNew  boolValue])
                ret++;
        }
        
    }
    fetchedObjects=nil;
    fetchRequest=nil;
    return ret;
}
-(Chat *)LatestChatRecordForJID:(NSString *)jidString
{
    
    Chat *hist;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Chat"
                                              inManagedObjectContext:[self appDelegate].managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"jidString == %@",jidString];
    [fetchRequest setPredicate:predicate];
    NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:@"messageDate" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sd,nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    NSError *error = nil;
    NSArray *fetchedObjects = [[self appDelegate].managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if ([fetchedObjects count]>0)
    {
        hist  = (Chat *)[fetchedObjects objectAtIndex:0];
    }
    fetchedObjects=nil;
    fetchRequest=nil;
    return hist;
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
                         [self rotateImage:image duration:duration delay:delay curve:curve rotations:rotations];
                         ;
                     }];
    [UIView commitAnimations];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
