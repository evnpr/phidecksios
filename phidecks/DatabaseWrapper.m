//
//  DatabaseWrapper.m
//  phidecks
//
//  Created by Harshad on 7/17/12.
//  Copyright (c) 2012 XMinds. All rights reserved.
//

#import "DatabaseWrapper.h"
#import "Deck.h"
#import "phidecksAppDelegate.h"

@implementation DatabaseWrapper
@synthesize database, activeUser;


- (void)createEditableCopyOfDatabaseIfNeeded {
    // First, test for existence.
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"db.rdb"];
	NSLog(@"%@", writableDBPath);
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (success) return;
	
    // The writable database does not exist, so copy the default to the appropriate location.
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"db.rdb"];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    if (!success) {
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
        return;
    }
}

- (void)initializeDatabase {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"db.rdb"];
	NSLog(@"%@", path);
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
            
    } else {
        // Even though the open failed, call close to properly clean up resources.
        sqlite3_close(database);
        NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
		NSLog(@"Failed to open database with message '%s'.", sqlite3_errmsg(database));
    }
}

- (BOOL) loadActiveUser {
 
    if( database == nil) 
		return NO;
    
	const char *sql =  [[NSString stringWithFormat:@"Select id,username,password from users where active = 1 limit 1"] UTF8String];
	sqlite3_stmt *stmt;
	if (sqlite3_prepare_v2(database, sql, -1, &stmt, NULL) != SQLITE_OK) {
		NSLog(@"%s", sqlite3_errmsg(database));
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
	
	if (sqlite3_step(stmt) == SQLITE_ROW) {
        activeUser = [[User alloc] init];
        [activeUser setUser_id:sqlite3_column_int(stmt,0)];
        [activeUser setUsername:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 1)]];
        [activeUser setPassword:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 2)]];
        [activeUser setActive:YES];
         
         NSLog(@"User: %@", activeUser);
		return YES;
	}
	else{
		sqlite3_reset(stmt);
		return NO;
	}
	return NO;
}

- (BOOL) loadDecksFromDatabaseForUser:(int) user_id{

    if( database == nil) 
		return NO;
    
    PhidecksAppDelegate *appDelegate = (PhidecksAppDelegate *)   [[UIApplication sharedApplication]delegate];
    
	const char *sql =  [[NSString stringWithFormat:@"Select id,deck_id,title, description, number_of_slides, tags, date, owner, thumbnail, date_created from user_decks where user_id = ?"] UTF8String];
    const char *sql_images =  [[NSString stringWithFormat:@"Select id,deck_id,slide_number,image_url,image_loaded,deck_photo from deck_slides where deck_id = ? order by slide_number ASC"] UTF8String];
    
	sqlite3_stmt *stmt;
	sqlite3_stmt *stmt_images;
	if (sqlite3_prepare_v2(database, sql, -1, &stmt, NULL) != SQLITE_OK) {
		NSLog(@"%s", sqlite3_errmsg(database));
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
    
    if (sqlite3_prepare_v2(database, sql_images, -1, &stmt_images, NULL) != SQLITE_OK) {
		NSLog(@"%s", sqlite3_errmsg(database));
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
    
    sqlite3_bind_int(stmt, 1, activeUser.user_id);
	int idx = 1;
	while(sqlite3_step(stmt) == SQLITE_ROW) {
        
        Deck* deck = [[Deck alloc] init];
        [deck setDeck_id:sqlite3_column_int(stmt,1)];
        [deck setTitle:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 2)]];
        [deck setDescription:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 3)]];
        [deck setSlidesnumber:sqlite3_column_int(stmt,4)];
        [deck setTags:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 5)]];
        NSData *data = [[NSData alloc] initWithBytes:sqlite3_column_blob(stmt, 8) length:sqlite3_column_bytes(stmt, 8)];
        [deck setThumbImage:[UIImage imageWithData:data]];
