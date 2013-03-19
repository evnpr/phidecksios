//
//  SmoothLineView.m
//  Smooth Line View

//
//  SmoothLineView.m
//  Smooth Line View
//
//  Created by Levi Nunnink on 8/15/11.
//  Copyright 2011 culturezoo. All rights reserved.
//
//  modify by Hanson @ Splashtop

#import "SmoothLineView.h"
#import <QuartzCore/QuartzCore.h>

#define DEFAULT_COLOR [UIColor blackColor]
#define DEFAULT_WIDTH 5.0f
#define DEFAULT_ALPHA 1.0f

@interface SmoothLineView () 

#pragma mark Private Helper function

CGPoint midPoint(CGPoint p1, CGPoint p2);

@end

@implementation SmoothLineView

@synthesize lineAlpha;
@synthesize lineColor;
@synthesize lineWidth;

#pragma mark -

- (UIColor *)lineColor {
    return lineColor;
}



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.lineWidth = DEFAULT_WIDTH;
        self.lineColor = DEFAULT_COLOR;
        self.lineAlpha = DEFAULT_ALPHA;
        
        bufferArray=[[NSMutableArray alloc]init];
        lineArray=[[NSMutableArray alloc]init];
        colorArray=[[NSMutableArray alloc]init]; 
        
        blackColor = [[UIColor alloc] initWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
        blueColor = [[UIColor alloc] initWithRed:51.0/255.0 green:102.0/255.0 blue:153.0/255.0 alpha:1.0];
        redColor = [[UIColor alloc] initWithRed:204.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    
    switch (drawStep) {
        case DRAW:
        {
            [curImage drawAtPoint:CGPointMake(0, 0)];
            CGPoint mid1 = midPoint(previousPoint1, previousPoint2); 
            CGPoint mid2 = midPoint(currentPoint, previousPoint1);
            CGContextRef context = UIGraphicsGetCurrentContext(); 
            
            [self.layer renderInContext:context];
            CGContextMoveToPoint(context, mid1.x, mid1.y);
            CGContextAddQuadCurveToPoint(context, previousPoint1.x, previousPoint1.y, mid2.x, mid2.y); 
            CGContextSetLineCap(context, kCGLineCapRound);
            CGContextSetLineWidth(context, self.lineWidth);
            CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
            CGContextSetAlpha(context, self.lineAlpha);
            CGContextStrokePath(context);            
            [super drawRect:rect];
            [curImage release];
            
        }
            break;
        case CLEAR:
        {
            CGContextRef context = UIGraphicsGetCurrentContext(); 
            CGContextClearRect(context, rect);
            break;
        }
        case ERASE:
        {
            [curImage drawAtPoint:CGPointMake(0, 0)];
            CGContextRef context = UIGraphicsGetCurrentContext(); 
            CGContextClearRect(context, rect);
            [super drawRect:rect];
            [curImage release];
            
        }
            break;
        case UNDO:
        {
            [curImage drawInRect:self.bounds];   
            break;
        }
        case REDO:
        {
            [curImage drawInRect:self.bounds];   
            break;
        }
        case DASHED:
        {
            [curImage drawAtPoint:CGPointMake(0, 0)];
            CGPoint mid1 = midPoint(previousPoint1, previousPoint2); 
            CGPoint mid2 = midPoint(currentPoint, previousPoint1);
            CGContextRef context = UIGraphicsGetCurrentContext(); 
            
            [self.layer renderInContext:context];
            CGContextMoveToPoint(context, mid1.x, mid1.y);
            CGContextAddQuadCurveToPoint(context, previousPoint1.x, previousPoint1.y, mid2.x, mid2.y); 
            CGContextSetLineCap(context, kCGLineCapRound);
            CGContextSetLineWidth(context, self.lineWidth);
            CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
            CGContextSetAlpha(context, self.lineAlpha);
            CGFloat dashArray[] = {lineWidth,lineWidth + (lineWidth *2), lineWidth + (lineWidth *3), lineWidth + (lineWidth *4)};
            CGContextSetLineDash(context, 0, dashArray, 4);
            CGContextStrokePath(context);            
            [super drawRect:rect];
            [curImage release];
        }
            
        default:
            break;
    }    
}

#pragma mark Private Helper function

CGPoint midPoint(CGPoint p1, CGPoint p2)
{
    return CGPointMake((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5);
}

#pragma mark Gesture handle

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    UITouch *touch = [touches anyObject];
    
    previousPoint1 = [touch locationInView:self];
    previousPoint2 = [touch locationInView:self];
    currentPoint = [touch locationInView:self];
    
    pathArray=[NSMutableArray new];
    
    [super touchesBegan:touches withEvent:event];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    UITouch *touch  = [touches anyObject];
    
    previousPoint2  = previousPoint1;
    previousPoint1  = currentPoint;
    currentPoint    = [touch locationInView:self];
    
    NSArray *points = [NSArray arrayWithObjects:
                       [NSValue valueWithCGPoint:previousPoint2],
                       [NSValue valueWithCGPoint:previousPoint1],
                       [NSValue valueWithCGPoint:currentPoint],
                       nil];
    
    [pathArray addObject:points];
    if (1)
    {
        if(drawStep != ERASE && drawStep != DASHED) 
            drawStep = DRAW;
        [self calculateMinImageArea:previousPoint1 :previousPoint2 :currentPoint];
    }
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{

    UIGraphicsBeginImageContext(self.bounds.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    curImage = UIGraphicsGetImageFromCurrentImageContext();
    [curImage retain];
    UIGraphicsEndImageContext();
    
    NSDictionary *lineInfo = [NSDictionary dictionaryWithObjectsAndKeys:[pathArray copy], @"LINEARRAY",
                              self.lineColor, @"COLOR",
                              [NSNumber numberWithDouble:1.0], @"ALPHA",
                              [NSNumber numberWithDouble:self.lineWidth], @"WIDTH",
                              curImage, @"IMAGE",
                              nil];
    
    [lineArray addObject:lineInfo];
    [pathArray removeAllObjects];
    [pathArray release]; pathArray = nil;
    
    
    [curImage release];
    
}

#pragma mark Private Helper function


- (void) calculateMinImageArea:(CGPoint)pp1 :(CGPoint)pp2 :(CGPoint)cp
{
    
    // calculate mid point
    CGPoint mid1    = midPoint(pp1, pp2); 
    CGPoint mid2    = midPoint(cp, pp1);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, mid1.x, mid1.y);
    CGPathAddQuadCurveToPoint(path, NULL, pp1.x, pp1.y, mid2.x, mid2.y);
    CGRect bounds = CGPathGetBoundingBox(path);
    CGPathRelease(path);
    
    CGRect drawBox = bounds;
    
    //Pad our values so the bounding box respects our line width
    drawBox.origin.x        -= self.lineWidth * 2;
    drawBox.origin.y        -= self.lineWidth * 2;
    drawBox.size.width      += self.lineWidth * 4;
    drawBox.size.height     += self.lineWidth * 4;
    
    UIGraphicsBeginImageContext(drawBox.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    curImage = UIGraphicsGetImageFromCurrentImageContext();
    [curImage retain];
    UIGraphicsEndImageContext();
    
    [self setNeedsDisplayInRect:drawBox];
    
    [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate: [NSDate date]];
    
}

- (void)drawLines
{
    for(int x = 0 ; x<[lineArray count];x++)
    {
        NSDictionary *lineInfo = [lineArray objectAtIndex:x];
        NSMutableArray *_pathArray = (NSMutableArray*)[lineInfo valueForKey:@"LINEARRAY"];
        self.lineColor = (UIColor*)[lineInfo valueForKey:@"COLOR"];
        self.lineWidth = [(NSNumber*)[lineInfo valueForKey:@"WIDTH"] floatValue];
        self.lineAlpha = 1.0;//[(NSNumber*)[lineInfo valueForKey:@"ALPHA"] floatValue];
        
        for(int y = 0 ; y<[_pathArray count];y++)
        {
            NSArray *points = (NSArray*)[_pathArray objectAtIndex:y];
            
            previousPoint2 = [[points objectAtIndex:0] CGPointValue];
            previousPoint1 = [[points objectAtIndex:1] CGPointValue];
            currentPoint = [[points objectAtIndex:2] CGPointValue];
            drawStep = DRAW;
            [self calculateMinImageArea:previousPoint1 :previousPoint2 :currentPoint];
        }
    }
}


- (void)removeLine
{
    for(int x = 0 ; x<[bufferArray count];x++)
    {
        NSDictionary *lineInfo = [lineArray objectAtIndex:x];
        NSMutableArray *_pathArray = (NSMutableArray*)[lineInfo valueForKey:@"LINEARRAY"];
        self.lineColor = (UIColor*)[lineInfo valueForKey:@"COLOR"];
        self.lineWidth = [(NSNumber*)[lineInfo valueForKey:@"WIDTH"] floatValue];
        self.lineAlpha = 1.0;//[(NSNumber*)[lineInfo valueForKey:@"ALPHA"] floatValue];
        for(int y = 0 ; y<[_pathArray count];y++)
        {
            NSArray *points = (NSArray*)[_pathArray objectAtIndex:y];
            
            previousPoint2 = [[points objectAtIndex:0] CGPointValue];
            previousPoint1 = [[points objectAtIndex:1] CGPointValue];
            currentPoint = [[points objectAtIndex:2] CGPointValue];
            drawStep = ERASE;
            [self calculateMinImageArea:previousPoint1 :previousPoint2 :currentPoint];
        }
    }
}


-(void)redrawLine
{
    UIGraphicsBeginImageContext(self.bounds.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    NSDictionary *lineInfo = [lineArray lastObject];
    curImage = (UIImage*)[lineInfo valueForKey:@"IMAGE"];
    UIGraphicsEndImageContext();
    [self setNeedsDisplayInRect:self.bounds];    
}


#pragma mark Button Handle

-(void)undoButtonClicked
{
    if([lineArray count]>0){
        NSMutableArray *_line=[lineArray lastObject];
        [bufferArray addObject:[_line copy]];
        [lineArray removeLastObject];
        drawStep = UNDO;
        [self redrawLine];
    }
}

-(void)redoButtonClicked
{
    if([bufferArray count]>0){
        NSMutableArray *_line=[bufferArray lastObject];
        [lineArray addObject:_line];
        [bufferArray removeLastObject];
        drawStep = REDO;
        [self redrawLine];
    }
    
}
-(void)clearButtonClicked
{    
    UIGraphicsBeginImageContext(self.bounds.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    curImage = UIGraphicsGetImageFromCurrentImageContext();
    [curImage retain];
    UIGraphicsEndImageContext();
    drawStep = CLEAR;
    [self setNeedsDisplayInRect:self.bounds];
    [lineArray removeAllObjects];
    [bufferArray removeAllObjects];
}

-(void)eraserButtonClicked
{    
    if(drawStep!=ERASE)
    {
        drawStep = ERASE;
    }
    else 
    {
        drawStep = DRAW;
    }
}

- (void) dashedLineClicked: (BOOL) dash{
    
    if( dash == YES)
        drawStep = DASHED;
    else {
        drawStep = DRAW;
    }
}

-(void)setColor:(int)color
{
    if( drawStep != DRAW && drawStep != DASHED)
        drawStep = DRAW;
    
    if( color == 0 )
        lineColor = blackColor;
    else if( color == 1 )
        lineColor = redColor;
    else if( color == 2 )
        lineColor = blueColor;
    else if( color == 3 ){
        lineColor = [UIColor clearColor];
        drawStep = ERASE;
    }
}

@end


