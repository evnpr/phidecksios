//
//  PopupTimerView.m
//  phidecks
//
//  Created by Aneesh on 7/13/12.
//  Copyright (c) 2012 XMinds. All rights reserved.
//

#import "PopupTimerView.h"

@implementation PopupTimerView

const float TIMER_POPUP_WIDTH = 350;
const float TIMER_POPUP_HEIGHT = 350;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        
        UIImageView *headerView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"drop-top.png"]] autorelease];
        headerView.frame = CGRectMake(56,0,TIMER_POPUP_WIDTH - 56, 10);
        [self addSubview:headerView];
        
        contentView = [[UIView alloc] initWithFrame:CGRectMake(56,10, TIMER_POPUP_WIDTH-56,TIMER_POPUP_HEIGHT - 12 - 10)];
        contentView.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"drop-center.png"]];
        [self addSubview:contentView];
        
        UIImageView *footerView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"drop-bottom.png"]] autorelease];
        footerView.frame = CGRectMake(56,TIMER_POPUP_HEIGHT - 12, TIMER_POPUP_WIDTH - 56, 12);
        [self addSubview:footerView];
        
        
        UIImageView *arrow = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"popup-bubble-arrow-1.png"]] autorelease];
        arrow.frame = CGRectMake(4,200,58, 59);
        [self addSubview:arrow];
        
        UIImageView *shadow = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shadow-bottom.png"]] autorelease];
        shadow.frame = CGRectMake(56,TIMER_POPUP_HEIGHT + 10.0,TIMER_POPUP_WIDTH - 56, 45);
        [self addSubview:shadow];
        
        timerDragView = [[TimerDragView alloc] initWithFrame:CGRectMake(60,0, 280,350)];
        [self addSubview:timerDragView];
    }
    return self;
}

- (void) dealloc {
    
    [contentView release];
    [timerDragView release];
    
    [super dealloc];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
