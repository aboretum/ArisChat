//
//  ArisSettingViewController.m
//  ArisChat
//
//  Created by Wuchen Wang on 6/18/15.
//  Copyright (c) 2015 Wuchen Wang. All rights reserved.
//

#import "ArisSettingViewController.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "DDLog.h"
#import "ArisChattingStyleSettingViewController.h"
#import "ArisProfileSettingViewController.h"
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

@interface ArisSettingViewController () <NSFetchedResultsControllerDelegate,UITableViewDelegate, UITableViewDataSource>
{
    NSFetchedResultsController *fetchedResultsController;
    
}

@property (nonatomic,strong) ArisChattingStyleSettingViewController *cssvc;
@property (nonatomic,strong) ArisProfileSettingViewController *psvc;
@property (nonatomic,strong) UITableView *mtableView;
@property (nonatomic,strong) UITableViewCell *profile;
@property (nonatomic,strong) UITableViewCell *chattingStyle;
@property (nonatomic,strong) UITableViewCell *chattingFigures;
@property (nonatomic,strong) UITableViewCell *social;

@end

@implementation ArisSettingViewController

- (AppDelegate *)appDelegate
{
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor=[UIColor whiteColor];
    
    //Add setting label
    UILabel *settingLabel = [[UILabel alloc] initWithFrame:CGRectMake((ScreenWidth-70)/2,25,70,86)];
    settingLabel.text = [NSString stringWithFormat:@"Settings"];
    settingLabel.backgroundColor = [UIColor clearColor];
    settingLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16.0];
    settingLabel.textColor = [UIColor blackColor] ;
    [self.view addSubview:settingLabel];
    
    
    self.mtableView = [[UITableView alloc] initWithFrame:CGRectMake(0,86,ScreenWidth,ScreenHeight-86) style:UITableViewStyleGrouped];
    
    self.mtableView.delegate=self;
    self.mtableView.dataSource = self;
    self.mtableView.rowHeight = 45;
    self.mtableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    self.mtableView.backgroundColor = [UIColor clearColor];
    
    //populate profile table cell
    self.profile = [[UITableViewCell alloc] init];
    UILabel *pLabel = [[UILabel alloc]initWithFrame:CGRectInset(self.profile.contentView.bounds, 15, 0)];
    pLabel.text = @"Profile";
    [self.profile addSubview:pLabel];
    
    //polulate chatting style table cell
    self.chattingStyle = [[UITableViewCell alloc] init];
    UILabel *sLabel = [[UILabel alloc]initWithFrame:CGRectInset(self.chattingStyle.contentView.bounds, 15, 0)];
    sLabel.text = @"Chatting Style";
    [self.chattingStyle addSubview:sLabel];
    self.chattingStyle.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    
    self.chattingFigures= [[UITableViewCell alloc] init];
    UILabel *figureLabel = [[UILabel alloc]initWithFrame:CGRectInset(self.chattingFigures.contentView.bounds, 15, 0)];
    figureLabel.text = @"Figure Options";
    [self.chattingFigures addSubview:figureLabel];
    
    self.social = [[UITableViewCell alloc] init];
    UILabel *aboutUsLabel = [[UILabel alloc] initWithFrame:CGRectInset(self.social.contentView.bounds, 15, 0)];
    aboutUsLabel.text = @"About Us";
    [self.social addSubview:aboutUsLabel];
    
    [self.view addSubview:self.mtableView];
    
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
#pragma mark UITableView
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch(section)
    {
        case 0:  return 1;  // section 0 has 1 row
        case 1:  return 2;  // section 1 has 1 row
        case 2:  return 1;  // section 2 has 1 row
        default: return 0;
    };
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch(indexPath.section)
    {
        case 0:
            switch(indexPath.row)
        {
            case 0: return self.profile;  // section 0, row 0 is profile
            
        }
        case 1:
            switch(indexPath.row)
        {
            case 0: return self.chattingStyle;      // section 1, row 0 is chatting style
            case 1: return self.chattingFigures;      // section 1, row 1 is chatting style
        }
        case 2:
            switch(indexPath.row)
        {
            case 0: return self.social;     // section 2, row 0 is chatting style
        }
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch(indexPath.section)
    {
        case 0:
            switch(indexPath.row)
        {
            case 0:
                NSLog(@"Section 0 row 0 selected");  // section 0, row 0 is profile
                if(self.psvc){
                    self.psvc = nil;
                }
                self.psvc = [[ArisProfileSettingViewController alloc] init];
                [self.navigationController pushViewController:self.psvc animated:YES];
        }
            break;
        case 1:
            switch(indexPath.row)
        {
            case 0:
                NSLog(@"section 1 row 0 selected");
                if(self.cssvc){
                    self.cssvc = nil;
                    
                }
                self.cssvc = [[ArisChattingStyleSettingViewController alloc]init];
                [self.navigationController pushViewController:self.cssvc animated:YES];
                
                
            case 1: ;      // section 1, row 1 is chatting style
        }
            break;
        case 2:
            switch(indexPath.row)
        {
            case 0: ;     // section 2, row 0 is chatting style
        }
            break;
    }
    
    
}


// Customize the section headings for each section
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch(section)
    {
        case 0: return @"User Information";
        case 1: return @"Configuration";
        case 2: return @"Social";
    }
    return nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
