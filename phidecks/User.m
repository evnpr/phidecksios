//
//  User.m
//  phidecks
//
//  Created by Meera on 7/17/12.
//  Copyright (c) 2012 XMinds. All rights reserved.
//

#import "User.h"

@implementation User

- (int)user_id {
    return user_id;
}

- (void)setUser_id:(int)newValue {
    user_id = newValue;
}

- (NSString *)username {
    return username;
}

- (void)setUsername:(NSString *)newValue {
    [username autorelease];
    username = [newValue retain];
}

- (NSString *)password {
    return password;
}

- (void)setPassword:(NSString *)newValue {
    [password autorelease];
    password = [newValue retain];
}

- (BOOL)active {
    return active;
}

- (void)setActive:(BOOL)newValue {
    active = newValue;
}

@end
