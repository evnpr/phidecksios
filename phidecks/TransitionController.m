//
//  TransitionController.m
//
//  Created by XJones on 11/25/11.
//

#import "TransitionController.h"
#import "PhidecksAppDelegate.h"
#import "NSNotificationCenter+MainThread.h"
#import "CarouselDeckViewController.h"

@implementation TransitionController

@synthesize containerView = _containerView,
            viewController = _viewController;

- (id)initWithViewController:(UIViewController *)viewController
{
    if (self = [super init]) {
        _viewController = viewController;
    }
    return self;
}

- (void)loadView
{
    self.wantsFullScreenLayout = YES;
    UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.view = view;
    
    _containerView = [[UIView alloc] initWithFrame:view.bounds];
    _containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_containerView];
    [_containerView addSubview:self.viewController.view];
}

- (void) setAutoResizingNone {
    
    _containerView.autoresizingMask = UIViewAutoresizingNone;
    self.view.autoresizingMask = UIViewAutoresizingNone;
}

- (void) setAutoResizing {
    
    int a = _containerView.autoresizingMask;
    _containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    a = _containerView.autoresizingMask;
    a = self.view.autoresizingMask;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    a = self.view.autoresizingMask;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortrait);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
//    [self.viewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
  //  [self.viewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)transitionToViewController:(UIViewController *)aViewController
                       withOptions:(UIViewAnimationOptions)options
{
    [UIView transitionWithView:self.containerView
                      duration:0.3f
                       options:options
                    animations:^{
                        [self.viewController.view removeFromSuperview];
                        [self.containerView addSubview:aViewController.view];
                    }
                    completion:^(BOOL finished){
                        if( [self.viewController isKindOfClass:[CarouselDeckViewController class]] )
                            [self.viewController release];
                        self.viewController = aViewController;
                    }];
}
- (void)transitionToViewControllerWithBackgroundAndPoint:(UIViewController *)aViewController
                                               withImage:(UIImage*) image startRect:(CGRect) rect
{
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    [self.viewController.view removeFromSuperview];
    
    NSLog(@"%f,%f", rect.origin.x, rect.origin.y);
    aViewController.view.frame = rect;
    CGAffineTransform transform = CGAffineTransformMakeScale(0.1,0.1);
    aViewController.view.transform = transform;
    [self.containerView addSubview:aViewController.view];
    
    [UIView animateWithDuration:0.8f delay:0.0f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        CGAffineTransform transform = CGAffineTransformMakeScale(1.0,1.0);
        aViewController.view.transform = transform;
        aViewController.view.frame = CGRectMake(0,0,1024,768);
        
    }
     completion:^(BOOL finished) {
         if (finished) { 
             self.viewController = aViewController;
             [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:@"NSChangeCarouselType" object:nil ];
         }
     }];
    
}

@end
