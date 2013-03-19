//
//  phidecksView.m
//  phidecks
//
//  Created by Aneesh on 05/06/12.
//  Copyright 2012 XMinds. All rights reserved.
//

#import "SlidesView.h"
#import "NSNotificationCenter+MainThread.h"
#import <QuartzCore/QuartzCore.h>
#import "PhidecksAppDelegate.h"
#import "CGPointUtils.h"

@implementation SlidesView

@synthesize button, image, previewImage;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        swipeUp = NO;
        
        self.backgroundColor=[UIColor whiteColor];
        smoothView = [[[SmoothLineView alloc] initWithFrame:self.bounds]autorelease];
        smoothView.lineColor = [[UIColor alloc] initWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
        smoothView.lineWidth = 2.0;
        [self addSubview:smoothView];
        
        UIImage *buttonImage = [UIImage imageNamed:@"pullout-ribbon.png"];
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:buttonImage forState:UIControlStateNormal];
        button.frame = CGRectMake(650,80, 120, 90);
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];        
        
        self.multipleTouchEnabled = YES;
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleViewsSwipe:)];
        panGesture.minimumNumberOfTouches = 3;
        panGesture.maximumNumberOfTouches = 3;
        panGesture.delegate = (id <UIGestureRecognizerDelegate>)self;
        [self addGestureRecognizer:panGesture];
        [panGesture release];
        
/*        UISwipeGestureRecognizer* swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleUndoRedoSwipe:)];
        swipeGesture.numberOfTouchesRequired = 1;
        swipeGesture.direction = UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionLeft;
        swipeGesture.delegate = (id <UIGestureRecognizerDelegate>)self;
        [self addGestureRecognizer:swipeGesture];
        [swipeGesture release];
*/
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(configUpdated:)
                                                     name:@"NSWriteConfigUpdated" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(dashedLineConfigUpdated:)
                                                     name:@"NSWriteDashedLineUpdated" object:nil];

        
        UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
        [self addGestureRecognizer:pinchGesture]; 
        [pinchGesture release];
        
        dismissViewCalled = NO;
 
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    if( image != nil){
        [image drawInRect:rect];
    }
}

- (void) handleUndoRedoSwipe:(UIPanGestureRecognizer *)panGesture{

    NSLog(@"Here");
    
}

- (void)handleViewsSwipe:(UIPanGestureRecognizer *)panGesture{
    
    CGPoint velocity = [panGesture velocityInView:self];
    
    if(velocity.x > 0)
    {
        [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:@"NSShowToolbar" object:nil ];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:@"NSHideToolbar" object:nil ];
    }
}

- (void)handlePinchGesture:(UIPinchGestureRecognizer *)gestureRecognizer {
    
    if([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        // Reset the last scale, necessary if there are multiple objects with different scales
        lastScale = [gestureRecognizer scale];
        [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:@"NSChangeBackgroundToHome" object:nil ];
    }
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan ||
        [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        
        if( [gestureRecognizer scale] < 0.5 ){
            if( !dismissViewCalled ){
                [self dismissCurrentView];
                dismissViewCalled = YES;
            }
            return;
        }
        
        CGFloat currentScale = [[[gestureRecognizer view].layer valueForKeyPath:@"transform.scale"] floatValue];
        
        // Constants to adjust the max/min values of zoom
        const CGFloat kMaxScale = 1.0;
        const CGFloat kMinScale = 0.4;
        
        CGFloat newScale = 1 -  (lastScale - [gestureRecognizer scale]); // new scale is in the range (0-1)
        newScale = MIN(newScale, kMaxScale / currentScale);
        newScale = MAX(newScale, kMinScale / currentScale);
        CGAffineTransform transform = CGAffineTransformScale([[gestureRecognizer view] transform], newScale, newScale);
        [gestureRecognizer view].transform = transform;
        
        lastScale = [gestureRecognizer scale];  // Store the previous scale factor for the next pinch gesture call
    }
    
    if([gestureRecognizer state] == UIGestureRecognizerStateEnded || 
       [gestureRecognizer state] == UIGestureRecognizerStateCancelled ){
        if( !dismissViewCalled ){
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.1];
            CGAffineTransform transform = CGAffineTransformMakeScale(1.0,1.0);
            self.transform = transform;
            [UIView commitAnimations];
            [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:@"NSResetBackground" object:nil ];
        }
    }
}

- (void) dismissCurrentView {
    
    PhidecksAppDelegate *appDelegate = (PhidecksAppDelegate *)   [[UIApplication sharedApplication]delegate];
    [UIView animateWithDuration:0.8f delay:0.0f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        CGAffineTransform transform = CGAffineTransformMakeScale(0.01,0.01);
        self.transform = transform;
        self.frame = appDelegate.appData.selectedDeckRect;
    }
                     completion:^(BOOL finished) {
                         if (finished) { 
                             [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:@"NSHideAllPanes" object:nil ]; //
                             [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:@"NSShowHomeScreen" object:nil ];
                         }
                     }];
}

-(void)buttonClicked:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:@"NSShowToolbar" object:nil ];
    
}

- (void) configUpdated:(id)sender  {
    
    PhidecksAppDelegate *appDelegate = (PhidecksAppDelegate *)   [[UIApplication sharedApplication]delegate];
    int color = appDelegate.appData.writeConfigData.selected_color;
    [smoothView setColor:color];
    smoothView.lineWidth = appDelegate.appData.writeConfigData.width;
}

- (void) dashedLineConfigUpdated:(id)sender{
    PhidecksAppDelegate *appDelegate = (PhidecksAppDelegate *)   [[UIApplication sharedApplication]delegate];
    [smoothView dashedLineClicked:appDelegate.appData.writeConfigData.flip_line];
}

- (void) saveCurrentViewToImage{
    
    CGRect rect = [self bounds];
    UIGraphicsBeginImageContextWithOptions(rect.size,YES,0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.layer renderInContext:context];   
    previewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
}

#pragma mark - Touch Methods
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    PhidecksAppDelegate *appDelegate = (PhidecksAppDelegate *)   [[UIApplication sharedApplication]delegate];
    if( appDelegate.appData.popup_displayed == YES){
        [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:@"NSHideAllPanes" object:nil ]; //
    }
    
    if ([touches count] == 2) {
        CGPoint nowPoint = [[touches anyObject] locationInView:self];
        if( nowPoint.x >= 1000)
            swipeUp = YES;
    }
    
    [super touchesBegan:touches withEvent:event];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    
    if ([touches count] == 2 && swipeUp) {
        
        CGPoint nowPoint = [[touches anyObject] locationInView:self];
        CGPoint prevPoint = [[touches anyObject] previousLocationInView:self];
        
        if( nowPoint.x <= prevPoint.x && nowPoint.y <= prevPoint.y){
            NSLog(@"Inside");
        }
        else {
            swipeUp = NO;
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    CGPoint nowPoint = [[touches anyObject] locationInView:self];
    
    if ([touches count] == 2 && swipeUp && nowPoint.x <= 900 && nowPoint.y <= 600) {
        [smoothView undoButtonClicked];
    }
    swipeUp = NO;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    swipeUp = NO;
}

- (void)dealloc
{
    NSLog(@"Inside SlidesView dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [smoothView removeFromSuperview];
    [super dealloc];
}

@end
