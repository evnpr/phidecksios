//
//  ToolbarView.m
//  phidecks
//
//  Created by Aneesh on 7/5/12.
//  Copyright (c) 2012 XMinds. All rights reserved.
//

#import "ToolbarView.h"
#import "NSNotificationCenter+MainThread.h"
#import "phidecksAppDelegate.h"

@implementation ToolbarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        preview = NO;
        write = NO;
        timer = NO;
        
        self.opaque = NO;
        UIImage *buttonImage = [UIImage imageNamed:@"tb1-1.png"];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:buttonImage forState:UIControlStateNormal];
        button.frame = CGRectMake(0,0, 66, 98);
        [self addSubview:button];
        [button addTarget:self action:@selector(previewButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        buttonImage = [UIImage imageNamed:@"tb2-1.png"];
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:buttonImage forState:UIControlStateNormal];
        button.frame = CGRectMake(0,98, 66, 98);
        [self addSubview:button];
        [button addTarget:self action:@selector(writeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];        
        
        buttonImage = [UIImage imageNamed:@"tb3-1.png"];
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:buttonImage forState:UIControlStateNormal];
        button.frame = CGRectMake(0,98 * 2 - 1, 66, 98);
        [self addSubview:button];        
        [button addTarget:self action:@selector(slideShowButtonClicked:) forControlEvents:UIControlEventTouchUpInside];        
        
        buttonImage = [UIImage imageNamed:@"tb4-1.png"];
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:buttonImage forState:UIControlStateNormal];
        button.frame = CGRectMake(0,98 * 3 - 2, 66, 98);
        [self addSubview:button];
        [button addTarget:self action:@selector(timerButtonClicked:) forControlEvents:UIControlEventTouchUpInside];        
        
        buttonImage = [UIImage imageNamed:@"tb5-1.png"];
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:buttonImage forState:UIControlStateNormal];
        button.frame = CGRectMake(0,98 * 4 - 3, 66, 98);
        [self addSubview:button];                
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(resetFlags:)
                                                     name:@"NSResetFlags" object:nil];

    }
    return self;
}

-(void)resetFlags:(id)sender {
    preview = NO;
    write = NO;
    timer = NO;
}

-(void)slideShowButtonClicked:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:@"NSStartSlideShow" object:nil ];
}

-(void)previewButtonClicked:(id)sender {
    
    preview = !preview;
    if( preview ){
        [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:@"NSShowPreviewPane" object:nil ]; //
    }
    else{
        [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:@"NSHidePreviewPane" object:nil ];
    }
}

-(void)writeButtonClicked:(id)sender {
    
    write = !write;
    if( write ){
        [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:@"NSShowWritePane" object:nil ]; //NSShowWritePane
    }
    else{
        [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:@"NSHideWritePane" object:nil ];
    }
}

-(void)timerButtonClicked:(id)sender {
    
    timer = !timer;
    if( timer ){
        [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:@"NSShowTimerPane" object:nil ];
    }
    else{
        [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:@"NSHideTimerPane" object:nil ];
    }
}

- (void) dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

@end
