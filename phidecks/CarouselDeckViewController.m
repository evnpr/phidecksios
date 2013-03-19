//
//  CarouselDeckViewController.m
//  phidecks
//
//  Created by Meera on 7/10/12.
//  Copyright (c) 2012 XMinds. All rights reserved.
//

#import "CarouselDeckViewController.h"
#import "iCarousel.h"
#import "PhidecksAppDelegate.h"
#import "Deck.h"
#import "NSNotificationCenter+MainThread.h"
#import "SlidesView.h"

const float PREVIEW_MARGIN_y = 10.0f;

@interface CarouselDeckViewController () <iCarouselDataSource, iCarouselDelegate, UIActionSheetDelegate>{
 
    int deck_id;
    Deck* deck;
}


@property (nonatomic, assign) BOOL wrap;

- (id) initWithDeckId:(int) l_deck_id;
- (BOOL) loadDeck;

@end

@implementation CarouselDeckViewController

@synthesize carousel;
@synthesize wrap;

- (id) initWithDeckId:(int) l_deck_id{
    
    self = [super init];
    if (self) {
        deck_id = l_deck_id;
        [self loadDeck];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    wrap = NO;
	timer = nil;
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(showPreviewPane:)
                                                 name:@"NSShowPreviewPane" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(hidePreviewPane:)
                                                 name:@"NSHidePreviewPane" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(showWritePane:)
                                                 name:@"NSShowWritePane" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(hideWritePane:)
                                                 name:@"NSHideWritePane" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(showTimerPane:)
                                                 name:@"NSShowTimerPane" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(hideTimerPane:)
                                                 name:@"NSHideTimerPane" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(hideAllPanes:)
                                                 name:@"NSHideAllPanes" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(startTimer:)
                                                 name:@"NSStartTimer" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(changeBackgroundToHomeImage:)
                                                 name:@"NSChangeBackgroundToHome" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(resetBackground:)
                                                 name:@"NSResetBackground" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(changeCarouselType:)
                                                 name:@"NSChangeCarouselType" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(startSlideShow:)
                                                 name:@"NSStartSlideShow" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(killTimerIfAny:)
                                                 name:@"NSTimerReset" object:nil];
    
	//add background
	backgroundView = [[UIImageView alloc] initWithFrame:self.view.bounds];
	backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	backgroundView.image = [UIImage imageNamed:@"background.png"];
	[self.view addSubview:backgroundView];
	
	//create carousel
	carousel = [[iCarousel alloc] initWithFrame:self.view.bounds];
	carousel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    carousel.type = iCarouselTypeTimeMachine;
    carousel.decelerationRate = 0.5;
    carousel.scrollSpeed = 2.0;
	carousel.delegate = self;
	carousel.dataSource = self;
    
	//add carousel to view
	[self.view addSubview:carousel];
    
    popupWriteView = [[PopupWriteView alloc]initWithFrame:CGRectMake(66, 150, 300, 400)];
    [self.view addSubview:popupWriteView];
    popupWriteView.alpha = 0;

    popupTimerView = [[PopupTimerView alloc]initWithFrame:CGRectMake(66, 250, 350, 400)];
    [self.view addSubview:popupTimerView];
    popupTimerView.alpha = 0;
    
    timer_on_screen = NO;
    timerDragView = nil;
    popupPreviewView = nil;

    
}

- (void)changeCarouselType:(id)sender{
    carousel.type = iCarouselTypeLinear; //Nice lil hack

}
- (void) changeBackgroundToHomeImage:(id)sender {
    PhidecksAppDelegate *appDelegate = (PhidecksAppDelegate *)   [[UIApplication sharedApplication]delegate];
    backgroundView.image = appDelegate.appData.previewHomePage;
}

- (void) resetBackground:(id)sender {

    backgroundView.image = [UIImage imageNamed:@"background.png"];
    
}

- (void) dismissAllPopups {

    PhidecksAppDelegate *appDelegate = (PhidecksAppDelegate *)   [[UIApplication sharedApplication]delegate];
    appDelegate.appData.popup_displayed = NO;
    if( popupPreviewView.alpha == 1){
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
        popupPreviewView.alpha = 0;
        [UIView commitAnimations];
    }
    
    if( popupWriteView.alpha == 1){
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
        popupWriteView.alpha = 0;
        [UIView commitAnimations];
    }
    
    if( popupTimerView.alpha == 1){
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
        popupTimerView.alpha = 0;
        [UIView commitAnimations];
    }
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:@"NSResetFlags" object:nil ];
}

