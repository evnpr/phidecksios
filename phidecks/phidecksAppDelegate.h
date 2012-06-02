//
//  phidecksAppDelegate.h
//  phidecks
//
//  Created by Jugs VN on 02/06/12.
//  Copyright 2012 XMinds. All rights reserved.
//

#import <UIKit/UIKit.h>

@class phidecksViewController;

@interface phidecksAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet phidecksViewController *viewController;

@end
