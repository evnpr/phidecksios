//
//  User.h
//  phidecks
//
//  Created by Meera on 7/17/12.
//  Copyright (c) 2012 XMinds. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject{
    
    int user_id;
    NSString* username;
    NSString* password;
    BOOL active;
}

- (int)user_id;

- (void)setUser_id:(int)newValue;

- (NSString *)username;

- (void)setUsername:(NSString *)newValue;

- (NSString *)password;

- (void)setPassword:(NSString *)newValue;

- (BOOL)active;

- (void)setActive:(BOOL)newValue;

@end
