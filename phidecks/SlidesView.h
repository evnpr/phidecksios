//
//  phidecksView.h
//  phidecks
//
//  Created by Aneesh on 05/06/12.
//  Copyright 2012 XMinds. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SmoothLineView.h"

#define kMinimumPinchDelta 100

@interface SlidesView : UIView
{
    UIButton *button;
    UIImage* image;    
    UIImage* previewImage;
    int width;
    CGFloat  initialDistance;
    CGFloat lastScale;
    BOOL dismissViewCalled;
    
    SmoothLineView* smoothView;
    
    BOOL swipeUp;
}

-(void)buttonClicked:(id)sender;
- (void) configUpdated:(id)sender ;
- (void) saveCurrentViewToImage;

@property(nonatomic, retain) UIButton *button;
@property(nonatomic, retain) UIImage* image;
@property(nonatomic, retain) UIImage* previewImage;
@end
