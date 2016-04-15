/*
 * Copyright (C) 2014 Xianwen Chen <xianwen@xianwenchen.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
 */

#import <Foundation/Foundation.h>

@interface XCPjsua : NSObject

/**
 * The callback for register pjsip account.
 */
typedef void (^RegisterCallBack)(BOOL success);

/**
 * Get the singleton XCPjsua.
 */
+ (XCPjsua *)sharedXCPjsua;
/**
 * Initialize and start pjsua.
 *
 * @param sipUser the sip username to be used for register
 * @param password the login password
 * @param sipDomain the domain of the sip register server
 *
 * @return When successful, returns 0.
 */
- (int)startPjsipAndRegisterOnServer:(char *)sipDomain
                        withUserName:(char *)sipUser
                         andPassword:(char *)password
                            callback:(RegisterCallBack)callback;

/**
 * Make VoIP call.
 *
 * @param destUri the uri of the receiver, something like "sip:192.168.43.106:5080"
 */
- (void)makeCallTo:(char*)destUri;
/**
 * End ALL ongoing VoIP calls
 */
- (void)endCall;

- (void)callAnswer:(NSInteger)calId;

- (void)callDecline;

- (void)destroy;

- (void)addUser:(char *)sipUser withPassword:(char *)password;

@property  (strong) RegisterCallBack registerCallBack;

@end
