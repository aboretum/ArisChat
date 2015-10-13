//
//  ArisHelper.h
//  ArisChat
//
//  Created by Wuchen Wang on 7/25/14.
//  Copyright (c) 2014 Wuchen Wang. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface ArisHelper : NSObject

+ (UIColor *)colorWithHexString:(NSString *)stringToConvert;
+(BOOL )createUser:(NSString *)username password:(NSString *)password name:(NSString *)name email:(NSString *)email;
+(int)createUserREST:(NSString *)username password:(NSString *)password name:(NSString *)name email:(NSString *)email;
+(NSString *)dayLabelForMessage:(NSDate *)msgDate;
@end

