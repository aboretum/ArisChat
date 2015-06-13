//
//  ArisHelper.m
//  ArisChat
//
//  Created by Wuchen Wang on 7/25/14.
//  Copyright (c) 2014 Wuchen Wang. All rights reserved.
//

#import "ArisHelper.h"
#import "NSDate-Utilities.h"

@implementation ArisHelper

+ (UIColor *)colorWithHexString:(NSString *)stringToConvert{
    {
        NSString *noHashString = [stringToConvert stringByReplacingOccurrencesOfString:@"#" withString:@""]; // remove the #
        NSScanner *scanner = [NSScanner scannerWithString:noHashString];
        [scanner setCharactersToBeSkipped:[NSCharacterSet symbolCharacterSet]]; // remove + and $
        unsigned hex;
        if (![scanner scanHexInt:&hex]) return nil;
        int r = (hex >> 16) & 0xFF;
        int g = (hex >> 8) & 0xFF;
        int b = (hex) & 0xFF;
        return [UIColor colorWithRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:1.0f];
    }
}

+(BOOL )createUser:(NSString *)username password:(NSString *)password name:(NSString *)name email:(NSString *)email
{
    NSString *urlToCall = [NSString stringWithFormat:kxmppHTTPRegistrationUrl,username,password,name,email];
    NSURL *url = [NSURL URLWithString:urlToCall];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    [theRequest setHTTPMethod:@"GET"];
    NSError* error = nil;
    NSURLResponse* response;
    NSData* result = [NSURLConnection sendSynchronousRequest:theRequest  returningResponse:&response error:&error];
    NSString *responseString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
    if ([responseString isEqualToString:@"<result>ok</result>\r\n"])
    {
        return YES;
    }
    else {
        
        return  NO;
    }
}
+(NSString *)dayLabelForMessage:(NSDate *)msgDate
{
    NSString *retStr = @"";
    NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    NSString *time = [formatter stringFromDate:msgDate];
    
    if ([msgDate isToday])
    {
        retStr = [NSString stringWithFormat:@"today %@",time];
    }
    else if ([msgDate isYesterday])
    {
        retStr = [NSString stringWithFormat:@"yesterday %@" ,time];
    }
    else
    {
        [formatter setDateFormat:@"yyyy/MM/dd HH:mm"];
        NSString *time = [formatter stringFromDate:msgDate];
        retStr = [NSString stringWithFormat:@"%@" ,time];
    }
    return retStr;
}

@end
