//
//  TransitionController.h
//
//  Created by XJones on 11/25/11.
//

#import <UIKit/UIKit.h>

@interface TransitionController : UIViewController

@property (nonatomic, strong)   UIView *                containerView;
@property (nonatomic, strong)   UIViewController *      viewController;

- (id)initWithViewController:(UIViewController *)viewController;
- (void)transitionToViewController:(UIViewController *)viewController
                     withOptions:(UIViewAnimationOptions)options;
- (void)transitionToViewControllerWithBackgroundAndPoint:(UIViewController *)aViewController
                    withImage:(UIImage*) image startRect:(CGRect) rect;

- (void) setAutoResizing;
- (void) setAutoResizingNone;

@end
