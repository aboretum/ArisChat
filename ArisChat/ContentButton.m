//
//  ContentButton.m
//  ArisChat
//
//  Created by Wuchen Wang on 6/28/15.
//  Copyright (c) 2015 Wuchen Wang. All rights reserved.
//

#import "ContentButton.h"

@implementation ContentButton


-(void) setContent:(NSString *)content
{
    self.type = content;
    NSString *imageName;
    if([content isEqualToString:@"eat"]){
        imageName = @"eat.png";
    }else if([content isEqualToString:@"home"]){
        imageName = @"home1.png";
    }else if([content isEqualToString:@"drink"]){
        imageName = @"eat.png";
    }else if([content isEqualToString:@"work"]){
        imageName = @"eat.png";
    }
    
    [self setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    self.autoresizingMask= UIViewAutoresizingFlexibleTopMargin;
    [self.layer setMasksToBounds:YES];
    self.layer.cornerRadius = 10.0f;
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.layer.borderWidth = 1;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
