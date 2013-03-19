//
//  CarouselDeckViewController.h
//  phidecks
//
//  Created by Meera on 7/10/12.
//  Copyright (c) 2012 XMinds. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopupPreviewView.h"
#import "PopupWriteView.h"
#import "PopupTimerView.h"
#import "iCarousel.h"
#import "TimerDragView.h"

@interface CarouselDeckViewController : UIViewController{
    
    PopupPreviewView *popupPreviewView;
    PopupWriteView *popupWriteView;
    PopupTimerView *popupTimerView;
    UIImageView *backgroundView;
    TimerDragView* timerDragView;
    NSTimer *timer;
    BOOL timer_on_screen;
}

- (id) initWithDeckId:(int) l_deck_id;

- (void) dismissAllPopups;

- (void)showPreviewPane:(id)sender;
- (void)hidePreviewPane:(id)sender;
- (void)showWritePane:(id)sender;
- (void)hideWritePane:(id)sender;
- (void)showTimerPane:(id)sender;
- (void)hideTimerPane:(id)sender;
- (void)startTimer:(id)sender;
- (void) killTimerIfAny:(id)sender;
- (void)changeCarouselType:(id)sender;
- (void) startSlideShow:(id)sender;

- (void)hideAllPanes:(id)sender;

@property (nonatomic, retain) iCarousel *carousel;

@end
