//
//  phidecksAppDelegate.h
//  phidecks
//
//  Created by Aneesh on 02/06/12.
//  Copyright 2012 XMinds. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhidecksAppData.h"
#import "MBProgressHUD.h"
#import "phidecksViewController.h"
#import "TransitionController.h"
#import "CarouselDeckViewController.h"
#import "ToolbarView.h"
#import "DatabaseWrapper.h"


@interface PhidecksAppDelegate : NSObject <UIApplicationDelegate>{
    
    PhidecksAppData *appData;
    MBProgressHUD *HUD;
    TransitionController* transitionController;
    CarouselDeckViewController *carouselDeckViewController;
    ToolbarView *toolbarView;
    
    DatabaseWrapper* dbWrapper;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet phidecksViewController *viewController;
@property (nonatomic, retain) PhidecksAppData *appData;
@property (nonatomic, retain) MBProgressHUD *HUD;
@property (nonatomic, retain) CarouselDeckViewController *carouselDeckViewController;
@property (nonatomic, retain) TransitionController* transitionController;
@property (nonatomic, retain) DatabaseWrapper* dbWrapper;

- (void) showLoadingHUD;
- (void) hideLoadingHUD;
- (void) deckLoaded:(id) sender;
- (void) showToolbar:(id) sender;
- (void) hideToolbar:(id) sender;
- (void) showHomeScreen:(id) sender;
@end
