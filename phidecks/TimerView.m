//
//  TimerView.m
//  iDharmaClock
//
//  Created by Aneesh on 7/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TimerView.h"
#import "NSNotificationCenter+MainThread.h"

const int steps = 7;
const float stepz = 0.33;
const float speed = 0.02;


@implementation TimerView

@synthesize timer;
- (id)initWithFrameAndValue:(CGRect)frame value:(int) val
{
    self = [super initWithFrame:frame];
    if (self) {
        timerSecond = (val * 60) + 59;
        popup = NO;
        [self initialize];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    if (self) {
        timerSecond = 1 * 60;
        popup = YES;
        [self initialize];
    }
    return self;
}

- (int) getTimerValue{
    return timerSecond / 60;
}

- (void) startTimer {
    
    if (!myTicker) {
        myTicker = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(showActivity) userInfo:nil repeats:YES];
    }
}

- (void) timerReset: (id) sender{
    [myTicker invalidate];
    myTicker = nil;
}

- (void) initialize {
    
    self.backgroundColor = [UIColor clearColor];
    loop = 1;
    newTime = YES;
    firstminutez = 13;
    numbers = 13;
    
    inputSeconds = timerSecond;
    hours =  inputSeconds / 3600;
    minutes = ( inputSeconds - hours * 3600 ) / 60; 
    
    firstminutez = timerSecond / 10;
    numbers = timerSecond - (timerSecond / 10) * 10;
    
    firstMinutebg1 = [[[UIImageView alloc] initWithFrame:CGRectMake(10,10, 104, 81)] autorelease];//Minute hand - TOP - below
    firstMinutebg1.image = [UIImage imageNamed:@"w-1-up.png"];
    
    firstMinutebg2 = [[[UIImageView alloc] initWithFrame:CGRectMake(10,10, 104, 81)] autorelease];//Minute hand - TOP - above
    firstMinutebg3 = [[[UIImageView alloc] initWithFrame:CGRectMake(10,10 + 81, 104, 81)] autorelease];//Minute hand - BELOW - above
    whiteBg1 = [[[UIImageView alloc] initWithFrame:CGRectMake(10,10 + 81, 104, 81)] autorelease];//Minute hand - BELOW - 2nd below
    
    bg1 = [[[UIImageView alloc] initWithFrame:CGRectMake(10 + 78,10, 104, 81)] autorelease];//Second hand - TOP - below
    bg1.image = [UIImage imageNamed:@"w-1-up.png"];
    bg2 = [[[UIImageView alloc] initWithFrame:CGRectMake(10 + 78,10, 104, 81)] autorelease];//Second hand - TOP - above
    bg3 = [[[UIImageView alloc] initWithFrame:CGRectMake(10 + 78,10 + 81, 104, 81)] autorelease];//Second hand - BELOW - above
    whiteBg2 = [[[UIImageView alloc] initWithFrame:CGRectMake(10 + 78,10 + 81, 104, 81)] autorelease];//Second hand - BELOW - 2nd below
    
    UIImageView* whiteBg3 = [[[UIImageView alloc] initWithFrame:CGRectMake(10,10 + 81, 104, 81)] autorelease];//Minute hand - BELOW - 3rd below
    //whiteBg3.image = [UIImage imageNamed:@"whiteBgrnd.png"];
    UIImageView* whiteBg4 = [[[UIImageView alloc] initWithFrame:CGRectMake(10 + 78,10 + 81, 104, 81)] autorelease];//Second hand - BELOW - 3rd below
    //whiteBg4.image = [UIImage imageNamed:@"whiteBgrnd.png"];
    
    //Minute hand
    [self addSubview:firstMinutebg1];
    [self addSubview:firstMinutebg2];
    [self addSubview:whiteBg3];
    [self addSubview:whiteBg1];
    [self addSubview:firstMinutebg3];
    
    //Secondhand
    [self addSubview:bg1];
    [self addSubview:bg2];
    [self addSubview:whiteBg4];
    [self addSubview:whiteBg2];
    [self addSubview:bg3];
    
    UIImageView* scroller = [[[UIImageView alloc] initWithFrame:CGRectMake(10 + 73,60, 39, 61)] autorelease];
    scroller.image = [UIImage imageNamed:@"scoller.png"];
    [self addSubview:scroller];
    
    self.timer = [NSTimer timerWithTimeInterval:speed target:self selector:@selector(setMinuteInTimer) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];	
    
    if( popup ){
        
        UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
        [swipeGesture setDirection: UISwipeGestureRecognizerDirectionUp ];
        [self addGestureRecognizer:swipeGesture];
        [swipeGesture release];
        
        swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
        [swipeGesture setDirection: UISwipeGestureRecognizerDirectionDown ];
        [self addGestureRecognizer:swipeGesture];
        [swipeGesture release];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(timerReset:)
                                                 name:@"NSKillTimer" object:nil];
}

