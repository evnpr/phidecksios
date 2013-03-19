//
//  NSNotificationCenter+MainThread.h
//  phidecks
//
//  Created by Harshad on 7/10/12.
//  Copyright (c) 2012 XMinds. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNotificationCenter (MainThread)

- (void)postNotificationOnMainThread:(NSNotification *)notification;
- (void)postNotificationOnMainThreadName:(NSString *)aName object:(id)anObject;
- (void)postNotificationOnMainThreadName:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo;

@end
