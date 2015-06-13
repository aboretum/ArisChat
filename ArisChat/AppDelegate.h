//
//  AppDelegate.h
//  ArisChat
//
//  Created by Wuchen Wang on 7/20/14.
//  Copyright (c) 2014 Wuchen Wang. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "ArisLeftMenuViewController.h"
#import "ArisSlideMenuContainerViewController.h"
#import "ViewController.h"
#import <CoreData/CoreData.h>

#import "XMPPFramework.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate,ArisLeftMenuViewControllerDelegate,ArisSlideMenuContainerViewControllerDelegate,XMPPRosterDelegate>
{
    BOOL allowSelfSignedCertificates;
	BOOL allowSSLHostNameMismatch;
	BOOL customerCertEvaluation;
	BOOL isXmppConnected;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic)  UINavigationController* navigationController;
@property (strong,nonatomic)  ViewController *rootViewController;
@property(strong,nonatomic)   ArisLeftMenuViewController* leftMenuViewController;
@property(strong,nonatomic)   ArisSlideMenuContainerViewController *container;



//XMPP
@property (nonatomic, strong, readonly) XMPPStream *xmppStream;
@property (nonatomic, strong, readonly) XMPPReconnect *xmppReconnect;
@property (nonatomic, strong, readonly) XMPPRoster *xmppRoster;
@property (nonatomic, strong, readonly) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property (nonatomic, strong, readonly) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic, strong, readonly) XMPPvCardAvatarModule *xmppvCardAvatarModule;
@property (nonatomic, strong, readonly) XMPPvCardCoreDataStorage *xmppvCardStorage;
@property (nonatomic, strong, readonly) XMPPCapabilities *xmppCapabilities;
@property (nonatomic, strong, readonly) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
- (NSManagedObjectContext *)managedObjectContext_roster;
- (NSManagedObjectContext *)managedObjectContext_capabilities;
-(void)sendInvitationToJID:(NSString *)_jid withNickName:(NSString *)_nickName;
//CoreData
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
//public methods
- (BOOL)connect;
- (void)disconnect;


//public methods
#pragma mark Side Menu delegates
-(void)toggleLeftMenu;

@end