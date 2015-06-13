//
//  ArisMenuItem.h
//  ArisChat
//
//  Created by Wuchen Wang on 7/25/14.
//  Copyright (c) 2014 Wuchen Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ArisMenuItem : NSObject

@property (nonatomic, readonly) NSString *menuTitle;
@property (nonatomic, readonly) NSString *backgroundColorHexString;
@property (nonatomic, readonly) NSString *textColorHexString;
@property (nonatomic, readonly) NSString* controllerTAG;
@property (nonatomic, readonly) NSString* imageName;

-(id)initWithTitle:(NSString *)title backgroundColorHexString:(NSString *)bgColorHexString textColorHexString:(NSString *)txtColorHexString viewControllerTAG:(NSString *)tag imageName:(NSString *)image;
@end