- (void) startSlideShow:(id)sender{
    
    [self dismissAllPopups];
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:@"NSHideToolbar" object:nil ];
    if( carousel.currentItemIndex != 0 )
        [carousel scrollToItemAtIndex:0 animated:YES];
    timer = [NSTimer timerWithTimeInterval:3 target:self selector:@selector(showNextSlide) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];	
}

- (void) showNextSlide{
    
    if( carousel.currentItemIndex < carousel.numberOfItems ){
        [carousel scrollToItemAtIndex:(carousel.currentItemIndex + 1) animated:YES];
    }
    else{
        [timer invalidate];
        timer = nil;
    }
}

-(void)startTimer:(id)sender{
    
    if( !timer_on_screen ){
        PhidecksAppDelegate *appDelegate = (PhidecksAppDelegate *)   [[UIApplication sharedApplication]delegate];
        if( timerDragView != nil ){
            [timerDragView release];
            timerDragView = nil;            
        }
        timerDragView = [[TimerDragView alloc] initWithFrameAndValue:CGRectMake(600,100,270, 350) value:appDelegate.appData.timerValue];
        [self.view addSubview:timerDragView];
        [timerDragView startTimer];
        timer_on_screen = YES;
    }
}

- (void) killTimerIfAny:(id)sender{
    
    if( timer_on_screen ){
        [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:@"NSKillTimer" object:nil ];
        [timerDragView removeFromSuperview];
        [timerDragView release];
        timerDragView = nil;
        timer_on_screen = NO;
    }
}

-(BOOL) loadDeck{
    
    PhidecksAppDelegate *appDelegate = (PhidecksAppDelegate *)   [[UIApplication sharedApplication]delegate];
    deck = [appDelegate.appData.my_decks_dict objectForKey:[NSString stringWithFormat:@"%d", deck_id]];
    if( deck == nil){
        return NO;
    }
    return YES;
}

- (void)hideAllPanes:(id)sender{
    
    [self dismissAllPopups];
}

-(void)showPreviewPane:(id)sender {
    
    [self dismissAllPopups];
    
    PhidecksAppDelegate *appDelegate = (PhidecksAppDelegate *)   [[UIApplication sharedApplication]delegate];
    
    if( popupPreviewView != nil ){
        [popupPreviewView removePreviewPane];
        [popupPreviewView removeFromSuperview];
        [popupPreviewView release]; //We must do this to release all the UIIMages
        popupPreviewView = nil;
    }
    
    popupPreviewView = [[PopupPreviewView alloc]initWithFrame:CGRectMake(66, 50, 400, 690)];
    [self.view addSubview:popupPreviewView];
    popupPreviewView.alpha = 0;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    popupPreviewView.alpha = 1;
    [UIView commitAnimations];
    [popupPreviewView removePreviewPane];
    [popupPreviewView setPreviewPane];
    [self loadPreviewPane];
    appDelegate.appData.popup_displayed = YES;
}

-(void)hidePreviewPane:(id)sender {
    
    PhidecksAppDelegate *appDelegate = (PhidecksAppDelegate *)   [[UIApplication sharedApplication]delegate];
    
    appDelegate.appData.popup_displayed = NO;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    popupPreviewView.alpha = 0;
    [UIView commitAnimations];
}

- (void)showWritePane:(id)sender{
    
    [self dismissAllPopups];
    
    PhidecksAppDelegate *appDelegate = (PhidecksAppDelegate *)   [[UIApplication sharedApplication]delegate];
    appDelegate.appData.popup_displayed = YES;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    popupWriteView.alpha = 1;
    [UIView commitAnimations];
    appDelegate.appData.popup_displayed = YES;
    
}
- (void)hideWritePane:(id)sender{
    
    PhidecksAppDelegate *appDelegate = (PhidecksAppDelegate *)   [[UIApplication sharedApplication]delegate];
    appDelegate.appData.popup_displayed = NO;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    popupWriteView.alpha = 0;
    [UIView commitAnimations];
    
}

- (void)showTimerPane:(id)sender{
    
    [self dismissAllPopups];
    
    PhidecksAppDelegate *appDelegate = (PhidecksAppDelegate *)   [[UIApplication sharedApplication]delegate];
    appDelegate.appData.popup_displayed = YES;
    
    if( timer_on_screen ){
        [self showNotificationBar];
        return;
    }
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    popupTimerView.alpha = 1;
    [UIView commitAnimations];
}

- (void)hideTimerPane:(id)sender{
    
    PhidecksAppDelegate *appDelegate = (PhidecksAppDelegate *)   [[UIApplication sharedApplication]delegate];
    appDelegate.appData.popup_displayed = NO;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    popupTimerView.alpha = 0;
    [UIView commitAnimations];
}

