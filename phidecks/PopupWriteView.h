//
//  PopupWriteView.h
//  phidecks
//
//  Created by Aneesh on 7/12/12.
//  Copyright (c) 2012 XMinds. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopupWriteView : UIView{
    
    
    UIView *contentView;
}

-(void)flipDashed:(id)sender;
- (void)sliderValueChanged:(id)sender;
-(void)blackPenSelected:(id)sender;
-(void)redPenSelected:(id)sender;
-(void)bluePenSelected:(id)sender;
-(void)eraserSelected:(id)sender;

@end
