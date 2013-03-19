//
//  Deck.m
//  phidecks
//
//  Created by Meera on 7/10/12.
//  Copyright (c) 2012 XMinds. All rights reserved.
//

#import "Deck.h"
#import "phidecksAppDelegate.h"
#import "NSNotificationCenter+MainThread.h"

@implementation Deck

@synthesize thumb_image, position;

-(id) init {
	
	if (self = [super init]) 
	{
		slideImages = [[NSMutableArray alloc] init];
		slideImageLinks = [[NSMutableArray alloc] init];
        [self setThumb_local: YES];
        deck_loaded = NO;
        deck_from_db = NO;
        thumb_local = NO;
	}
	return self;
}

- (int)deck_id {
    return deck_id;
}

- (void)setDeck_id:(int)newValue {
    deck_id = newValue;
}

- (NSString *)title {
    return title;
}

- (void)setTitle:(NSString *)newValue {
    [title autorelease];
    title = [newValue retain];
}

- (NSString *)description {
    return description;
}

- (void)setDescription:(NSString *)newValue {
    [description autorelease];
    description = [newValue retain];
}

- (NSString *)tags {
    return tags;
}

- (void)setTags:(NSString *)newValue {
    [tags autorelease];
    tags = [newValue retain];
}

- (int)slidesnumber {
    return slidesnumber;
}

- (void)setSlidesnumber:(int)newValue {
    slidesnumber = newValue;
}

- (NSDate *)date {
    return date;
}

- (void)setDate:(NSDate *)newValue {
    [date autorelease];
    date = [newValue retain];
}

- (NSString *)owner {
    return owner;
}

- (void)setOwner:(NSString *)newValue {
    [owner autorelease];
    owner = [newValue retain];
}

- (NSString *)thumbnail {
    return thumbnail;
}

- (void)setThumbnail:(NSString *)newValue {
    [thumbnail autorelease];
    thumbnail = [newValue retain];
}

- (void) addSlideImages:(NSString*) image_url{
    
    [slideImageLinks addObject:image_url];
}

- (BOOL)thumb_local {
    return thumb_local;
}

- (void)setThumb_local:(BOOL)newValue {
    thumb_local = newValue;
}

- (void) loadThumbnail{
    if( thumb_local == YES ){
        [self setThumbImage: [UIImage imageNamed:thumbnail]];
    }
    else{
        UIImage* image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:thumbnail]]];
        [self setThumbImage:image];
        [image release];
    }
}

- (NSMutableArray *)slideImageLinks {
    return slideImageLinks;
}

- (NSMutableArray *)slideImages {
    return slideImages;
}


- (void) loadAllSlides:(id)sender {
    PhidecksAppDelegate *appDelegate = (PhidecksAppDelegate *)   [[UIApplication sharedApplication]delegate];
    if( !deck_loaded ){
        if( !images_in_db ){ 
            float current_perc = 0.0f;
            float increment = 1.0 / ([slideImageLinks count] + 1);
            
            for( int i=0;i<[slideImageLinks count];i++){
                NSLog(@"Downloading %d of %d files",i + 1,[slideImageLinks count]);
                UIImage* img = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[slideImageLinks objectAtIndex:i]]]];
                if( img != nil){
                    [slideImages insertObject:img atIndex:i];
                    [img release];
                }
                else{
                    [slideImages insertObject:[UIImage imageNamed:@"404.png"] atIndex:i];
                }
                current_perc += increment;
                appDelegate.HUD.progress = current_perc;
            }
            deck_loaded = YES;
            [appDelegate.dbWrapper saveSlidesToDatabase:self];
        }
        else{
            [appDelegate.dbWrapper loadSlidesFromDatabase:self];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:@"NSPhiDeckLoaded" object:nil ];

}

- (void) insertSlideImageAtPosition:(UIImage*) image position:(int) pos{

    [slideImages insertObject:image atIndex:pos];
}

- (BOOL)deck_loaded {
    return deck_loaded;
}

- (void)setDeck_loaded:(BOOL)newValue {
    deck_loaded = newValue;
}

- (UIImage *)thumb_image {
    return thumb_image;
}

- (void)setThumbImage:(UIImage *)newValue {
    [thumb_image autorelease];
    thumb_image = [newValue retain];
}

- (void) saveToDatabase {
    
    PhidecksAppDelegate *appDelegate = (PhidecksAppDelegate *)   [[UIApplication sharedApplication]delegate];
    [appDelegate.dbWrapper saveDeckToDatabase:self];
}

- (BOOL)images_in_db {
    return images_in_db;
}

- (void)setImagesInDB:(BOOL)newValue {
    images_in_db = newValue;
}

@end
