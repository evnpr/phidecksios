//
//  phidecksAppDelegate.m
//  phidecks
//
//  Created by Aneesh on 02/06/12.
//  Copyright 2012 XMinds. All rights reserved.
//

#import "PhidecksAppDelegate.h"

@implementation PhidecksAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize appData;
@synthesize HUD;
@synthesize transitionController;
@synthesize carouselDeckViewController;
@synthesize dbWrapper;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    carouselDeckViewController = nil;
    dbWrapper = [[DatabaseWrapper alloc] init];
    [dbWrapper createEditableCopyOfDatabaseIfNeeded];
    [dbWrapper initializeDatabase];
    
    if( [dbWrapper loadActiveUser] == NO ){
        NSLog(@"Failed - No Users");
    }
    
    appData = [[PhidecksAppData alloc] init];
    [appData setUsernameAndPassword:dbWrapper.activeUser.username password:dbWrapper.activeUser.password];
    
    [self showLoadingHUD];
    [dbWrapper loadDecksFromDatabaseForUser:dbWrapper.activeUser.user_id];
    if( [appData.my_decks count] <= 0 ){
        [appData authenticateAndLoadData];
    }

    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(deckLoaded:) 
                                                 name:@"NSPhiDeckLoaded" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(showToolbar:) 
                                                 name:@"NSShowToolbar" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(hideToolbar:) 
                                                 name:@"NSHideToolbar" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(showHomeScreen:) 
                                                 name:@"NSShowHomeScreen" object:nil];

    transitionController = [[TransitionController alloc] initWithViewController:self.viewController];
    toolbarView = [[ToolbarView alloc]initWithFrame:CGRectMake(0 - 120, 100, 100, 400)];
    
    self.window.rootViewController = self.transitionController;
    if( [appData.my_decks count] > 0 ){
        [_viewController.homePageViewController paintDeckThumbnails];
        [HUD hide:YES];
    }
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}


- (void) deckLoaded:(id) sender{
    
    HUD.progress = 1.0f;
    [HUD hide:YES];
    
    [self.transitionController setAutoResizing];    
    
/*    if( carouselDeckViewController != nil ){
        [carouselDeckViewController release];
        carouselDeckViewController = nil;
    }
 */
    
    carouselDeckViewController = [[CarouselDeckViewController alloc] initWithDeckId:appData.selected_deck_id];
    carouselDeckViewController.view.frame = CGRectMake(0,0,1024, 768);
    [transitionController transitionToViewControllerWithBackgroundAndPoint:carouselDeckViewController withImage:appData.previewHomePage startRect:appData.selectedDeckRect];
}

- (void)showToolbar:(id) sender{
    
    [carouselDeckViewController.view addSubview:toolbarView]; 
    [UIView animateWithDuration:0.4 animations:^{
        toolbarView.frame = CGRectMake(-2,100,100,400);
    }];
}

- (void)hideToolbar:(id) sender{
    
    [UIView animateWithDuration:0.4 
                     animations:^{
                         toolbarView.frame = CGRectMake(0 - 120,100, 100, 400);
                     }
                     completion:^(BOOL finished){
                         [toolbarView removeFromSuperview];
                     }
     ];
    
}

- (void) showHomeScreen:(id) sender{
    
    [transitionController transitionToViewController:_viewController withOptions:UIViewAnimationOptionTransitionCrossDissolve];
    
}
- (void) showLoadingHUD {
	
	if( HUD == nil)
		HUD = [[MBProgressHUD alloc] initWithView:self.viewController.view];
	HUD.labelFont = [UIFont fontWithName:@"Arial" size:14];
	[self.viewController.view addSubview:HUD];
	HUD.mode = MBProgressHUDModeDeterminate;
	HUD.labelText = @"Initializing...";
	HUD.progress = 0.0f;
    [HUD show:YES];
}

- (void) hideLoadingHUD {
	
	[HUD hide:YES];
	
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [appData release];
    [HUD release];
    [transitionController release];
    if( carouselDeckViewController != nil )
        [carouselDeckViewController release];
    [toolbarView release];
    [dbWrapper release];
    
    [_window release];
    [_viewController release];
    [super dealloc];
}

@end
