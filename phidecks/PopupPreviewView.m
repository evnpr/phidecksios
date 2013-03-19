//
//  PopupView.m
//  phidecks
//
//  Created by Aneesh on 7/11/12.
//  Copyright (c) 2012 XMinds. All rights reserved.
//

#import "PopupPreviewView.h"

@implementation PopupPreviewView
@synthesize backgroundView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.opaque = NO;
            
        UIImageView *headerView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"drop-top.png"]] autorelease];
        headerView.frame = CGRectMake(56,0,400 - 56, 10);
        [self addSubview:headerView];
        
        UIImageView *footerView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"drop-bottom.png"]] autorelease];
        footerView.frame = CGRectMake(56,600 - 12, 400 - 56, 12);
        [self addSubview:footerView];
        
        UIImageView *arrow = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"popup-bubble-arrow-1.png"]] autorelease];
        arrow.frame = CGRectMake(4,60,58, 59);
        [self addSubview:arrow];
        
        UIImageView *shadow = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shadow-bottom.png"]] autorelease];
        shadow.frame = CGRectMake(56,620,400 - 56, 45);
        [self addSubview:shadow];

    }
    return self;
}


- (void) setPreviewPane{
    
    backgroundView = [[[UIScrollView alloc] initWithFrame:CGRectMake(56,10, 400 - 56, 600 - 10 - 12)] autorelease];
    [self addSubview:backgroundView];
    
}

- (void) removePreviewPane{
    
    [backgroundView removeFromSuperview];
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