//        [deck setDate:date];
        [deck setOwner:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 7)]];

        idx++;
        BOOL image_in_db = YES;
        sqlite3_bind_int(stmt_images, 1, [deck deck_id]);
        while(sqlite3_step(stmt_images) == SQLITE_ROW) {
            if( sqlite3_column_int(stmt_images,4) ){
            }
            else{
                [deck addSlideImages:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt_images, 3)]];
                image_in_db = NO;
            }
        }
        
        [deck setImagesInDB:image_in_db];
        [appDelegate.appData addToMyDecks:deck];
        sqlite3_reset(stmt_images);
	}
	return YES;
}

- (BOOL)saveDeckToDatabase:(Deck*) deck{
    if( database == nil) 
		return NO;
    
    const char *sql_verify =  [[NSString stringWithFormat:@"select id from user_decks where deck_id = ? and user_id = ?"] UTF8String];
    const char *sql =  [[NSString stringWithFormat:@"Insert into user_decks(user_id,deck_id,title,description,number_of_slides,tags,owner,thumbnail ) values(?,?,?,?,?,?,?,?)"] UTF8String];
    const char *sql_deck_verify =  [[NSString stringWithFormat:@"select id from deck_slides where deck_id = ? and slide_number = ? and user_id = ?"] UTF8String];
    const char *sql_decks =  [[NSString stringWithFormat:@"Insert into deck_slides(deck_id,slide_number,image_url,image_loaded,user_id ) values(?,?,?,?,?)"] UTF8String];
    const char *sql_decks_photo =  [[NSString stringWithFormat:@"update deck_slides set deck_photo = ?, image_loaded = 1 where deck_id = ? and slide_number = ? and user_id = ?"] UTF8String];
    
    sqlite3_stmt *stmt_verify;
    sqlite3_stmt *stmt;
	sqlite3_stmt *stmt_decks;
	sqlite3_stmt *stmt_decks_verify;
    sqlite3_stmt *stmt_decks_photo;
    
    if (sqlite3_prepare_v2(database, sql_verify, -1, &stmt_verify, NULL) != SQLITE_OK) {
		NSLog(@"%s", sqlite3_errmsg(database));
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
    
	if (sqlite3_prepare_v2(database, sql, -1, &stmt, NULL) != SQLITE_OK) {
		NSLog(@"%s", sqlite3_errmsg(database));
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
    
    if (sqlite3_prepare_v2(database, sql_decks, -1, &stmt_decks, NULL) != SQLITE_OK) {
		NSLog(@"%s", sqlite3_errmsg(database));
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}

    if (sqlite3_prepare_v2(database, sql_deck_verify, -1, &stmt_decks_verify, NULL) != SQLITE_OK) {
		NSLog(@"%s", sqlite3_errmsg(database));
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
    
    if (sqlite3_prepare_v2(database, sql_decks_photo, -1, &stmt_decks_photo, NULL) != SQLITE_OK) {
		NSLog(@"%s", sqlite3_errmsg(database));
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}    
    
    
    sqlite3_bind_int(stmt_verify, 1, [deck deck_id]);
    sqlite3_bind_int(stmt_verify, 2, activeUser.user_id);
    if (sqlite3_step(stmt_verify) == SQLITE_ROW) { //record exists
        sqlite3_reset(stmt_verify);
        return YES;
    }
    
    
    NSData *imgData = UIImagePNGRepresentation([deck thumb_image]);

    sqlite3_bind_int(stmt, 1, activeUser.user_id);
    sqlite3_bind_int(stmt, 2, [deck deck_id]);
    sqlite3_bind_text(stmt, 3, [[deck title] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(stmt, 4, [[deck description] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(stmt, 5, [deck slidesnumber]);
    sqlite3_bind_text(stmt, 6, [[deck tags] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(stmt, 7, [[deck owner] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_blob(stmt, 8, [imgData bytes], [imgData length], NULL);
    int success = sqlite3_step(stmt);
    sqlite3_reset(stmt);
    if (success == SQLITE_ERROR) {
        return NO;
    }
    
    for( int i=0;i<[deck slidesnumber];i++){
        
        if( [[deck slideImageLinks] count] > i){
            sqlite3_bind_int(stmt_decks_verify, 1, [deck deck_id]);
            sqlite3_bind_int(stmt_decks_verify, 2, i);
            sqlite3_bind_int(stmt_decks_verify, 3, activeUser.user_id);
            if (sqlite3_step(stmt_decks_verify) == SQLITE_ROW) { //record exists
                UIImage* image = nil;
                if( [[deck slideImages] count] > i ){
                    image = [[deck slideImages] objectAtIndex:i];
                    if( image == nil){
                        continue;
                    }
                    else{
                        int image_in_db = sqlite3_column_int(stmt_decks_verify,1);
                        if(!image_in_db){
                            NSData *imgData = UIImagePNGRepresentation(image);
                            sqlite3_bind_blob(stmt_decks_photo, 1, [imgData bytes], [imgData length], NULL);
                            sqlite3_bind_int(stmt_decks_photo, 2, [deck deck_id]);
                            sqlite3_bind_int(stmt_decks_photo, 3, i);
                            sqlite3_bind_int(stmt_decks_photo, 4, activeUser.user_id);
                            sqlite3_step(stmt_decks_photo);
                            sqlite3_reset(stmt_decks_photo);
                        }
                    }
                }
            }
            else{
                sqlite3_bind_int(stmt_decks, 1, [deck deck_id]);
                sqlite3_bind_int(stmt_decks, 2, i);
                sqlite3_bind_text(stmt_decks, 3, [[[deck slideImageLinks] objectAtIndex:i] UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_int(stmt_decks, 4, 0);
                sqlite3_bind_int(stmt_decks, 5, activeUser.user_id);
                int success = sqlite3_step(stmt_decks);
                sqlite3_reset(stmt_decks);
                if (success == SQLITE_ERROR) {
                    continue;
                }
                else{
                    UIImage* image = nil;
                    if( [[deck slideImages] count] > i ){
                        image = [[deck slideImages] objectAtIndex:i];
                        if( image == nil){
                            continue;
                        }
                        else{
                            int image_in_db = sqlite3_column_int(stmt_decks_verify,1);
                            if(!image_in_db){
                                NSData *imgData = UIImagePNGRepresentation(image);
                                sqlite3_bind_blob(stmt_decks_photo, 1, [imgData bytes], [imgData length], NULL);
                                sqlite3_bind_int(stmt_decks_photo, 2, [deck deck_id]);
                                sqlite3_bind_int(stmt_decks_photo, 3, i);
                                sqlite3_bind_int(stmt_decks_photo, 4, activeUser.user_id);
                                sqlite3_step(stmt_decks_photo);
                                sqlite3_reset(stmt_decks_photo);
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    return YES;
}

- (BOOL) loadSlidesFromDatabase:(Deck*) deck {
    
    if( database == nil) 
		return NO;
    
    const char *sql_images =  [[NSString stringWithFormat:@"Select id,deck_id,slide_number,image_url,image_loaded,deck_photo from deck_slides where deck_id = ? order by slide_number ASC"] UTF8String];
    sqlite3_stmt *stmt_images;
    
    if (sqlite3_prepare_v2(database, sql_images, -1, &stmt_images, NULL) != SQLITE_OK) {
		NSLog(@"%s", sqlite3_errmsg(database));
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
    
    sqlite3_bind_int(stmt_images, 1, [deck deck_id]);
    
    BOOL loaded = YES;
    int idx = 1;
    while(sqlite3_step(stmt_images) == SQLITE_ROW) {
        if( sqlite3_column_int(stmt_images,4) ){
            NSData *data_image = [[NSData alloc] initWithBytes:sqlite3_column_blob(stmt_images, 5) length:sqlite3_column_bytes(stmt_images, 5)];
            [deck insertSlideImageAtPosition:[UIImage imageWithData:data_image] position:sqlite3_column_int(stmt_images,2)];
            NSLog(@"Loading from DB - %d of %d files",idx, [deck slidesnumber]);
        }
        else{
            [deck addSlideImages:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt_images, 3)]];
            loaded = NO;
        }
        idx++;
    }
    
    if( loaded == NO){
        [deck setImagesInDB:NO];
        [deck loadAllSlides:nil];
    }
    else{
        [deck setDeck_loaded:YES];
    }
    
    return YES;
}

- (BOOL)saveSlidesToDatabase:(Deck*) deck {
    
    if( database == nil) 
		return NO;
    
    const char *sql_deck_verify =  [[NSString stringWithFormat:@"select id, image_loaded from deck_slides where deck_id = ? and slide_number = ? and user_id = ?"] UTF8String];
    const char *sql_decks =  [[NSString stringWithFormat:@"Insert into deck_slides(deck_id,slide_number,image_url,image_loaded,user_id ) values(?,?,?,?,?)"] UTF8String];
    const char *sql_decks_photo =  [[NSString stringWithFormat:@"update deck_slides set deck_photo = ?, image_loaded = 1 where deck_id = ? and slide_number = ? and user_id = ?"] UTF8String];
    
    sqlite3_stmt *stmt_decks;
	sqlite3_stmt *stmt_decks_verify;
    sqlite3_stmt *stmt_decks_photo;
    
       
    if (sqlite3_prepare_v2(database, sql_decks, -1, &stmt_decks, NULL) != SQLITE_OK) {
		NSLog(@"%s", sqlite3_errmsg(database));
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
    
    if (sqlite3_prepare_v2(database, sql_deck_verify, -1, &stmt_decks_verify, NULL) != SQLITE_OK) {
		NSLog(@"%s", sqlite3_errmsg(database));
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
    
    if (sqlite3_prepare_v2(database, sql_decks_photo, -1, &stmt_decks_photo, NULL) != SQLITE_OK) {
		NSLog(@"%s", sqlite3_errmsg(database));
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
    
    for( int i=0;i<[deck slidesnumber];i++){
        
        UIImage* image = nil;
        if( [[deck slideImages] count] > i ){
            image = [[deck slideImages] objectAtIndex:i];
            if( image == nil){
                continue;
            }
        }
        else{
            continue;
        }
        
        sqlite3_bind_int(stmt_decks_verify, 1, [deck deck_id]);
        sqlite3_bind_int(stmt_decks_verify, 2, i);
        sqlite3_bind_int(stmt_decks_verify, 3, activeUser.user_id);
        if (sqlite3_step(stmt_decks_verify) == SQLITE_ROW) { //record exists
            
            int image_in_db = sqlite3_column_int(stmt_decks_verify,1);
            if( !image_in_db && image != nil){
                    NSData *imgData = UIImagePNGRepresentation(image);
                    sqlite3_bind_blob(stmt_decks_photo, 1, [imgData bytes], [imgData length], NULL);
                    sqlite3_bind_int(stmt_decks_photo, 2, [deck deck_id]);
                    sqlite3_bind_int(stmt_decks_photo, 3, i);
                    sqlite3_bind_int(stmt_decks_photo, 4, activeUser.user_id);
                    sqlite3_step(stmt_decks_photo);
                    sqlite3_reset(stmt_decks_photo);
            }
        }
        else{
            sqlite3_bind_int(stmt_decks, 1, [deck deck_id]);
            sqlite3_bind_int(stmt_decks, 2, i);
            sqlite3_bind_text(stmt_decks, 3, [[[deck slideImageLinks] objectAtIndex:i] UTF8String], -1, SQLITE_TRANSIENT);
            
            UIImage* image = [[deck slideImages] objectAtIndex:i];
            if( image == nil){
                sqlite3_bind_int(stmt_decks, 4, 0);
            }
            else{
                sqlite3_bind_int(stmt_decks, 4, 1);
            }
            sqlite3_bind_int(stmt_decks, 5, activeUser.user_id);
            int success = sqlite3_step(stmt_decks);
            sqlite3_reset(stmt_decks);
            if (success == SQLITE_ERROR) {
                continue;
            }
            else{
                if( image != nil){
                    NSData *imgData = UIImagePNGRepresentation(image);
                    sqlite3_bind_blob(stmt_decks_photo, 1, [imgData bytes], [imgData length], NULL);
                    sqlite3_bind_int(stmt_decks_photo, 2, [deck deck_id]);
                    sqlite3_bind_int(stmt_decks_photo, 3, i);
                    sqlite3_bind_int(stmt_decks_photo, 4, activeUser.user_id);
                    sqlite3_step(stmt_decks_photo);
                    sqlite3_reset(stmt_decks_photo);
                }
            }
        }
        sqlite3_reset(stmt_decks_verify);
    }
    
    return YES;
}

@end
