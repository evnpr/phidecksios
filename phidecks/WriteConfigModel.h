//
//  WriteConfigModel.h
//  phidecks
//
//  Created by Meera on 7/12/12.
//  Copyright (c) 2012 XMinds. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WriteConfigModel : NSObject{
    
    int selected_color;
    int width;
    BOOL flip_line;
}

@property int selected_color;
@property int width;
@property BOOL flip_line;
@end
