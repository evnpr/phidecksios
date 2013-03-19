//
//  PhidecksApiWrapper.m
//  phidecks
//
//  Created by Meera on 7/9/12.
//  Copyright (c) 2012 XMinds. All rights reserved.
//

#import "PhidecksApiWrapper.h"
#import "PhidecksAppDelegate.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "TouchXML.h"
#import "Deck.h"

@implementation PhidecksApiWrapper


-(void) authenticate:(NSString*) uname password:(NSString*) pwd{
	
    PhidecksAppDelegate *appDelegate = (PhidecksAppDelegate *)   [[UIApplication sharedApplication]delegate];
    appDelegate.HUD.progress = 0.1f;
    appDelegate.HUD.labelText =  @"Authenticating...";
    
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/login",appDelegate.appData.server]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request.shouldPresentCredentialsBeforeChallenge = YES;
    [request addBasicAuthenticationHeaderWithUsername:uname andPassword:pwd];
    request.userInfo = [NSDictionary dictionaryWithObject:@"authenticate" forKey:@"type"];
    [request setDelegate:self];
    [request startAsynchronous];
    
}

-(void) authenticateAndLoadData:(NSString*) uname password:(NSString*) pwd{
    
    [self authenticate:uname password:pwd];
}

-(void) loadAllUserDecks {

    PhidecksAppDelegate *appDelegate = (PhidecksAppDelegate *)   [[UIApplication sharedApplication]delegate];
    appDelegate.HUD.progress = 0.2f;
    appDelegate.HUD.labelText =  @"Loading your decks...";

    NSLog(@"Sending request to load the decks");
	
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/getall/id/%@",appDelegate.appData.server, appDelegate.appData.username]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request.userInfo = [NSDictionary dictionaryWithObject:@"load-all-decks" forKey:@"type"];
    [request setDelegate:self];
    [request startAsynchronous];
}

