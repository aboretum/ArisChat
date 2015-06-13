//
//  ArisDefinitions.h
//  ArisChat
//
//  Created by Wuchen Wang on 7/21/14.
//  Copyright (c) 2014 Wuchen Wang. All rights reserved.
//

#ifndef ArisChat_ArisDefinitions_h
#define ArisChat_ArisDefinitions_h

//Menu Items
static const NSString* ArisSlideMenuStateNotificationEvent =
@ "ArisSlideMenuStateNotificationEvent";
static const float tablewidth = 270.0f;

#define kMenuHomeTag        @"kMenuHomeTag"
#define kMenuContactsTag    @"kMenuContactsTag"
#define kMenuChatsTag       @"kMenuChatsTag"
#define kMenuGroupChatTag   @"kMenuGroupChatTag"
#define kMenuSettingsTag    @"kMenuSettingsTag"


#define kXMPPmyJID              @"kXMPPmyJID"
#define kXMPPmyPassword         @"kXMPPmyPassword"

#define kxmppHTTPRegistrationUrl    @"http://openfire.yourdeveloper.net:9090/plugins/userService/userservice?type=add&secret=V3q2GdGx&username=%@&password=%@&name=%@&email=%@"

#define kXMPPServer             @"openfire.yourdeveloper.net"
#define kxmppProxyServer        @"openfire.yourdeveloper.net"
#define kxmppConferenceServer   @"conference.openfire.yourdeveloper.net"
#define kxmppSearchServer       @"search.openfire.yourdeveloper.net"

//Notifications
#define kChatStatus                 @"kChatStatus"
#define kNewMessage                 @"kNewMessage"

//ArisConversationViewController
#define lineHeight  16.0f
#define maxChatLines 4

#endif
