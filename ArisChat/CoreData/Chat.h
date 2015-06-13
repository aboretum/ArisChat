//
//  Chat.h
//  ArisChat
//
//  Created by Wuchen Wang on 12/21/14.
//  Copyright (c) 2014 Wuchen Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Chat : NSManagedObject

@property (nonatomic, retain) NSString * direction;
@property (nonatomic, retain) NSString * filenameAsSent;
@property (nonatomic, retain) NSString * groupNumber;
@property (nonatomic, retain) NSNumber * hasMedia;
@property (nonatomic, retain) NSNumber * isGroupMessage;
@property (nonatomic, retain) NSNumber * isNew;
@property (nonatomic, retain) NSString * jidString;
@property (nonatomic, retain) NSString * localfileName;
@property (nonatomic, retain) NSString * mediaType;
@property (nonatomic, retain) NSString * messageBody;
@property (nonatomic, retain) NSDate * messageDate;
@property (nonatomic, retain) NSString * messageStatus;
@property (nonatomic, retain) NSString * mimeType;
@property (nonatomic, retain) NSString * roomJID;
@property (nonatomic, retain) NSString * roomName;
@property (nonatomic, retain) NSString * messageID;

@end