- (void) parseAllDecksXML:(NSString*) xml{
    
    PhidecksAppDelegate *appDelegate = (PhidecksAppDelegate *)   [[UIApplication sharedApplication]delegate];
    
    NSLog(@"Parsing the XML now..");
    
    NSError *error;
/*    NSString *xml2 = @"<?xml version='1.0' encoding='utf-8'?><decks><deck><id>18</id><title>ARA01032012.pdf</title><price>0</price><description/><slidesnumber>5</slidesnumber><tags/><date>0000-00-00</date><owner>lekshmi</owner><thumbnail>http://apps.phidecks.com/dev/uploaded/ARA01032012.pdf-0.png</thumbnail><slides><slide order='1'><image>http://apps.phidecks.com/dev/uploaded/ARA01032012.pdf-0.png</image></slide><slide order='2'><image>http://apps.phidecks.com/dev/uploaded/ARA01032012.pdf-1.png</image></slide><slide order='3'><image>http://apps.phidecks.com/dev/uploaded/ARA01032012.pdf-2.png</image></slide><slide order='4'><image>http://apps.phidecks.com/dev/uploaded/ARA01032012.pdf-3.png</image></slide><slide order='5'><image>http://apps.phidecks.com/dev/uploaded/ARA01032012.pdf-4.png</image></slide></slides></deck><deck><id>19</id><title>ARA01032012.pdf</title><price>0</price><description/><slidesnumber>5</slidesnumber><tags/><date>0000-00-00</date><owner>lekshmi</owner><thumbnail>http://apps.phidecks.com/dev/uploaded/ARA01032012.pdf-0.png</thumbnail><slides><slide order='1'><image>http://apps.phidecks.com/dev/uploaded/ARA01032012.pdf-0.png</image></slide><slide order='2'><image>http://apps.phidecks.com/dev/uploaded/ARA01032012.pdf-1.png</image></slide><slide order='3'><image>http://apps.phidecks.com/dev/uploaded/ARA01032012.pdf-2.png</image></slide><slide order='4'><image>http://apps.phidecks.com/dev/uploaded/ARA01032012.pdf-3.png</image></slide><slide order='5'><image>http://apps.phidecks.com/dev/uploaded/ARA01032012.pdf-4.png</image></slide></slides></deck></decks>";
*/
    CXMLDocument *parser = [[[CXMLDocument alloc] initWithXMLString:xml options:0 error:&error] autorelease];
	NSArray *resultNodes = NULL;
	resultNodes = [parser nodesForXPath:@"//decks/deck" error:&error];
    NSDateFormatter *format = [[[NSDateFormatter alloc] init] autorelease];
	[format setDateFormat:@"yyy-mm-dd"];
    int index = 0;
    int idx = 0;
    int count = [resultNodes count];
    NSLog(@"%d decks found..", count);
    float current_perc = 0.0f;
    float increment = 1.0 / count;
	if( [resultNodes count] > 0){
		for(CXMLNode *node in resultNodes ){
            index++;
            if( index >= 4)
                index = 1;
			NSArray* nodes = [node nodesForXPath:@"id" error:nil];
			NSString* str_deck_id = [[nodes objectAtIndex:0] stringValue];
            int deck_id = [str_deck_id intValue];
            
            nodes = [node nodesForXPath:@"title" error:nil];
			NSString* title = [[nodes objectAtIndex:0] stringValue];
            
            nodes = [node nodesForXPath:@"description" error:nil];
			NSString* description = [[nodes objectAtIndex:0] stringValue];
            
            nodes = [node nodesForXPath:@"slidesnumber" error:nil];
			NSString* str_slidesnumber = [[nodes objectAtIndex:0] stringValue];
            int slidesnumber = [str_slidesnumber intValue];
            
            nodes = [node nodesForXPath:@"tags" error:nil];
			NSString* tags = [[nodes objectAtIndex:0] stringValue];
            
            nodes = [node nodesForXPath:@"date" error:nil];
			NSString* date_created = [[nodes objectAtIndex:0] stringValue];
			NSDate *date = [format dateFromString:date_created];
            
            nodes = [node nodesForXPath:@"owner" error:nil];
			NSString* owner = [[nodes objectAtIndex:0] stringValue];
            
            nodes = [node nodesForXPath:@"thumbnail" error:nil];
			NSString* thumbnail = [[nodes objectAtIndex:0] stringValue];
            //NSString* thumbnail = [NSString stringWithFormat:@"thumb-%d.png", index];
            
            NSMutableArray *arr_images = [[NSMutableArray alloc] init];
            nodes = [node nodesForXPath:@"slides/slide" error:nil];
            for(CXMLNode *node_slide in nodes ){
                NSString* str_order = [[node_slide attributeForName:@"order"] stringValue];
                int order = [str_order intValue];
                order--;
                NSArray* images = [node_slide nodesForXPath:@"image" error:nil];
                NSString* image_url = @"";
                if( [images count] > 0 ){
                    image_url = [[images objectAtIndex:0] stringValue];
                }                
                [arr_images insertObject:image_url atIndex:order];
            }
            
            Deck* deck = [[[Deck alloc] init] autorelease];
            [deck setDeck_id:deck_id];
            [deck setTitle:title];
            [deck setDescription:description];
            [deck setSlidesnumber:slidesnumber];
            [deck setTags:tags];
            [deck setThumbnail:thumbnail];
            [deck setThumb_local:NO];
            [deck setDate:date];
            [deck setOwner:owner];
            NSLog(@"Loading thumbnail for deck %d", idx);
            idx++;
            [deck loadThumbnail];
            
            for( int i=0;i<[arr_images count];i++){
                [deck addSlideImages:[arr_images objectAtIndex:i]];
            }
            [appDelegate.appData addToMyDecks:deck];
            current_perc += increment;
            appDelegate.HUD.progress = current_perc;
            [deck saveToDatabase];
            [arr_images removeAllObjects];
            [arr_images release];
		}
	}

}

- (void)requestFinished:(ASIHTTPRequest *)request
{
	if ([request error])
	{
		// Error throw an alert ** Could not logon to game server **
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not logon to razzi server" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
    
	

	NSString *responseString = [request responseString];
	NSString *type = [request.userInfo objectForKey:@"type"];
	int statusCode = [request responseStatusCode];
	
	if( type == @"authenticate"){
		if( statusCode != 200 ){
            //NSLog(@"Error:%@",responseString);
		}
		else{
			//NSLog(@"%@",responseString);
            NSLog(@"Got the response XML");
            [self loadAllUserDecks];
		}
	}
    else if( type == @"load-all-decks"){
		if( statusCode != 200 ){
            NSLog(@"Error:%@",responseString);
		}
		else{
			NSLog(@"%@",responseString);
            [self parseAllDecksXML:responseString];
            
            PhidecksAppDelegate *appDelegate = (PhidecksAppDelegate *) [[UIApplication sharedApplication]delegate];
            [appDelegate.viewController.homePageViewController paintDeckThumbnails];
            [appDelegate.HUD hide:YES];
		}
	}

}
@end
