//
//  PhidecksAppData.h
//  phidecks
//
//  Created by Meera on 7/9/12.
//  Copyright (c) 2012 XMinds. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhidecksApiWrapper.h"
#import "Deck.h"
#import "WriteConfigModel.h"

@interface PhidecksAppData : NSObject
{
	PhidecksApiWrapper *apiWrapper;
	NSString *server;
	NSString *username;
	NSString *password;
    NSMutableArray *my_decks;
    NSMutableArray *featured_decks;
    NSMutableDictionary *my_decks_dict;
    int selected_deck_id;
    
    WriteConfigModel *writeConfigData;
    BOOL popup_displayed;
    int timerValue;
    CGRect selectedDeckRect;
    UIImage* previewHomePage;
}

@property (nonatomic, retain) PhidecksApiWrapper *apiWrapper;
@property (nonatomic, retain) NSString *server;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) WriteConfigModel *writeConfigData;
@property (nonatomic, retain) UIImage* previewHomePage;
@property (assign) CGRect selectedDeckRect;
@property int selected_deck_id;
@property BOOL popup_displayed;
@property int timerValue;

- (void) setUsernameAndPassword:(NSString*) uname password:(NSString*) pwd;
- (void) authenticateAndLoadData;
- (void) addToMyDecks:(Deck*) deck;
- (void) addToFeaturedDecks:(Deck*) deck;

- (NSMutableArray *)my_decks;
- (NSMutableDictionary *)my_decks_dict;

@end
