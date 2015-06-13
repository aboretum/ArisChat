//
//  ArisMenuItem.m
//  ArisChat
//
//  Created by Wuchen Wang on 7/25/14.
//  Copyright (c) 2014 Wuchen Wang. All rights reserved.
//



#import "ArisMenuItem.h"
@interface ArisMenuItem()

@property (nonatomic, strong) NSString *menuTitle;
@property (nonatomic, strong) NSString *backgroundColorHexString;
@property (nonatomic, strong) NSString *textColorHexString;
@property (nonatomic, strong) NSString* controllerTAG;
@property (nonatomic, strong) NSString* imageName;

@end

@implementation ArisMenuItem

-(id)initWithTitle:(NSString *)title backgroundColorHexString:(NSString *)bgColorHexString textColorHexString:(NSString *)txtColorHexString viewControllerTAG:(NSString *)tag  imageName:(NSString *)image
{self = [super init];
	if ( self != nil)
	{
        self.menuTitle=title;
        self.backgroundColorHexString=bgColorHexString;
        self.textColorHexString=txtColorHexString;
        self.controllerTAG=tag;
        self.imageName=image;
	}
	return self;
}
@end

