//
//  PopupView.h
//  phidecks
//
//  Created by Aneesh on 7/11/12.
//  Copyright (c) 2012 XMinds. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopupPreviewView : UIView{
 
    UIScrollView *backgroundView;
    
}
@property (nonatomic, retain) UIScrollView *backgroundView;

- (void) setPreviewPane;
- (void) removePreviewPane;
@end
