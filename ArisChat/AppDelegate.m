//
//  AppDelegate.m
//  ArisChat
//
//  Created by Wuchen Wang on 7/20/14.
//  Copyright (c) 2014 Wuchen Wang. All rights reserved.
//

#import "AppDelegate.h"
#import "ArisMenuItem.h"
#import "GCDAsyncSocket.h"
#import "XMPP.h"
#import "XMPPReconnect.h"
#import "XMPPCapabilitiesCoreDataStorage.h"
#import "XMPPRosterCoreDataStorage.h"
#import "XMPPvCardAvatarModule.h"
#import "XMPPvCardCoreDataStorage.h"
#import "ArisContactsViewController.h"

#import "DDLog.h"
#import "DDTTYLogger.h"

#import <CFNetwork/CFNetwork.h>
#import <SpriteKit/SpriteKit.h>

#import "ArisSignInViewController.h"
#import "KeychainItemWrapper.h"
#import "ArisChatOverViewController.h"


// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif
@interface AppDelegate()<UIActionSheetDelegate,ArisSignInViewControllerDelegate>
{
    NSString* userPassword;
    ArisSignInViewController *signinViewController;
    ArisContactsViewController *contactsViewController;
    ViewController *viewController;
    ArisChatOverViewController *chatOverViewController;
    
}
@property (nonatomic, strong) XMPPStream *xmppStream;
@property (nonatomic, strong) XMPPReconnect *xmppReconnect;
@property (nonatomic, strong) XMPPRoster *xmppRoster;
@property (nonatomic, strong) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property (nonatomic, strong) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic, strong) XMPPvCardAvatarModule *xmppvCardAvatarModule;
@property (nonatomic, strong) XMPPvCardCoreDataStorage *xmppvCardStorage;
@property (nonatomic, strong) XMPPCapabilities *xmppCapabilities;
@property (nonatomic, strong) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
- (void)setupStream;
- (void)teardownStream;

- (void)goOnline;
- (void)goOffline;

@end

@implementation AppDelegate

@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Configure logging framework
	[DDLog addLogger:[DDTTYLogger sharedInstance]];
    // Setup the XMPP stream
	[self setupStream];
    //Setup our CoreData System
    __managedObjectContext = self.managedObjectContext;
    
    application.statusBarHidden = YES;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] ;
    self.rootViewController = [[ViewController alloc] init];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.rootViewController];
    //self.navigationController.navigationBarHidden = YES;
    self.window.rootViewController = self.navigationController;
    //Create left menu
    ArisMenuItem* homeItem = [[ArisMenuItem alloc]initWithTitle:@"Home" backgroundColorHexString:@"008080" textColorHexString:@"0x663300" viewControllerTAG:kMenuHomeTag imageName:@""];
    ArisMenuItem* item1 = [[ArisMenuItem alloc]initWithTitle:@"Chats" backgroundColorHexString:@"4682B4" textColorHexString:@"0x663300" viewControllerTAG:kMenuChatsTag imageName:@"chat"];
    ArisMenuItem* item2 = [[ArisMenuItem alloc]initWithTitle:@"Contacts" backgroundColorHexString:@"40E0D0" textColorHexString:@"0x663300" viewControllerTAG:kMenuContactsTag imageName:@"contact"];
    ArisMenuItem* item3 = [[ArisMenuItem alloc]initWithTitle:@"Group chat" backgroundColorHexString:@"EE82EE" textColorHexString:@"0x663300" viewControllerTAG:kMenuGroupChatTag imageName:@"groupicon"];
    ArisMenuItem* item4 = [[ArisMenuItem alloc]initWithTitle:@"Settings" backgroundColorHexString:@"6A5ACD" textColorHexString:@"0x663300" viewControllerTAG:kMenuSettingsTag imageName:@"settings"];
    
    //create left menu Controller
    self.leftMenuViewController = [[ArisLeftMenuViewController alloc] init];
    self.leftMenuViewController.delegate=self;
    self.leftMenuViewController.menuItems = [NSArray arrayWithObjects:homeItem,item1,item2,item3,item4,nil];
    //create and setup Container
    self.container = [ArisSlideMenuContainerViewController
                      containerWithCenterViewController:self.navigationController
                      leftMenuViewController:self.leftMenuViewController
                      rightMenuViewController:nil];
    
    self.window.rootViewController = self.container;
    self.container.delegate=self;
    [self.window makeKeyAndVisible];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    //
    
    
    if (![self connect])
    {
        
        signinViewController= [[ArisSignInViewController alloc]init];
        signinViewController.delegate=self;
        [self.navigationController pushViewController:signinViewController animated:NO];
    }
    
    return YES;
}

