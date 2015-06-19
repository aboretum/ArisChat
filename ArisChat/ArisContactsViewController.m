//
//  ArisContactsViewController.m
//  ArisChat
//
//  Created by Peter van de Put on 09/12/2013.
//  Copyright (c) 2013 YourDeveloper. All rights reserved.
//

#import "ArisContactsViewController.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "DDLog.h"
#import "ArisConversationViewController.h"
#import "ArisAddContactsViewController.h"
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif
@interface ArisContactsViewController ()<NSFetchedResultsControllerDelegate,UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
{
    NSFetchedResultsController *fetchedResultsController;
}
@property (nonatomic,strong) UITableView *mtableView;
@property (nonatomic,strong) ArisConversationViewController* conversationVC;
@property (nonatomic,strong) ArisAddContactsViewController* addContactsVC;
@end

@implementation ArisContactsViewController

- (AppDelegate *)appDelegate
{
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    
    //Add contact label
    UILabel *contactLabel = [[UILabel alloc] initWithFrame:CGRectMake((ScreenWidth-70)/2,25,70,86)];
    contactLabel.text = [NSString stringWithFormat:@"Contacts"];
    contactLabel.backgroundColor = [UIColor clearColor];
    contactLabel.font =   [UIFont fontWithName:@"Helvetica-Bold" size:16.0];
    contactLabel.textColor = [UIColor blackColor] ;
    [self.view addSubview:contactLabel];

    
    self.mtableView = [[UITableView alloc] initWithFrame:CGRectMake(0,86,ScreenWidth,ScreenHeight - 86) style:UITableViewStylePlain];
    
    self.mtableView .delegate=self;
    self.mtableView .dataSource=self;
    self.mtableView .rowHeight=45.0;
    
    self.mtableView .separatorStyle=UITableViewCellSeparatorStyleNone;
    self.mtableView .backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.mtableView];
    //Add the invite button
    UIButton* inviteButton = [[UIButton alloc] initWithFrame:CGRectMake(3*(ScreenWidth)/4,82,70,30)];
    inviteButton.backgroundColor=[UIColor clearColor];
    inviteButton.layer.cornerRadius = 5.0f;
    [inviteButton addTarget:self action:@selector(inviteUser:) forControlEvents:UIControlEventTouchUpInside];
    UILabel *inviteLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,70,30)];
    inviteLabel.backgroundColor=[UIColor clearColor];
    [inviteLabel setFont:[UIFont systemFontOfSize:16]];
    inviteLabel.text=@"Add Contact";
    inviteLabel.adjustsFontSizeToFitWidth=YES;
    inviteLabel.textAlignment=NSTextAlignmentCenter;
    inviteLabel.textColor= [ArisHelper colorWithHexString:@"0x663300" ];
    [inviteButton addSubview:inviteLabel];
    [self.view addSubview:inviteButton];
    
}
-(IBAction)inviteUser:(id)sender
{
  
    self.addContactsVC = [[ArisAddContactsViewController alloc] init];
    [self.addContactsVC setModalPresentationStyle:UIModalPresentationFullScreen];
    [self presentViewController:self.addContactsVC animated:YES completion:nil];
    
    //UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Enter the user name" message:@"e.g peter" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
    //alert.alertViewStyle = UIAlertViewStylePlainTextInput ;
    //[alert show];
}


