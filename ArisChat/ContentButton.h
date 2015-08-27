//
//  ContentButton.h
//  ArisChat
//
//  Created by Wuchen Wang on 6/28/15.
//  Copyright (c) 2015 Wuchen Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContentButton : UIButton

@property (nonatomic, strong) NSString *type;


-(void) setContent:(NSString *)content;

@end