-(void)credentialsStored
{
    if (![self connect])
    {
        DDLogInfo(@"credentialsStored self connect failed");
    }
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Core Data
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSManagedObjectContext *)managedObjectContext_roster
{
	return [self.xmppRosterStorage mainThreadManagedObjectContext];
}

- (NSManagedObjectContext *)managedObjectContext_capabilities
{
	return [self.xmppCapabilitiesStorage mainThreadManagedObjectContext];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Private
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setupStream
{
	NSAssert(self.xmppStream == nil, @"Method setupStream invoked multiple times");
	
	// Setup xmpp stream
	//
	// The XMPPStream is the base class for all activity.
	// Everything else plugs into the xmppStream, such as modules/extensions and delegates.
    
	self.xmppStream = [[XMPPStream alloc] init];
    
 
	
#if !TARGET_IPHONE_SIMULATOR
	{
        // Want xmpp to run in the background?
        //
        // P.S. - The simulator doesn't support backgrounding yet.
        //        When you try to set the associated property on the simulator, it simply fails.
        //        And when you background an app on the simulator,
        //        it just queues network traffic til the app is foregrounded again.
        //        We are patiently waiting for a fix from Apple.
        //        If you do enableBackgroundingOnSocket on the simulator,
        //        you will simply see an error message from the xmpp stack when it fails to set the property.
        
        xmppStream.enableBackgroundingOnSocket = YES;
	}
#endif
	
	// Setup reconnect
	//
	// The XMPPReconnect module monitors for "accidental disconnections" and
	// automatically reconnects the stream for you.
	// There's a bunch more information in the XMPPReconnect header file.
	
	self.xmppReconnect = [[XMPPReconnect alloc] init];
	
	// Setup roster
	//
	// The XMPPRoster handles the xmpp protocol stuff related to the roster.
	// The storage for the roster is abstracted.
	// So you can use any storage mechanism you want.
	// You can store it all in memory, or use core data and store it on disk, or use core data with an in-memory store,
	// or setup your own using raw SQLite, or create your own storage mechanism.
	// You can do it however you like! It's your application.
	// But you do need to provide the roster with some storage facility.
	
	self.xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
    //	xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] initWithInMemoryStore];
	
	self.xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:self.xmppRosterStorage];
	
	self.xmppRoster.autoFetchRoster = YES;
	self.xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
	
	// Setup vCard support
	//
	// The vCard Avatar module works in conjuction with the standard vCard Temp module to download user avatars.
	// The XMPPRoster will automatically integrate with XMPPvCardAvatarModule to cache roster photos in the roster.
	
	self.xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
	self.xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:self.xmppvCardStorage];
	
	self.xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:self.xmppvCardTempModule];
	
	// Setup capabilities
	//
	// The XMPPCapabilities module handles all the complex hashing of the caps protocol (XEP-0115).
	// Basically, when other clients broadcast their presence on the network
	// they include information about what capabilities their client supports (audio, video, file transfer, etc).
	// But as you can imagine, this list starts to get pretty big.
	// This is where the hashing stuff comes into play.
	// Most people running the same version of the same client are going to have the same list of capabilities.
	// So the protocol defines a standardized way to hash the list of capabilities.
	// Clients then broadcast the tiny hash instead of the big list.
	// The XMPPCapabilities protocol automatically handles figuring out what these hashes mean,
	// and also persistently storing the hashes so lookups aren't needed in the future.
	//
	// Similarly to the roster, the storage of the module is abstracted.
	// You are strongly encouraged to persist caps information across sessions.
	//
	// The XMPPCapabilitiesCoreDataStorage is an ideal solution.
	// It can also be shared amongst multiple streams to further reduce hash lookups.
	
	self.xmppCapabilitiesStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
    self.xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:self.xmppCapabilitiesStorage];
    
    self.xmppCapabilities.autoFetchHashedCapabilities = YES;
    self.xmppCapabilities.autoFetchNonHashedCapabilities = NO;
    
	// Activate xmpp modules
    
	[self.xmppReconnect         activate:self.xmppStream];
	[self.xmppRoster            activate:self.xmppStream];
	[self.xmppvCardTempModule   activate:self.xmppStream];
	[self.xmppvCardAvatarModule activate:self.xmppStream];
	[self.xmppCapabilities      activate:self.xmppStream];
    
	// Add ourself as a delegate to anything we may be interested in
    
	[self.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
	[self.xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
	// Optional:
	//
	// Replace me with the proper domain and port.
	// The example below is setup for a typical google talk account.
	//
	// If you don't supply a hostName, then it will be automatically resolved using the JID (below).
	// For example, if you supply a JID like 'user@quack.com/rsrc'
	// then the xmpp framework will follow the xmpp specification, and do a SRV lookup for quack.com.
	//
	// If you don't specify a hostPort, then the default (5222) will be used.
	
    //	[xmppStream setHostName:@"talk.google.com"];
    //	[xmppStream setHostPort:5222];
	
    
	// You may need to alter these settings depending on the server you're connecting to
    customerCertEvaluation = YES;
	allowSelfSignedCertificates = YES;
	allowSSLHostNameMismatch = NO;
}

- (void)teardownStream
{
	[self.xmppStream removeDelegate:self];
	[self.xmppRoster removeDelegate:self];
	
	[self.xmppReconnect         deactivate];
	[self.xmppRoster            deactivate];
	[self.xmppvCardTempModule   deactivate];
	[self.xmppvCardAvatarModule deactivate];
	[self.xmppCapabilities      deactivate];
	
	[self.xmppStream disconnect];
	
	self.xmppStream = nil;
	self.xmppReconnect = nil;
    self.xmppRoster = nil;
	self.xmppRosterStorage = nil;
	self.xmppvCardStorage = nil;
    self.xmppvCardTempModule = nil;
	self.xmppvCardAvatarModule = nil;
	self.xmppCapabilities = nil;
	self.xmppCapabilitiesStorage = nil;
}

// It's easy to create XML elments to send and to read received XML elements.
// You have the entire NSXMLElement and NSXMLNode API's.
//
// In addition to this, the NSXMLElement+XMPP category provides some very handy methods for working with XMPP.
//
// On the iPhone, Apple chose not to include the full NSXML suite.
// No problem - we use the KissXML library as a drop in replacement.
//
// For more information on working with XML elements, see the Wiki article:
// https://github.com/robbiehanson/XMPPFramework/wiki/WorkingWithElements

- (void)goOnline
{
	XMPPPresence *presence = [XMPPPresence presence]; // type="available" is implicit
    
    NSString *domain = [self.xmppStream.myJID domain];
    
    //Google set their presence priority to 24, so we do the same to be compatible.
    
    if([domain isEqualToString:@"gmail.com"]
       || [domain isEqualToString:@"gtalk.com"]
       || [domain isEqualToString:@"talk.google.com"])
    {
        NSXMLElement *priority = [NSXMLElement elementWithName:@"priority" stringValue:@"24"];
        [presence addChild:priority];
    }
	
	[self.xmppStream sendElement:presence];
    [self.rootViewController updateStatus:@"Online"];
}

- (void)goOffline
{
	XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
	
	[self.xmppStream sendElement:presence];
    [self.rootViewController updateStatus:@"Offline"];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Connect/disconnect
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)connect
{
	if (![self.xmppStream isDisconnected]) {
		return YES;
	}
    NSString *myJID = [[NSUserDefaults standardUserDefaults] stringForKey:kXMPPmyJID];
    KeychainItemWrapper* keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"ArisCHAT" accessGroup:nil];
 	NSString *myPassword = [keychain objectForKey:(__bridge id)kSecValueData];
    userPassword = @"demo";
    
	
	myJID = @"demo@openfire.yourdeveloper.net";
    
	
	if (myJID == nil || myPassword == nil) {
		return NO;
	}
    
	[self.xmppStream setMyJID:[XMPPJID jidWithString:myJID]];
    
	NSError *error = nil;
	if (![self.xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error])
    {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error connecting"
		                                                    message:@"See console for error details."
		                                                   delegate:nil
		                                          cancelButtonTitle:@"Ok"
		                                          otherButtonTitles:nil];
		[alertView show];
        
		DDLogError(@"Error connecting: %@", error);
        
        return NO;
    }
    
	return YES;
}
- (void)xmppStreamDidRegister:(XMPPStream *)sender
{
    DDLogInfo(@"xmppStreamDidRegister: ");
}


- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error
{
    DDLogError(@"Error connecting: %@", error);
}
- (void)disconnect
{
	[self goOffline];
	[self.xmppStream disconnect];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPStream Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	

	if (allowSSLHostNameMismatch)
    {
		[settings setObject:[NSNull null] forKey:(NSString *)kCFStreamSSLPeerName];
    }
	else
    {
		// Google does things incorrectly (does not conform to RFC).
		// Because so many people ask questions about this (assume xmpp framework is broken),
		// I've explicitly added code that shows how other xmpp clients "do the right thing"
		// when connecting to a google server (gmail, or google apps for domains).
		
		NSString *expectedCertName = nil;
		
		NSString *serverDomain = self.xmppStream.hostName;
		NSString *virtualDomain = [self.xmppStream.myJID domain];
		
		if ([serverDomain isEqualToString:@"talk.google.com"])
        {
			if ([virtualDomain isEqualToString:@"gmail.com"])
            {
				expectedCertName = virtualDomain;
            }
			else
            {
				expectedCertName = serverDomain;
            }
        }
		else if (serverDomain == nil)
        {
			expectedCertName = virtualDomain;
        }
		else
        {
			expectedCertName = serverDomain;
        }
		
		if (expectedCertName)
        {
			[settings setObject:expectedCertName forKey:(NSString *)kCFStreamSSLPeerName];
        }
    }
    
    if(customerCertEvaluation){
        [settings setObject:@"YES" forKey:GCDAsyncSocketManuallyEvaluateTrust];
    }
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	isXmppConnected = YES;
	
	NSError *error = nil;
	
	if (![self.xmppStream authenticateWithPassword:userPassword error:&error])
    {
		DDLogError(@"Error authenticating: %@", error);
    }
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	[self goOnline];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    NSError *err=nil;
    ///check if inband registration is supported
    if (self.xmppStream.supportsInBandRegistration)
    {
        if (![self.xmppStream registerWithPassword:userPassword error:&err])
        {
            DDLogError(@"Oops, I forgot something: %@", error);
        }
    }
    else
    {
        DDLogError(@"Inband registration is not supported");
    }
    
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	return NO;
}

