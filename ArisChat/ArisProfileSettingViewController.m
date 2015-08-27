//
//  ArisProfileSettingViewController.m
//  ArisChat
//
//  Created by Wuchen Wang on 6/23/15.
//  Copyright (c) 2015 Wuchen Wang. All rights reserved.
//

#import "ArisProfileSettingViewController.h"
#import "AppDelegate.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "XMPPvCardTemp.h"

@interface ArisProfileSettingViewController ()  <NSFetchedResultsControllerDelegate,UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    float prevLines;
}

@property (nonatomic,strong) UITableView *mtableView;
@property (nonatomic,strong) UITableViewCell *profileImage;
@property (nonatomic,strong) UITableViewCell *alias;
@property (nonatomic,strong) UIActionSheet *actions;
@property (nonatomic,strong) UIImagePickerController *imagePickerController;
@property (nonatomic,strong) UIImageView *avatarImage;
@property (nonatomic,strong) UIImage *image;
@end

@implementation ArisProfileSettingViewController 

- (AppDelegate *)appDelegate
{
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

#define IMG_SIZE 85
#define PROFILE_CELL_HEIGHT 105

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
    
    //polulate profile option cells
    self.profileImage = [[UITableViewCell alloc] init];
    
    self.profileImage.accessoryType = UITableViewCellAccessoryNone;
    self.profileImage.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //user profile image
    self.avatarImage = [[UIImageView alloc] initWithFrame:CGRectMake(15,10,IMG_SIZE,IMG_SIZE)];
    self.avatarImage.backgroundColor=[UIColor clearColor];
    self.avatarImage.contentMode=UIViewContentModeScaleAspectFill;
    
    UIImage *avImage;
    avImage = [UIImage imageWithData:[[NSUserDefaults standardUserDefaults]valueForKey:@"userAvatar"]];
    if(!avImage){
        avImage = [UIImage imageNamed:@"emptyavatar.jpg"];
    }
    
    self.avatarImage.image = avImage;
    self.avatarImage.layer.cornerRadius = self.avatarImage.frame.size.width/2;
    self.avatarImage.layer.masksToBounds = YES;
    self.avatarImage.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.avatarImage.layer.borderWidth = 1.0;
    [self.profileImage addSubview:self.avatarImage];
    
    
    UILabel *tLabel = [[UILabel alloc]initWithFrame:CGRectMake(IMG_SIZE+45, 0, ScreenWidth, PROFILE_CELL_HEIGHT)];
    
    tLabel.text = @"Profile Picture";
   
    [self.profileImage addSubview:tLabel];
    
    //button for image picker
    UIButton *newImage = [[UIButton alloc]initWithFrame:CGRectMake(15,10,IMG_SIZE,IMG_SIZE)];
    [newImage addTarget:self action:@selector(addImage) forControlEvents:UIControlEventTouchUpInside];
    newImage.backgroundColor = [UIColor clearColor];
    [self.profileImage addSubview:newImage];
    
   
    self.alias= [[UITableViewCell alloc] init];
    UITextField *aliasText = [[UITextField alloc] initWithFrame:CGRectInset(self.alias.contentView.bounds, 15, 0)];
    aliasText.text = @"Your Name";
    aliasText.delegate = self;
    [self.alias addSubview:aliasText];
    self.alias.accessoryType = UITableViewCellAccessoryNone;
    self.alias.selectionStyle = UITableViewCellSelectionStyleNone;

    [self.view addSubview:self.mtableView];
    
    
}

-(void)shortenTableView
{
    [UIView beginAnimations:@"moveView" context:nil];
    [UIView setAnimationDuration:0.2];
    self.mtableView.frame=CGRectMake(0,36,ScreenWidth,ScreenHeight-86);
    [UIView commitAnimations];
    prevLines=0.9375f;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITextField delegate methods and tableview move animation
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)showFullTableView
{
    
    [UIView beginAnimations:@"moveView" context:nil];
    [UIView setAnimationDuration:0.2];
    self.mtableView.frame=CGRectMake(0,86,ScreenWidth,ScreenHeight-86);
    [UIView commitAnimations];
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self showFullTableView];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSLog(@"textField delegate method called");
    [self shortenTableView];
    
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark touch events
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)addImage
{
    self.actions = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose From Library",@"Choose From ArisChat", nil];
    self.actions.tag = 1;
    [self.actions showInView:self.view];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch(indexPath.section)
    {
        case 0:
            switch(indexPath.row)
        {
            case 0: return IMG_SIZE+20;  // section 0, row 0
            case 1: return 45; // section 0, row 1
        }
            
    }
    return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch(indexPath.section)
    {
        case 0:
            switch(indexPath.row)
        {
            case 0: return self.profileImage;  // section 0, row 0
            case 1: return self.alias; // section 0, row 1
        }
            
    }
    return nil;
}


- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (popup.tag) {
        case 1: {
            switch (buttonIndex) {
                case 0:
                {
                    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                    imagePicker.delegate = self;
                    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
                        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                    }
                    NSString *desired  = (NSString *)kUTTypeImage;
                    if([[UIImagePickerController availableMediaTypesForSourceType:imagePicker.sourceType] containsObject:desired]){
                        imagePicker.mediaTypes = @[desired];
                    }else{
                        
                    }
                    imagePicker.allowsEditing = YES;
                    [self presentViewController:imagePicker animated:YES completion:NULL];
                }
                  
                    
                    
                    break;
                case 1:
                {
                    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                    imagePicker.delegate = self;
                    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
                        
                        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    }
                    NSString *desired  = (NSString *)kUTTypeImage;
                    if([[UIImagePickerController availableMediaTypesForSourceType:imagePicker.sourceType] containsObject:desired]){
                        imagePicker.mediaTypes = @[desired];
                    }else{
                        
                    }
                    imagePicker.allowsEditing = YES;
                    [self presentViewController:imagePicker animated:YES completion:NULL];
                }
                    break;
                case 2:
                    
                    break;
                case 3:
                    
                    break;
                case 4:
                    
                    break;
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *img = info[UIImagePickerControllerEditedImage];
    if(!img) img = info[UIImagePickerControllerOriginalImage];
    self.image = img;
    self.avatarImage.image = img;
    NSData *avatarData = UIImageJPEGRepresentation(self.image, 0.0);
    
    //save the photo to user default
    [[NSUserDefaults standardUserDefaults]setObject:avatarData forKey:@"userAvatar"];
    
    //save the photo with server
    NSXMLElement *vCardXML = [NSXMLElement elementWithName:@"vCard" xmlns:@"vcard-temp"];
    NSXMLElement *photoXML = [NSXMLElement elementWithName:@"PHOTO"];
    NSXMLElement *typeXML = [NSXMLElement elementWithName:@"TYPE" stringValue:@"image/jpg"];
    
    NSString *image64 = [self encodeToBase64String:self.image];
    
    NSXMLElement *binvalXML = [NSXMLElement elementWithName:@"BINVAL" stringValue:image64];
    
    [photoXML addChild:typeXML];
    [photoXML addChild:binvalXML];
    [vCardXML addChild:photoXML];
    
    XMPPvCardTemp *myvCardTemp = [[[self appDelegate] xmppvCardTempModule] myvCardTemp];
    
    if (myvCardTemp) {
        [myvCardTemp setPhoto:avatarData];
        [[[self appDelegate] xmppvCardTempModule] updateMyvCardTemp:myvCardTemp];
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (NSString *)encodeToBase64String:(UIImage *)image {
    return [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}


@end
