//
//  TimerDragView.h
//  phidecks
//
//  Created by Aneesh on 7/13/12.
//  Copyright (c) 2012 XMinds. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimerView.h"

@interface TimerDragView : UIView
{
    TimerView* timerView;
    UIButton *buttonStart;
    UIButton *buttonReset;
    BOOL inPopupView;
    int timerValue;
}
- (void) addStartButton;
- (void) addResetButton;
- (id)initWithFrameAndValue:(CGRect)frame value:(int)val;
- (void) startTimer;
- (void)startTimerClicked:(id)sender;
@end
