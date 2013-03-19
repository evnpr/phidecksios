//
//  TimerView.h
//  iDharmaClock
//
//  Created by Aneesh on 7/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimerView : UIView{
    
    UIImageView *firstMinutebg1;//Minute hand - TOP - below
    UIImageView *firstMinutebg2;//Minute hand - TOP - above
	UIImageView *firstMinutebg3;//Minute hand - BELOW - above
    
    UIImageView *bg1;//Second hand - TOP - below
    UIImageView *bg2;//Second hand - TOP - above
	UIImageView *bg3;//Second hand - BELOW - above

    UIImageView *whiteBg1;//Minute hand - BELOW - 2nd below
	UIImageView *whiteBg2;//Second hand - BELOW - 2nd below
    
    int timerHour;
    int timerMinute;
    int timerSecond;
    
    int inputSeconds;
    int hours;
    int minutes;
    
    int firstminutez;
    int numbers;
    
    int loop;
    BOOL isFirstMinuteFlipEnded;
    BOOL newTime;
    
    NSTimer *timer;
	NSTimer *timer2;
	NSTimer *myTicker;
    BOOL popup;

}
@property(nonatomic, retain)     NSTimer *timer;
- (id)initWithFrameAndValue:(CGRect)frame value:(int) val;
- (void) initialize;
- (void) startTimer;
- (int) getTimerValue;
@end
