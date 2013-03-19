//
//  WriteConfigModel.m
//  phidecks
//
//  Created by Meera on 7/12/12.
//  Copyright (c) 2012 XMinds. All rights reserved.
//

#import "WriteConfigModel.h"

@implementation WriteConfigModel

@synthesize selected_color, width, flip_line;

-(id) init {
	
	if (self = [super init]) 
	{
        selected_color = 0; //1 - black, 2 - red, 3 - blue, 4 - eraser
        width = 2;
        flip_line = NO;
	}
	return self;
}


@end
