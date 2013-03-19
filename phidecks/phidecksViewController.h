//
//  phidecksViewController.h
//  phidecks
//
//  Created by Meera on 02/06/12.
//  Copyright 2012 XMinds. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomePageViewController.h"

@interface phidecksViewController : UIViewController
{
    HomePageViewController *homePageViewController;
}
@property(nonatomic, retain) HomePageViewController *homePageViewController;

@end
