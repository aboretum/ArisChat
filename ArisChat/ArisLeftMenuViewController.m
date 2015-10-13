//
//  ArisLeftMenuViewController.m
//  ArisChat
//
//  Created by Wuchen Wang on 7/25/14.
//  Copyright (c) 2014 Wuchen Wang. All rights reserved.
//


#import "ArisLeftMenuViewController.h"
#import "ArisHelper.h"
#import "PaperFoldView.h"

#import <QuartzCore/QuartzCore.h>
#import "ArisMenuItem.h"


@interface ArisLeftMenuViewController()<UITableViewDataSource,UITableViewDelegate>
{

}


@property(nonatomic,strong) UITableView* mTableView;
@property(nonatomic,strong) PaperFoldView* paperFoldView;

@end

@implementation ArisLeftMenuViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor=[ArisHelper colorWithHexString:@"FBF6E9"];
    self.mTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,0,[self.view bounds].size.width,[[UIScreen mainScreen] bounds].size.height) style:UITableViewStylePlain];
    self.mTableView.delegate=self;
    self.mTableView.dataSource=self;
    self.mTableView.rowHeight= [self menuItemHeight];
    self.mTableView.backgroundColor=[UIColor clearColor];
    self.mTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
   
   
    //dropshadow
    self.view.clipsToBounds = NO;
    self.view.layer.masksToBounds = NO;
    CALayer *sublayer = [CALayer layer];
    sublayer.shadowOffset = CGSizeMake(0, 3);
    sublayer.shadowRadius = 5.0;
    sublayer.backgroundColor=[UIColor whiteColor].CGColor;
    sublayer.shadowColor = [UIColor whiteColor].CGColor;
    sublayer.shadowOpacity = 1.0;
    sublayer.frame = CGRectMake(tablewidth-3, 0, 4, [[UIScreen mainScreen] bounds].size.height);
    [self.view.layer addSublayer:sublayer];
    
    
    self.paperFoldView = [[PaperFoldView alloc] initWithFrame:CGRectMake(0,20,[self.view bounds].size.width,[self.view bounds].size.height-20)];
    [self.view addSubview:_paperFoldView];
    
    [self.paperFoldView setTopFoldContentView:self.mTableView topViewFoldCount:3 topViewPullFactor:1.5];
    
}

- (CGFloat)menuItemHeight
{
    return (ScreenHeight-20)/self.menuItems.count;
}


#pragma mark table view delegates


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LeftTableCell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        ArisMenuItem* item = [self.menuItems objectAtIndex:indexPath.row];
        
        UIView *cellContentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,tablewidth,[self menuItemHeight])];
        cellContentView.backgroundColor= [ArisHelper colorWithHexString:@"FBF6E9"];
        UIImage *bgImage = [[UIImage imageNamed:@"torn-paper.png"] stretchableImageWithLeftCapWidth:0  topCapHeight:15];
        UIImageView *paperHolder = [[UIImageView alloc] initWithFrame:CGRectMake(50,0,tablewidth,[self menuItemHeight])];
        paperHolder.image = bgImage;
        [cellContentView addSubview:paperHolder];
        
        if ([item.imageName length] >0)
        {
            UIImageView* imgView = [[UIImageView alloc] initWithFrame:CGRectMake(220,([self menuItemHeight]-tablewidth*0.3)/2,tablewidth*0.3,tablewidth*0.3)];
            imgView.backgroundColor=[UIColor clearColor];
            imgView.image=[UIImage imageNamed:item.imageName];
            imgView.contentMode = UIViewContentModeScaleAspectFill;
            [cellContentView addSubview:imgView];
        }
        
        
        
        UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(100,[self menuItemHeight]/2-20,tablewidth -50,40)];
        titleLabel.textColor=[ArisHelper colorWithHexString:item.textColorHexString];
        titleLabel.backgroundColor=[UIColor clearColor];
        [titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:20.0]];
        titleLabel.text = item.menuTitle;
        [cellContentView addSubview:titleLabel];
        
        //Adding a dropshadow. Not sure about size and radius
        [cell.layer setShadowColor:[[UIColor blackColor] CGColor]];
        [cell.layer setShadowOffset:CGSizeMake(1,1)];
        [cell.layer setShadowRadius:1.0];
        [cell.layer setShadowOpacity:1.0];
        
        cell.clipsToBounds = NO;
        cell.layer.zPosition = -indexPath.row;
        
        cell.backgroundView = cellContentView;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ArisMenuItem* item = [self.menuItems objectAtIndex:indexPath.row];
    [self.delegate leftMenuSelectionItemClick:item];
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.menuItems count]  ;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}@end
