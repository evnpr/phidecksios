//
//  Deck.h
//  phidecks
//
//  Created by Meera on 7/10/12.
//  Copyright (c) 2012 XMinds. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Deck : NSObject{
    int deck_id;
    NSString* title;
    NSString* description;
    NSString* tags;
    int slidesnumber;
    NSDate* date;
    NSString* owner;
    NSString* thumbnail;
    NSMutableArray* slideImageLinks;
    NSMutableArray* slideImages;
    BOOL thumb_local;
    BOOL deck_loaded;
    BOOL deck_from_db;
    BOOL images_in_db;
    UIImage* thumb_image;
    
    CGRect position;
}

- (int)deck_id;
- (void)setDeck_id:(int)newValue;

- (NSString *)title;
- (void)setTitle:(NSString *)newValue;

- (NSString *)description;
- (void)setDescription:(NSString *)newValue;

- (NSString *)tags;
- (void)setTags:(NSString *)newValue;

- (int)slidesnumber;
- (void)setSlidesnumber:(int)newValue;

- (NSDate *)date;
- (void)setDate:(NSDate *)newValue;

- (NSString *)owner;
- (void)setOwner:(NSString *)newValue;

- (NSString *)thumbnail;
- (void)setThumbnail:(NSString *)newValue;

- (void) addSlideImages:(NSString*) image_url;

- (BOOL)thumb_local;
- (void)setThumb_local:(BOOL)newValue;

- (UIImage *)thumb_image;
- (void)setThumbImage:(UIImage *)newValue;

- (NSMutableArray *)slideImageLinks;
- (NSMutableArray *)slideImages;
- (BOOL)deck_loaded;
- (void)setDeck_loaded:(BOOL)newValue;

- (void) loadThumbnail;
- (void) loadAllSlides:(id)sender;
- (void) insertSlideImageAtPosition:(UIImage*) image position:(int) pos;
- (void) saveToDatabase;

@property (nonatomic, retain) UIImage* thumb_image;
@property (assign) CGRect position;

- (BOOL)images_in_db;

- (void)setImagesInDB:(BOOL)newValue;

@end