#pragma mark delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.alertViewStyle == UIAlertViewStylePlainTextInput)
    {
        UITextField* username = [alertView textFieldAtIndex:0];
        NSString *jidString = [NSString stringWithFormat:@"%@@%@",username.text,kXMPPServer];
        NSLog(@"JID %@",jidString);
        [[self appDelegate] sendInvitationToJID:jidString withNickName:username.text];
    }
    
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark NSFetchedResultsController
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSFetchedResultsController *)fetchedResultsController
{
	if (fetchedResultsController == nil)
    {
		NSManagedObjectContext *moc = [[self appDelegate] managedObjectContext_roster];
		
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject"
		                                          inManagedObjectContext:moc];
		
		NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"sectionNum" ascending:YES];
		NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
		
		NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, sd2, nil];
		
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		[fetchRequest setEntity:entity];
		[fetchRequest setSortDescriptors:sortDescriptors];
		[fetchRequest setFetchBatchSize:10];
		
		fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
		                                                               managedObjectContext:moc
		                                                                 sectionNameKeyPath:@"sectionNum"
		                                                                          cacheName:nil];
		[fetchedResultsController setDelegate:self];
		
		
		NSError *error = nil;
		if (![fetchedResultsController performFetch:&error])
        {
			DDLogError(@"Error performing fetch: %@", error);
        }
        
    }
	
	return fetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	[self.mtableView reloadData];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITableViewCell helpers
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)configurePhotoForCell:(UITableViewCell *)cell user:(XMPPUserCoreDataStorageObject *)user
{
	// Our xmppRosterStorage will cache photos as they arrive from the xmppvCardAvatarModule.
	// We only need to ask the avatar module for a photo, if the roster doesn't have it.
	
	if (user.photo != nil)
    {
		cell.imageView.image = user.photo;
    }
	else
    {
		NSData *photoData = [[[self appDelegate] xmppvCardAvatarModule] photoDataForJID:user.jid];
        
		if (photoData != nil)
			cell.imageView.image = [UIImage imageWithData:photoData];
		else
			cell.imageView.image = [UIImage imageNamed:@"emptyavatar.jpg"];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITableView
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [[[self fetchedResultsController] sections] count];
}

- (NSString *)tableView:(UITableView *)sender titleForHeaderInSection:(NSInteger)sectionIndex
{
	NSArray *sections = [[self fetchedResultsController] sections];
	
	if (sectionIndex < [sections count])
    {
		id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:sectionIndex];
        
		int section = [sectionInfo.name intValue];
		switch (section)
        {
            case 0  : return @"Available";
            case 1  : return @"Away";
            default : return @"Offline";
        }
    }
	
	return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
	NSArray *sections = [[self fetchedResultsController] sections];
	
	if (sectionIndex < [sections count])
    {
		id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:sectionIndex];
		return sectionInfo.numberOfObjects;
    }
	
	return 0;
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
	
	XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:indexPath];
	
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,45)];
    UIImageView *avatarImage = [[UIImageView alloc] initWithFrame:CGRectMake(12,6,36,36)];
    
    avatarImage.layer.cornerRadius = avatarImage.frame.size.width/2;
    avatarImage.layer.masksToBounds = YES;
    avatarImage.layer.borderColor = [UIColor lightGrayColor].CGColor;
    avatarImage.layer.borderWidth = 1.0;
    
    UILabel *line1 = [[UILabel alloc] initWithFrame:CGRectMake(55,8,220,25)];
    line1.backgroundColor = [UIColor clearColor];
    line1.text=user.displayName;
    line1.font = [UIFont fontWithName:@"Helvetica-Bold" size:16.0];
    line1.textColor = [UIColor blackColor] ;
    [bgView addSubview:line1];
    
    
	//[self configurePhotoForCell:cell user:user];
    
    
	if (user.photo != nil)
    {
		avatarImage.image = user.photo;
    }
	else
    {
		NSData *photoData = [[[self appDelegate] xmppvCardAvatarModule] photoDataForJID:user.jid];
        
		if (photoData != nil)
			avatarImage.image = [UIImage imageWithData:photoData];
		else
			avatarImage.image = [UIImage imageNamed:@"emptyavatar.jpg"];
    }
    [bgView addSubview:avatarImage];
    cell.backgroundView = bgView;
    //Adding a dropshadow. Not sure about size and radius
    [cell.layer setMasksToBounds:NO];
    [cell.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [cell.layer setShadowOffset:CGSizeMake(15,1)];
    [cell.layer setShadowRadius:0.6];
    [cell.layer setShadowOpacity:0.2];
    cell.clipsToBounds = NO;
    
    cell.layer.zPosition = -indexPath.row;
	
	return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //Get our contact record
    XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    DDLogInfo(@"user %@",user.jidStr);
    
    if (self.conversationVC)
        self.conversationVC = nil;
    
    self.conversationVC = [[ArisConversationViewController alloc]init];
    [self.conversationVC showConversationForJIDString:user.jidStr];
    [self.navigationController pushViewController:self.conversationVC animated:YES];

    
}
- (void)viewWillDisappear:(BOOL)animated
{
	
	[super viewWillDisappear:animated];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
