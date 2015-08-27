//
//  ArisChattingStyleSettingViewController.m
//  ArisChat
//
//  Created by Wuchen Wang on 6/18/15.
//  Copyright (c) 2015 Wuchen Wang. All rights reserved.
//

#import "ArisChattingStyleSettingViewController.h"
#import "AppDelegate.h"
#import "Account.h"

@interface ArisChattingStyleSettingViewController () <NSFetchedResultsControllerDelegate,UITableViewDelegate, UITableViewDataSource>

@property (nonatomic,strong) UITableView *mtableView;
@property (nonatomic,strong) UITableViewCell *textAndImage;
@property (nonatomic,strong) UITableViewCell *ImageOnly;
@property (nonatomic,strong) NSNumber *text;
@end

@implementation ArisChattingStyleSettingViewController

- (AppDelegate *)appDelegate
{
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor=[UIColor whiteColor];
    self.mtableView = [[UITableView alloc] initWithFrame:CGRectMake(0,86,ScreenWidth,ScreenHeight-86) style:UITableViewStyleGrouped];
    
    self.mtableView.delegate=self;
    self.mtableView.dataSource = self;
    self.mtableView.rowHeight = 45;
    self.mtableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    self.mtableView.backgroundColor = [UIColor clearColor];
 
    
    //polulate chatting style option table cells
    self.textAndImage = [[UITableViewCell alloc] init];
    UILabel *tLabel = [[UILabel alloc]initWithFrame:CGRectInset(self.textAndImage.contentView.bounds, 15, 0)];
    tLabel.text = @"Text and Image";
    [self.textAndImage addSubview:tLabel];
    self.textAndImage.accessoryType = UITableViewCellAccessoryNone;
    self.textAndImage.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    
    self.ImageOnly= [[UITableViewCell alloc] init];
    UILabel *iLabel = [[UILabel alloc]initWithFrame:CGRectInset(self.ImageOnly.contentView.bounds, 15, 0)];
    iLabel.text = @"Image Only";
    [self.ImageOnly addSubview:iLabel];
    self.ImageOnly.accessoryType = UITableViewCellAccessoryNone;
    self.ImageOnly.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self loadData];
    
    
    [self.view addSubview:self.mtableView];
}

-(void)loadData
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Account"
                                              inManagedObjectContext:[self appDelegate].managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = nil;
    [fetchRequest setPredicate:predicate];
    NSError *error=nil;
    NSArray *fetchedObjects = [[self appDelegate].managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    for (NSManagedObject *obj in fetchedObjects)
    {
        Account *thisAccount = (Account *)obj;
        self.text = thisAccount.allowText;
    }
    
    //Save changes
    error = nil;
    if (![[self appDelegate].managedObjectContext save:&error])
    {
        NSLog(@"error saving");
    }
    
    NSLog(@"saved user default %@", [[NSUserDefaults standardUserDefaults] valueForKey:@"chattingStyleSetting"]);
    self.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"chattingStyleSetting"];
    if(self.text){
        self.textAndImage.accessoryType = UITableViewCellAccessoryCheckmark;
        self.ImageOnly.accessoryType = UITableViewCellAccessoryNone;
    }else{
        self.textAndImage.accessoryType = UITableViewCellAccessoryNone;
        self.ImageOnly.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITableView
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch(section)
    {
        case 0:  return 2;  // section 0 has 2 row
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
            case 0: return self.textAndImage;  // section 0, row 0
            case 1: return self.ImageOnly; // section 0, row 1
        }
        
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Account *account;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Account"
                                              inManagedObjectContext:[self appDelegate].managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = nil;
    [fetchRequest setPredicate:predicate];
    NSError *error=nil;
    NSArray *fetchedObjects = [[self appDelegate].managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if(fetchedObjects.count>0){
        account = [fetchedObjects objectAtIndex:0];
    }else{
        account = (Account *)[NSEntityDescription insertNewObjectForEntityForName:@"Account" inManagedObjectContext:[self appDelegate].managedObjectContext];
    }
    
    if(indexPath.row==0){
        if(self.text){
                
        }else{
            self.text = [NSNumber numberWithBool:YES];
        }
    }else{
        if(self.text){
            self.text = 0;
        }
    }
    
    account.allowText = self.text;
    [[NSUserDefaults standardUserDefaults] setObject:self.text forKey:@"chattingStyleSetting"];
    
    if (![[self appDelegate].managedObjectContext save:&error])
    {
        NSLog(@"error saving");
    }
    
    [self loadData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
