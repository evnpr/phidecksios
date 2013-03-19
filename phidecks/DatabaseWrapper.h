//
//  DatabaseWrapper.h
//  phidecks
//
//  Created by Harshad on 7/17/12.
//  Copyright (c) 2012 XMinds. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "User.h"
#import "Deck.h"

@interface DatabaseWrapper : NSObject{
    
    sqlite3 *database;
    User* activeUser;
    
}

@property (readonly) sqlite3 *database;
@property (nonatomic, retain)     User* activeUser;;
- (void)initializeDatabase;
- (void)createEditableCopyOfDatabaseIfNeeded;
- (BOOL) loadActiveUser;
- (BOOL)loadDecksFromDatabaseForUser:(int) user_id;

- (BOOL)saveDeckToDatabase:(Deck*) deck;
- (BOOL)saveSlidesToDatabase:(Deck*) deck;
- (BOOL) loadSlidesFromDatabase:(Deck*) deck;
@end
