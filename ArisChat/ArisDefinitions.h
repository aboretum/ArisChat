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
#define kChatSettingTag    @"chattingStyleSetting"
#define kDeviceToken    @"kDeviceToken"


#define kXMPPmyJID              @"kXMPPmyJID"
#define kXMPPmyPassword         @"kXMPPmyPassword"

#define kxmppHTTPRegistrationUrl    @"http://ec2-52-27-140-159.us-west-2.compute.amazonaws.com:9090/plugins/userService/userservice?type=add&secret=WCBoUNA2&username=%@&password=%@&name=%@&email=%@"
#define kxmppHTTPRegistrationUrlJson @"http://ec2-52-27-140-159.us-west-2.compute.amazonaws.com:9090/plugins/restapi/v1/users"

#define kXMPPServer             @"ec2-52-27-140-159.us-west-2.compute.amazonaws.com"
#define kxmppProxyServer        @"ec2-52-27-140-159.us-west-2.compute.amazonaws.com"
#define kxmppConferenceServer   @"conference.openfire.yourdeveloper.net"
#define kxmppSearchServer       @"search.openfire.yourdeveloper.net"

//Notifications
#define kChatStatus                 @"kChatStatus"
#define kNewMessage                 @"kNewMessage"

//ArisConversationViewController
#define lineHeight  16.0f
#define maxChatLines 4

#endif
