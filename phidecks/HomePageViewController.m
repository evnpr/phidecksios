//
//  HomePageViewController.m
//  phidecks
//
//  Created by Meera on 7/7/12.
//  Copyright (c) 2012 XMinds. All rights reserved.
//

#import "HomePageViewController.h"
#import "PhidecksAppDelegate.h"
#import "Deck.h"
#import "NSNotificationCenter+MainThread.h"

const float DECK_MARGIN_X = 40;
const float DECK_MARGIN_Y = 40;

@interface HomePageViewController ()

@end

@implementation HomePageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    self.navigationController.toolbarHidden = YES;
    
    self.view.frame = CGRectMake(0, 0, 1024, 768);
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0, 1024,120)];
    headerView.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"top-bg-repeat.png"]];;
    [self.view addSubview:headerView];
    
    UIView* leatherView = [[UIView alloc] initWithFrame:CGRectMake(0,119, 1024,55)];
    leatherView.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"stich-bg-2.png"]];;
    [self.view addSubview:leatherView];

    UIView* footerView = [[UIView alloc] initWithFrame:CGRectMake(0,768 - 50, 1024,50)];
    footerView.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"bottom-bar-repeat2.png"]];;
    [self.view addSubview:footerView];    

    
    backgroundView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,119 + 54, 1024,768 - 119 - 54 - 50)];
    backgroundView.contentSize = CGSizeMake(1020, 768 - 119 - 54 - 50);
    backgroundView.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"bottom-bg-repeat.png"]];;
    [self.view addSubview:backgroundView];
    
    
    UIImage *buttonImage = [UIImage imageNamed:@"fb-btn.png"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:buttonImage forState:UIControlStateNormal];
    button.frame = CGRectMake(840,768 - 50, 64, 25);
    [self.view addSubview:button];
    
    buttonImage = [UIImage imageNamed:@"twitter-btn.png"];
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:buttonImage forState:UIControlStateNormal];
    button.frame = CGRectMake(840 + 64 + 10,768 - 50, 92, 25);
    [self.view addSubview:button];

    
    UIImageView *logoView = [[UIImageView alloc] initWithFrame:CGRectMake(20,15,386,92)];
    logoView.image = [UIImage imageNamed:@"logo.png"];
    [headerView addSubview:logoView];
    [logoView release];
    
    buttonImage = [UIImage imageNamed:@"settings-btn.png"];
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:buttonImage forState:UIControlStateNormal];
    button.frame = CGRectMake(1024 - 60 - 25, 35, 60, 57);
    [headerView addSubview:button];
    
    buttonImage = [UIImage imageNamed:@"question-btn.png"];
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:buttonImage forState:UIControlStateNormal];
    button.frame = CGRectMake(15, 11, 34, 33);
    [leatherView addSubview:button];
    
    buttonImage = [UIImage imageNamed:@"lock.png"];
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:buttonImage forState:UIControlStateNormal];
    button.frame = CGRectMake(15 + 34 + 10, 22, 12, 14);
    [leatherView addSubview:button];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15 + 34 + 10 + 14 + 4, 18, 200, 20)];
    [label setTextColor:[UIColor grayColor]];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setFont:[UIFont fontWithName: @"Trebuchet MS" size: 14.0f]];
    [label setText:@"Amin Nordin"];
    [leatherView addSubview:label];
    [label release];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(470, 15, 100, 26)];
    [label setTextColor:[UIColor colorWithRed:64/255.0 green:224/255.0 blue:208/255.0 alpha:1.0]];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setFont:[UIFont fontWithName: @"Trebuchet MS" size: 18.0f]];
    [label setText:@"MY DECKS"];
    [leatherView addSubview:label];
    [label release];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(620, 15, 200, 26)];
    [label setTextColor:[UIColor whiteColor]];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setFont:[UIFont fontWithName: @"Trebuchet MS" size: 18.0f]];
    [label setText:@"FEATURED DECKS"];
    [leatherView addSubview:label];
    [label release];

    [leatherView release];
    [headerView release];
    [footerView release];
    
}

- (void) paintDeckThumbnails{
    
    PhidecksAppDelegate *appDelegate = (PhidecksAppDelegate *)   [[UIApplication sharedApplication]delegate];
    
    int y = 0;
    for( int i=0;i<[appDelegate.appData.my_decks count];i++){
        Deck* deck = [appDelegate.appData.my_decks objectAtIndex:i];
        
        int j = i / 3.0;
        int k = i % 3;
        int x = k * 278 + (k+1) * DECK_MARGIN_X;
        y = j * 228 + (j+1) * DECK_MARGIN_Y;
        CGRect rect = CGRectMake(x,y,278,228);
        UIImageView *containerView = [[UIImageView alloc] initWithFrame:rect];
        containerView.image = [UIImage imageNamed:@"image-thumb-bg.png"];
        containerView.userInteractionEnabled = YES;
        UIImage* buttonImage = deck.thumb_image;
        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = [deck deck_id];
        [button setImage:buttonImage forState:UIControlStateNormal];
        button.frame = CGRectMake(10, 7, 258, 208);
        [containerView addSubview:button];
        
        [button addTarget:self action:@selector(deckSelected:) forControlEvents:UIControlEventTouchUpInside];
        [backgroundView addSubview:containerView];
        
        deck.position = rect;
        [containerView release];
    }
    
    backgroundView.contentSize = CGSizeMake(1020, y + 228 + DECK_MARGIN_Y);
}

- (UIImage*) saveCurrentViewToImage{
    
    CGRect rect = CGRectMake(0,0,1024,768);
    UIGraphicsBeginImageContextWithOptions(rect.size,YES,0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.view.layer renderInContext:context];   
    UIImage* previewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return previewImage;
}

-(void)deckSelected:(id)sender{
    
    PhidecksAppDelegate *appDelegate = (PhidecksAppDelegate *)   [[UIApplication sharedApplication]delegate];
    UIButton* button = (UIButton*) sender;
    Deck* deck = [appDelegate.appData.my_decks_dict objectForKey:[NSString stringWithFormat:@"%d", button.tag]];
    
    
    if( deck == nil){
        //UIAlertView
        return;
    }
    
    appDelegate.appData.previewHomePage = [self saveCurrentViewToImage];
    CGPoint point = CGPointMake(deck.position.origin.x, deck.position.origin.y);
    CGPoint convertedPoint = [backgroundView convertPoint:point toView:appDelegate.window.rootViewController.view];  //Now convert teh point to window coordinates
    appDelegate.appData.selectedDeckRect = CGRectMake(convertedPoint.x, convertedPoint.y, deck.position.size.width,deck.position.size.height);
    
    appDelegate.appData.selected_deck_id = button.tag;
    if( [deck deck_loaded] == NO){	
        appDelegate.HUD.progress = 0.0f;
        appDelegate.HUD.labelText =  @"Loading selected deck...";
        [appDelegate.HUD show:YES];
        
        [NSThread detachNewThreadSelector:@selector(loadAllSlides:) toTarget:deck withObject:nil];    

    }
    else{
        [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:@"NSPhiDeckLoaded" object:nil ];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    [backgroundView release];
    [super dealloc];
}

@end
