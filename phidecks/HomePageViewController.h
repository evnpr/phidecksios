//
//  HomePageViewController.h
//  phidecks
//
//  Created by Meera on 7/7/12.
//  Copyright (c) 2012 XMinds. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomePageView.h"
@interface HomePageViewController : UIViewController
{
    HomePageView *homepageView;
    UIScrollView* backgroundView;
}
-(void)deckSelected:(id)sender;
- (void) paintDeckThumbnails;
- (UIImage*) saveCurrentViewToImage;

@end
