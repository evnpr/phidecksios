//
//  TimerDragView.m
//  phidecks
//
//  Created by Aneesh on 7/13/12.
//  Copyright (c) 2012 XMinds. All rights reserved.
//

#import "TimerDragView.h"
#import "NSNotificationCenter+MainThread.h"
#import "phidecksAppDelegate.h"

@implementation TimerDragView

- (id)initWithFrameAndValue:(CGRect)frame value:(int)val {
    
    self = [super initWithFrame:frame];
    if (self) {
        timerValue = val;
        inPopupView = NO;
        [self initialize];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        timerValue = -1;
        inPopupView = YES;
        [self initialize];
    }
    return self;
}

- (void) initialize {
    
    self.userInteractionEnabled = YES;
    UIImageView *imgView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 150, 278, 208)] autorelease];
    imgView.image = [UIImage imageNamed:@"timer-minute.png"];
    [self addSubview:imgView];
    
    
    UIImage *buttonImage = [UIImage imageNamed:@"start-btn.png"];
    buttonStart = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonStart setImage:buttonImage forState:UIControlStateNormal];
    buttonStart.frame = CGRectMake(34,150 + 65, 210, 108);
    [buttonStart setEnabled:YES];
    [buttonStart addTarget:self action:@selector(startTimerClicked:) forControlEvents:UIControlEventTouchUpInside];
     
    
    buttonImage = [UIImage imageNamed:@"reset-btn.png"];
    buttonReset = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonReset setImage:buttonImage forState:UIControlStateNormal];
    buttonReset.frame = CGRectMake(34,150 + 65, 210, 108);
    [buttonReset addTarget:self action:@selector(resetButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    if( timerValue == -1){
        timerView = [[TimerView alloc] initWithFrame:CGRectMake(35,0,240, 170)];
        [self addStartButton];
    }
    else{
        timerView = [[TimerView alloc] initWithFrameAndValue:CGRectMake(35,0,240, 170) value:timerValue];
        [self addResetButton];
    }

    [self addSubview:timerView];
}

- (void) startTimer{
    
    [timerView startTimer];
}

- (void) addStartButton{
    [buttonReset removeFromSuperview];
    [self addSubview:buttonStart];
    [buttonStart addTarget:self action:@selector(startTimerClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void) addResetButton{
    [buttonStart removeFromSuperview];
    [self addSubview:buttonReset];
}

- (void) startTimerClicked:(id)sender{
    
    NSLog(@"startTimerClicked");
    PhidecksAppDelegate *appDelegate = (PhidecksAppDelegate *)   [[UIApplication sharedApplication]delegate];
    appDelegate.appData.timerValue = [timerView getTimerValue];
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:@"NSStartTimer" object:nil ];
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:@"NSHideAllPanes" object:nil ];
    
}

-(void)resetButtonClicked:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:@"NSTimerReset" object:nil ];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
    if( inPopupView )
        return;
	// We only support single touches, so anyObject retrieves just that touch from touches
	UITouch *touch = [touches anyObject];	
	// Animate the first touch
	CGPoint touchPoint = [touch locationInView:self.superview];
	[self animateFirstTouchAtPoint:touchPoint];
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
    if( inPopupView )
        return;
    
	UITouch *touch = [touches anyObject];
    CGPoint thisTouch = [touch locationInView:self.superview];
    
    CGPoint prevTouch = [touch previousLocationInView:self.superview];
    CGFloat dx = thisTouch.x - prevTouch.x;
    CGFloat dy = thisTouch.y - prevTouch.y;
    
    //CGPoint newCenter = CGPointMake(dx, dy);
    //[touch view].center = newCenter;
    
    self.frame = CGRectMake(self.frame.origin.x + dx, 
                                    self.frame.origin.y + dy, 
                                    self.frame.size.width, 
                                    self.frame.size.height);

}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
    if( inPopupView )
        return;
    
	UITouch *touch = [touches anyObject];
	
	// If the touch was in the placardView, bounce it back to the center
	if ([touch view] == self) {
		// Disable user interaction so subsequent touches don't interfere with animation
		self.userInteractionEnabled = YES;
//		[self animatePlacardViewToCenter];
		return;
	}		
}


- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	
	/*
     To impose as little impact on the device as possible, simply set the placard view's center and transformation to the original values.
     */
}

- (void)animateFirstTouchAtPoint:(CGPoint)touchPoint {
	
#define GROW_ANIMATION_DURATION_SECONDS 0.15
#define SHRINK_ANIMATION_DURATION_SECONDS 0.15
	
	/*
	 Create two separate animations, the first for the grow, which uses a delegate method as before to start an animation for the shrink operation. The second animation here lasts for the total duration of the grow and shrink animations and is responsible for performing the move.
	 */
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:GROW_ANIMATION_DURATION_SECONDS];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(growAnimationDidStop:finished:context:)];
	CGAffineTransform transform = CGAffineTransformMakeScale(1.05, 1.05);
	self.transform = transform;
	[UIView commitAnimations];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:GROW_ANIMATION_DURATION_SECONDS + SHRINK_ANIMATION_DURATION_SECONDS];
	self.center = touchPoint;
	[UIView commitAnimations];
}

- (void)growAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:SHRINK_ANIMATION_DURATION_SECONDS];
	self.transform = CGAffineTransformMakeScale(1, 1);	
	[UIView commitAnimations];
}


- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
	//Animation delegate method called when the animation's finished:
	// restore the transform and reenable user interaction
	self.transform = CGAffineTransformIdentity;
	self.userInteractionEnabled = YES;
}


@end
