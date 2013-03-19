//
//  PopupWriteView.m
//  phidecks
//
//  Created by Aneesh on 7/12/12.
//  Copyright (c) 2012 XMinds. All rights reserved.
//

#import "PopupWriteView.h"
#import "phidecksAppDelegate.h"
#import "NSNotificationCenter+MainThread.h"

const float POPUP_WIDTH = 250;
const float POPUP_HEIGHT = 350;

@implementation PopupWriteView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        
        UIImageView *headerView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"drop-top.png"]] autorelease];
        headerView.frame = CGRectMake(56,0,POPUP_WIDTH - 56, 10);
        [self addSubview:headerView];
        
        contentView = [[UIView alloc] initWithFrame:CGRectMake(56,10, POPUP_WIDTH-56,POPUP_HEIGHT - 12 - 10)];
        contentView.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"drop-center.png"]];
        [self addSubview:contentView];
        
        UIImageView *footerView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"drop-bottom.png"]] autorelease];
        footerView.frame = CGRectMake(56,POPUP_HEIGHT - 12, POPUP_WIDTH - 56, 12);
        [self addSubview:footerView];
        
        
        UIImageView *arrow = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"popup-bubble-arrow-1.png"]] autorelease];
        arrow.frame = CGRectMake(4,80,58, 59);
        [self addSubview:arrow];
        
        UIImageView *shadow = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shadow-bottom.png"]] autorelease];
        shadow.frame = CGRectMake(56,POPUP_HEIGHT + 10.0,POPUP_WIDTH - 56, 45);
        [self addSubview:shadow];
        
        UIImage *buttonImage = [UIImage imageNamed:@"black-pen-btn.png"];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:buttonImage forState:UIControlStateNormal];
        button.frame = CGRectMake(85,30, 58, 57);
        [button addTarget:self action:@selector(blackPenSelected:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];

        buttonImage = [UIImage imageNamed:@"red-pen-btn.png"];
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:buttonImage forState:UIControlStateNormal];
        button.frame = CGRectMake(85,97, 58, 57);
        [button addTarget:self action:@selector(redPenSelected:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];

        buttonImage = [UIImage imageNamed:@"blue-pen-btn.png"];
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:buttonImage forState:UIControlStateNormal];
        button.frame = CGRectMake(85,164, 58, 57);
        [button addTarget:self action:@selector(bluePenSelected:) forControlEvents:UIControlEventTouchUpInside];        
        [self addSubview:button];

        buttonImage = [UIImage imageNamed:@"eraser-btn.png"];
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:buttonImage forState:UIControlStateNormal];
        button.frame = CGRectMake(85,237, 58, 57);
        [button addTarget:self action:@selector(eraserSelected:) forControlEvents:UIControlEventTouchUpInside];        
        [self addSubview:button];
        
        UISlider *slider = [[[UISlider alloc] initWithFrame:CGRectMake(70,135,250,60)] autorelease];
        slider.minimumValue = 2.0; 
        slider.maximumValue = 25.0;
        slider.continuous = NO; 
        slider.value = 2.0; 
        slider.transform=CGAffineTransformRotate(slider.transform,270.0/180*M_PI);
        [self addSubview:slider];
        [slider addTarget:self action: @selector(sliderValueChanged:) forControlEvents: UIControlEventValueChanged];
        
        UISwitch *mySwitch = [[[UISwitch alloc] initWithFrame:CGRectMake(145, 310, 0,0)] autorelease];
        [self addSubview:mySwitch];
        [mySwitch setOn:NO animated:YES];
        [mySwitch addTarget:self action: @selector(flipDashed:) forControlEvents: UIControlEventValueChanged];

    }
    return self;
}

- (void)flipDashed:(id)sender{
    
    PhidecksAppDelegate *appDelegate = (PhidecksAppDelegate *)   [[UIApplication sharedApplication]delegate];
    
    BOOL flip_on = NO;
    UISwitch *onoff = (UISwitch *) sender;
    if( onoff.on ){
        flip_on = YES;
    }
    appDelegate.appData.writeConfigData.flip_line = flip_on;
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:@"NSWriteDashedLineUpdated" object:nil ];
}

- (void)sliderValueChanged:(id)sender{
    
    UISlider *slider = (UISlider*) sender;
    PhidecksAppDelegate *appDelegate = (PhidecksAppDelegate *)   [[UIApplication sharedApplication]delegate];
    appDelegate.appData.writeConfigData.width = slider.value;
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:@"NSWriteConfigUpdated" object:nil ];
}

- (void)blackPenSelected:(id)sender{
    
    PhidecksAppDelegate *appDelegate = (PhidecksAppDelegate *)   [[UIApplication sharedApplication]delegate];
    appDelegate.appData.writeConfigData.selected_color = 0;
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:@"NSWriteConfigUpdated" object:nil ];
}

- (void)redPenSelected:(id)sender{
    
    PhidecksAppDelegate *appDelegate = (PhidecksAppDelegate *)   [[UIApplication sharedApplication]delegate];
    appDelegate.appData.writeConfigData.selected_color = 1;
    NSLog(@"Here in redPenSelected");
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:@"NSWriteConfigUpdated" object:nil ];

}

-(void)bluePenSelected:(id)sender{
    
    PhidecksAppDelegate *appDelegate = (PhidecksAppDelegate *)   [[UIApplication sharedApplication]delegate];
    appDelegate.appData.writeConfigData.selected_color = 2;
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:@"NSWriteConfigUpdated" object:nil ];
    
}

-(void)eraserSelected:(id)sender{
    
    PhidecksAppDelegate *appDelegate = (PhidecksAppDelegate *)   [[UIApplication sharedApplication]delegate];
    appDelegate.appData.writeConfigData.selected_color = 3;
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:@"NSWriteConfigUpdated" object:nil ];
    
}

- (void) dealloc {
    
    [contentView release];
    [super dealloc];
}

@end