/*
 * This is only called if the stream is secured with settings that include:
 * - GCDAsyncSocketManuallyEvaluateTrust == YES
 * That is, if a delegate implements xmppStream:willSecureWithSettings:, and plugs in that key/value pair.
 */
- (void)xmppStream:(XMPPStream *)sender didReceiveTrust:(SecTrustRef)trust completionHandler:(void (^)(BOOL shouldTrustPeer))completionHandler
{
    /* Custom validation for your certificate on server should be performed */
    
    completionHandler(YES); // After this line, SSL connection will be established
}

-(void)updateCoreDataWithIncomingMessage:(XMPPMessage *)message
{
    //determine the sender
    XMPPUserCoreDataStorageObject *user = [self.xmppRosterStorage userForJID:[message from]
                                                                  xmppStream:self.xmppStream
                                                        managedObjectContext:[self managedObjectContext_roster]];
	
    Chat *chat = [NSEntityDescription
                  insertNewObjectForEntityForName:@"Chat"
                  inManagedObjectContext:self.managedObjectContext];
    chat.messageBody = [[message elementForName:@"body"] stringValue];
    chat.messageID = [[message elementForName:@"body"] stringValue];
    chat.messageDate = [NSDate date];
    chat.messageStatus=@"received";
    chat.direction = @"IN";
    chat.groupNumber=@"";
    chat.isNew = [NSNumber numberWithBool:YES];
    chat.hasMedia=[NSNumber numberWithBool:NO];
    chat.isGroupMessage=[NSNumber numberWithBool:NO];
    chat.jidString = user.jidStr;
    NSError *error = nil;
    NSLog(@"datasaved");
    if (![self.managedObjectContext save:&error])
    {
        NSLog(@"error saving");
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kNewMessage object:self userInfo:nil];
}


- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
	// A simple example of inbound message handling.
    
	if ([message isChatMessageWithBody])
    {
		XMPPUserCoreDataStorageObject *user = [self.xmppRosterStorage userForJID:[message from]
                                                                      xmppStream:self.xmppStream
                                                            managedObjectContext:[self managedObjectContext_roster]];
		
		NSString *body = [[message elementForName:@"body"] stringValue];
		NSString *displayName = [user displayName];
        
		if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
        {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Message from %@", displayName]
                                                                message:nil
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
            
            SKScene *myScene = [[SKScene alloc] initWithSize:CGSizeMake(100, 100)];
            myScene.scaleMode = SKSceneScaleModeAspectFill;
            
            SKView *msgView = [[SKView alloc] initWithFrame:CGRectMake(0, 0, 150, 150)];
            
            //Node for image
            SKSpriteNode *imgNode;
            
            if([body isEqualToString:@"Aris1"]){
                imgNode = [SKSpriteNode spriteNodeWithImageNamed:@"home1.png"];
                
            }else if([body isEqualToString:@"Aris2"]){
                imgNode = [SKSpriteNode spriteNodeWithImageNamed:@"eat.png"];
            }
            
            imgNode.position = CGPointMake(CGRectGetMidX(myScene.frame), CGRectGetMidY(myScene.frame));
            imgNode.size = CGSizeMake(100, 100);
            
            NSString *particlePath = [[NSBundle mainBundle] pathForResource:@"MyParticle" ofType:@"sks"];
            SKEmitterNode *emitterNode = [NSKeyedUnarchiver unarchiveObjectWithFile:particlePath];
            emitterNode.position = CGPointMake(CGRectGetMidX(myScene.frame), CGRectGetMidY(myScene.frame)-18);
            
            [myScene addChild:emitterNode];
            
            SKAction *scaleActionSmall = [SKAction scaleBy:0.8 duration:0.5];
            SKAction *scaleActionLarge = [SKAction scaleBy:1.25 duration:0.25];
            SKAction *sequence = [SKAction sequence:@[scaleActionSmall, scaleActionLarge]];
            
            [imgNode runAction:[SKAction repeatAction:sequence count:2]];
            [imgNode runAction:[SKAction playSoundFileNamed:@"pew-pew-lei.caf" waitForCompletion:NO]];
            [myScene addChild:imgNode];
            
            
            //msgView.showsFPS = YES;
            //msgView.showsNodeCount = YES;
            
            //UIColor *globalTint = [[[UIApplication sharedApplication] delegate] window].tintColor;
            myScene.backgroundColor = [SKColor colorWithRed:247/255.0f green:247/255.0f blue:247/255.0f alpha:1.0f];
            msgView.backgroundColor = [SKColor clearColor];
            msgView.layer.cornerRadius = 0.5f;
            [msgView presentScene:myScene];
            
            [alertView setValue:msgView forKey:@"accessoryView"] ;
            
            [alertView show];
            
            [self updateCoreDataWithIncomingMessage:message];
        }
		else
        {
			// We are not active, so use a local notification instead
			UILocalNotification *localNotification = [[UILocalNotification alloc] init];
			localNotification.alertAction = @"Ok";
			localNotification.alertBody = [NSString stringWithFormat:@"From: %@\n\n%@",displayName,body];
            
			[[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
        }
    }
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
	DDLogVerbose(@"%@: %@ - %@", THIS_FILE, THIS_METHOD, [presence fromStr]);
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	if (!isXmppConnected)
    {
		DDLogError(@"Unable to connect to server. Check xmppStream.hostName");
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPRosterDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)sendInvitationToJID:(NSString *)_jid withNickName:(NSString *)_nickName
{
    
    [self.xmppRoster addUser:[XMPPJID jidWithString:_jid] withNickname:_nickName];
    [self.xmppRoster subscribePresenceToUser:[XMPPJID jidWithString:_jid]];
}

- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{
    XMPPUserCoreDataStorageObject *user = [self.xmppRosterStorage userForJID:[presence from]
                                                                  xmppStream:self.xmppStream
                                                        managedObjectContext:[self managedObjectContext_roster]];
    DDLogVerbose(@"didReceivePresenceSubscriptionRequest from user %@ ", user.jidStr);
    [self.xmppRoster acceptPresenceSubscriptionRequestFrom:[presence from] andAddToRoster:YES];
}
- (void)xmppRoster:(XMPPRoster *)sender didReceiveBuddyRequest:(XMPPPresence *)presence
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	XMPPUserCoreDataStorageObject *user = [self.xmppRosterStorage userForJID:[presence from]
                                                                  xmppStream:self.xmppStream
                                                        managedObjectContext:[self managedObjectContext_roster]];
	
	NSString *displayName = [user displayName];
	NSString *jidStrBare = [presence fromStr];
	NSString *body = nil;
	
	if (![displayName isEqualToString:jidStrBare])
    {
		body = [NSString stringWithFormat:@"Buddy request from %@ <%@>", displayName, jidStrBare];
    }
	else
    {
		body = [NSString stringWithFormat:@"Buddy request from %@", displayName];
    }
	
	
	if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
    {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:displayName
		                                                    message:body
		                                                   delegate:nil
		                                          cancelButtonTitle:@"Not implemented"
		                                          otherButtonTitles:nil];
		[alertView show];
    }
	else
    {
		// We are not active, so use a local notification instead
		UILocalNotification *localNotification = [[UILocalNotification alloc] init];
		localNotification.alertAction = @"Not implemented";
		localNotification.alertBody = body;
		
		[[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    }
	
}


#pragma mark SlideMenu Delegate
-(void)leftMenuSelectionItemClick:(ArisMenuItem *)item
{
    
    if ([item.controllerTAG length]>0)
    {
        [self.container setMenuState:ArisSLideMenuStateClosed];
        
        if ([item.controllerTAG isEqualToString:kMenuHomeTag])
        {
            viewController = [[ViewController alloc]init];
            [self.navigationController pushViewController:viewController animated:YES];
            
        }
        else if ([item.controllerTAG isEqualToString:kMenuContactsTag])
        {
            //allocate the View Controller
            contactsViewController = [[ArisContactsViewController alloc]init];
            [self.navigationController pushViewController:contactsViewController animated:YES];
            
        }
        else if ([item.controllerTAG isEqualToString:kMenuChatsTag])
        {
            //allocate the View Controller
            chatOverViewController = [[ArisChatOverViewController alloc]init];
            [self.navigationController pushViewController:chatOverViewController animated:YES];
            
        }
    }
}


-(void)toggleLeftMenu
{
    if (self.container.menuState == ArisSLideMenuStateLeftMenuOpen)
    {
        [self.container setMenuState:ArisSLideMenuStateClosed];
    }
    else
    {
        [self.container setMenuState:ArisSLideMenuStateLeftMenuOpen];
    }
    
}
-(void)menuWillHide
{
    
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
#if TARGET_IPHONE_SIMULATOR
	DDLogError(@"The iPhone simulator does not process background network traffic. "
			   @"Inbound traffic is queued until the keepAliveTimeout:handler: fires.");
#endif
    
	if ([application respondsToSelector:@selector(setKeepAliveTimeout:handler:)])
    {
		[application setKeepAliveTimeout:600 handler:^{
			
			DDLogVerbose(@"KeepAliveHandler");
			
			// Do other keep alive stuff here.
		}];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark COREDATA
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
        [__managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        // subscribe to change notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_mocDidSaveNotification:) name:NSManagedObjectContextDidSaveNotification object:nil];
    }
    return __managedObjectContext;
}
//

- (void)_mocDidSaveNotification:(NSNotification *)notification
{
    NSManagedObjectContext *savedContext = [notification object];
    
    // ignore change notifications for the main MOC
    if (__managedObjectContext == savedContext)
    {
        return;
    }
    
    if (__managedObjectContext.persistentStoreCoordinator != savedContext.persistentStoreCoordinator)
    {
        // that's another database
        return;
    }
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        
        [__managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
    });
}
//
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"ChatModel" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"YDChat.sqlite"];   NSError *error = nil;
    
    //NSLog([storeURL absoluteString]);
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:@{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES} error:&error])
        
    {
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return __persistentStoreCoordinator;
}

- (void)dealloc
{
	[self teardownStream];
}

@end
