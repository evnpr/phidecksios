//
//  PhidecksApiWrapper.h
//  phidecks
//
//  Created by Meera on 7/9/12.
//  Copyright (c) 2012 XMinds. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhidecksApiWrapper : NSObject
{
    
    
}
- (void) loadAllUserDecks;
- (void) authenticate:(NSString*) uname password:(NSString*) pwd;
- (void) authenticateAndLoadData:(NSString*) uname password:(NSString*) pwd;
- (void) parseAllDecksXML:(NSString*) xml;
@end