- (void)handleSwipeGesture:(UISwipeGestureRecognizer *)panGesture{
    
    BOOL no_change = NO;
    if (panGesture.direction == UISwipeGestureRecognizerDirectionUp) {
        timerSecond = timerSecond + 60;
        if( timerSecond > 3600 ){
            timerSecond -= 60;
            no_change = YES;
        }
    }
    else if (panGesture.direction == UISwipeGestureRecognizerDirectionDown) {
        timerSecond = timerSecond - 60;
        if( timerSecond < 60 ){
            timerSecond = 60;
            no_change = YES;
        }
    }
    else {
        return;
    }
    
    if( !no_change ){
        newTime = YES;
        inputSeconds = timerSecond;
        hours =  inputSeconds / 3600;
        minutes = ( inputSeconds - hours * 3600 ) / 60; 
        
        firstminutez = timerSecond / 10;
        numbers = timerSecond - (timerSecond / 10) * 10;
        
        timer = [NSTimer timerWithTimeInterval:speed target:self selector:@selector(setMinuteInTimer) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    }

}

-(int)sMinute {
	static NSString *minute;
	NSString *mTime = [NSString stringWithFormat:@"%02d",minutes];
	minute = [mTime substringWithRange:NSMakeRange(1, 1)];
    return [minute integerValue];
}
-(int)fMinute {
	static NSString *minute;
	NSString *mTime = [NSString stringWithFormat:@"%02d",minutes];
	minute = [mTime substringWithRange:NSMakeRange(0, 1)];
    
    return [minute integerValue];	
}

-(int)sHour {
	static NSString *minute;
	NSString *mTime = [NSString stringWithFormat:@"%02d",hours];
	minute = [mTime substringWithRange:NSMakeRange(1, 1)];
    

    return [minute integerValue];
	
}
-(int)fHour {
	static NSString *minute;
	NSString *mTime = [NSString stringWithFormat:@"%02d",hours];
	minute = [mTime substringWithRange:NSMakeRange(0, 1)];
    
    return [minute integerValue];
}



-(void) setMinuteInTimer{
	NSString *tableColor = @"w";
	numbers = [self sMinute];
		
	int prevNumber;
	prevNumber = numbers;
	if (prevNumber == -1) {
		prevNumber = 9;
	}
	NSString *secMin1 = [NSString stringWithFormat:@"%@-%d-up.png",tableColor,numbers];
	bg1.image = [UIImage imageNamed:secMin1];
	
	secMin1 = [NSString stringWithFormat:@"%@-%d-up.png",tableColor,prevNumber];
	bg2.image = [UIImage imageNamed:secMin1];
	
	
	float scaleCoef = 1 - (stepz * loop);
	bg1.hidden = NO;
	
	
	if (scaleCoef >= 0) {
		bg2.transform = CGAffineTransformConcat(
												bg2.transform = CGAffineTransformMakeScale(1, scaleCoef),
												CGAffineTransformMakeTranslation(0, (scaleCoef > 0 ? -1 : 1) * 
																				 bg2.frame.size.height  / 2  + 53));
	}
	if (scaleCoef < 0) {
		if (loop == steps) {
			scaleCoef = -1;
		}
		NSString *secMin = [NSString stringWithFormat:@"%@-%d-down.png",tableColor,prevNumber];
		bg2.image = [UIImage imageNamed:secMin];
		bg2.transform = CGAffineTransformConcat(
												bg2.transform = CGAffineTransformMakeScale(1, (scaleCoef * -1)),
												CGAffineTransformMakeTranslation(0, (scaleCoef > 0 ? -1 : 1) * 
																				 bg2.frame.size.height  / 2  + 53));
	}
	
	loop++;
	if (loop >= steps) {
		loop = 0;
//        if( timer != nil ){
            [timer invalidate];
//            timer = nil;
//        }
		
		NSString *secMin3 = [NSString stringWithFormat:@"%@-%d-down.png",tableColor,numbers];
		bg3.image = [UIImage imageNamed:secMin3];
		
		NSString *secMin2 = [NSString stringWithFormat:@"%@-%d-up.png",tableColor,numbers];
		bg2.image = [UIImage imageNamed:secMin2];
		
		bg1.hidden = YES;
		bg2.transform = CGAffineTransformMakeScale(1, 1);
		
		if (numbers == 0 && !isFirstMinuteFlipEnded && !newTime) {
			isFirstMinuteFlipEnded = YES;
			timer = [NSTimer timerWithTimeInterval:speed target:self selector:@selector(flipFirstMinute) userInfo:nil repeats:YES];
			[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
		}
		if (numbers != 0) {
			isFirstMinuteFlipEnded = NO;
		}
		if (newTime == YES) {
			timer = [NSTimer timerWithTimeInterval:speed target:self selector:@selector(flipFirstMinute) userInfo:nil repeats:YES];
			[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
		}
         
	}
}

-(void) flipFirstMinute{
	firstminutez = [self fMinute];
	
	NSString *tableColor = @"w";
	
	//NSLog(@"firstminutez");
	int prevNumber = firstminutez;
	if (prevNumber == -1) {
		prevNumber = 9;
	}
	NSString *secMin1 = [NSString stringWithFormat:@"%@-%d-up.png",tableColor,firstminutez];
	firstMinutebg1.image = [UIImage imageNamed:secMin1];
	
	secMin1 = [NSString stringWithFormat:@"%@-%d-up.png",tableColor,prevNumber];
	firstMinutebg2.image = [UIImage imageNamed:secMin1];	
	
	float scaleCoef = 1 - (stepz * loop);
	firstMinutebg1.hidden = NO;
	
	
	if (scaleCoef >= 0) {
		firstMinutebg2.transform = CGAffineTransformConcat(
														   firstMinutebg2.transform = CGAffineTransformMakeScale(1, scaleCoef),
														   CGAffineTransformMakeTranslation(0, (scaleCoef > 0 ? -1 : 1) * 
																							firstMinutebg2.frame.size.height  / 2  + 53));
	}
	if (scaleCoef < 0) {
		if (loop == steps) {
			scaleCoef = -1;
		}
		NSString *secMin = [NSString stringWithFormat:@"%@-%d-down.png",tableColor,prevNumber];
		firstMinutebg2.image = [UIImage imageNamed:secMin];
		firstMinutebg2.transform = CGAffineTransformConcat(
														   firstMinutebg2.transform = CGAffineTransformMakeScale(1, (scaleCoef * -1)),
														   CGAffineTransformMakeTranslation(0, (scaleCoef > 0 ? -1 : 1) * 
																							firstMinutebg2.frame.size.height  / 2  + 53));
	}
	
	loop++;
	if (loop >= steps) {
		loop = 0;
//        if( timer != nil ){
            [timer invalidate];
//            timer = nil;
//        }
		
		NSString *secMin3 = [NSString stringWithFormat:@"%@-%d-down.png",tableColor,firstminutez];
		firstMinutebg3.image = [UIImage imageNamed:secMin3];
		
		NSString *secMin2 = [NSString stringWithFormat:@"%@-%d-up.png",tableColor,firstminutez];
		firstMinutebg2.image = [UIImage imageNamed:secMin2];
		
		firstMinutebg1.hidden = YES;
		firstMinutebg2.transform = CGAffineTransformMakeScale(1, 1);
		
/*		if (newTime == YES) {
			if (!myTicker) {
                myTicker = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(showActivity) userInfo:nil repeats:YES];
            }
		}
*/

	}
}

- (void)showActivity{
	
	timerSecond = timerSecond - 1;
	inputSeconds = timerSecond;
	hours =  inputSeconds / 3600;
	minutes = ( inputSeconds - hours * 3600 ) / 60; 
	int secondz = timerSecond - (hours * 3600 + minutes * 60);
	
	NSLog(@"%d - %d:%d:%d",timerSecond, hours,minutes,secondz);
	
	if (secondz == 59) {
		timer = [NSTimer timerWithTimeInterval:speed target:self selector:@selector(setMinuteInTimer) userInfo:nil repeats:YES];
		[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
		if (minutes == 0 && hours == 0) {
//			isAlarm = YES;
		}
	}
	if (secondz <= 10 && minutes == 0 && hours == 0) {
	}
	
    if( timerSecond <= 59 ){
        [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:@"NSTimerReset" object:nil ];
    }
}

- (void) dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}
@end