- (void) loadPreviewPane {
    
    int item_count = carousel.numberOfItems;
    int y = PREVIEW_MARGIN_y;
    
    for( int i=0;i<item_count;i++){
        
        UIImageView *imgView = [[[UIImageView alloc] initWithFrame:CGRectMake(40,y,262,200)] autorelease];
        [imgView.layer setBorderColor: [[UIColor blackColor] CGColor]];
        [imgView.layer setBorderWidth: 2.0];
        imgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        UIView *view = [carousel itemViewAtIndex:i];
        if( view != nil ){
            if( [view isKindOfClass:[SlidesView class]] ){
                SlidesView *sview = (SlidesView*) view;
                [sview saveCurrentViewToImage];
                imgView.image = sview.previewImage;
            }
        }
        else{
            imgView.image = [deck.slideImages objectAtIndex:i];
        }
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(40,y,262,200);
        button.tag = i;
        [button setImage:imgView.image forState:UIControlStateNormal];
        [button setEnabled:YES];
        
        CALayer * layer = [button layer];
        [layer setMasksToBounds:YES];
        [layer setCornerRadius:1.0]; //note that when radius is 0, the border is a rectangle
        [layer setBorderWidth:2.0];
        [layer setBorderColor:[[UIColor blackColor] CGColor]];
        
        [button addTarget:self action:@selector(previewImageClicked:) forControlEvents:UIControlEventTouchUpInside];
        [popupPreviewView.backgroundView addSubview:button];
        
        y += 200 + PREVIEW_MARGIN_y;
    }
    
    popupPreviewView.backgroundView.contentSize = CGSizeMake(400 - 56, y );
    popupPreviewView.backgroundView.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"drop-center.png"]];;
 
}

- (void) showNotificationBar {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0,768 + 100, 1024, 50)];
    view.backgroundColor = [[UIColor alloc] initWithRed:51.0/255.0 green:102.0/255.0 blue:153.0/255.0 alpha:1.0];
    [self.view addSubview:view];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(350, 10, 300, 30)];
    [label setText:@"A timer is already on the screen!"];
    label.backgroundColor = [UIColor clearColor];
    [view addSubview:label];
    
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationCurveEaseInOut
                     animations:^{
                         [view setFrame: CGRectMake(0, 768 - 50, 1024, 50)];
                     } 
                     completion:^(BOOL finished){
                         
                         [UIView animateWithDuration:0.5
                                       delay:3.0
                                     options: UIViewAnimationCurveEaseInOut
                                  animations:^{
                                      [view setFrame: CGRectMake(0,768 + 100, 1024, 50)];
                                  } 
                                  completion:^(BOOL finished){
                                      [label removeFromSuperview];
                                      [label release];
                                      [view release];
                                  }];
                     }];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortrait);
}

- (void)previewImageClicked:(id)sender {
    UIButton* button = (UIButton*) sender;
    int idx = button.tag;
    
    [carousel scrollToItemAtIndex:idx duration:0.6f];
}

#pragma mark -
#pragma mark iCarousel methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return [deck slidesnumber];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    if (view == nil)
    {
        SlidesView* sView = [[[SlidesView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)] autorelease];
        sView.image = [deck.slideImages objectAtIndex:index];
        return sView;
    }
    else
    {
    }
    return view;
}

- (CATransform3D)carousel:(iCarousel *)_carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform
{
    //implement 'flip3D' style carousel
    transform = CATransform3DRotate(transform, M_PI / 8.0f, 0.0f, 1.0f, 0.0f);
    return CATransform3DTranslate(transform, 0.0f, 0.0f, offset * carousel.itemWidth);
}

- (CGFloat)carousel:(iCarousel *)_carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    //customize carousel display
    switch (option)
    {
        case iCarouselOptionWrap:
        {
            //normally you would hard-code this to YES or NO
            return wrap;
        }
        case iCarouselOptionSpacing:
        {
            //add a bit of spacing between the item views
            return value * 1.05f;
        }
        case iCarouselOptionFadeMax:
        {
            if (carousel.type == iCarouselTypeCustom)
            {
                //set opacity based on distance from camera
                return 0.0f;
            }
            return value;
        }
        case iCarouselOptionShowBackfaces:
        {
            return NO;
        }
        default:
        {
            return value;
        }
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) dealloc {
    
    if( timer != nil)
        [timer invalidate];
    [carousel release];
    if( popupPreviewView != nil ){
        [popupPreviewView removePreviewPane];
        [popupPreviewView removeFromSuperview];
        [popupPreviewView release];
    }
    
    [popupWriteView release];
    [popupTimerView release];

    [backgroundView release];
    if( timerDragView != nil)
        [timerDragView release];

    [super dealloc];
}
@end
