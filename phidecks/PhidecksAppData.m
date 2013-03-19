//
//  PhidecksAppData.m
//  phidecks
//
//  Created by Meera on 7/9/12.
//  Copyright (c) 2012 XMinds. All rights reserved.
//

#import "PhidecksAppData.h"

@implementation PhidecksAppData

@synthesize apiWrapper, server, username, selected_deck_id, popup_displayed, writeConfigData, timerValue, previewHomePage, selectedDeckRect;

-(id) init {
	
	if (self = [super init]) 
	{
		apiWrapper = [[PhidecksApiWrapper alloc] init];
		self.server = @"apps.phidecks.com/dev/index.php/api";
        my_decks = [[NSMutableArray alloc] init];
        featured_decks = [[NSMutableArray alloc] init];
        my_decks_dict = [[NSMutableDictionary alloc] init];
        writeConfigData = [[WriteConfigModel alloc] init];
        selected_deck_id = -1;
        popup_displayed = NO;
        timerValue = 1;
	}
	return self;
}

-(void) setUsernameAndPassword:(NSString*) uname password:(NSString*) pwd{
    username = uname;
    password = pwd;
}
- (void) authenticateAndLoadData {
    
    [apiWrapper authenticateAndLoadData:username password:password];
    
}

- (void) addToMyDecks:(Deck*) deck{
    
    [[self my_decks] addObject:deck];
    [[self my_decks_dict] setObject:deck forKey: [NSString stringWithFormat:@"%d", [deck deck_id]]];
    
}

- (void) addToFeaturedDecks:(Deck*) deck{
    
    [featured_decks addObject:deck];
}
- (NSMutableArray *)my_decks {
    return my_decks;
}

- (NSMutableDictionary *)my_decks_dict {
    return my_decks_dict;
}


@end
