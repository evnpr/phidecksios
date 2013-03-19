//
//  phidecksViewController.m
//  phidecks
//
//  Created by Meera on 02/06/12.
//  Copyright 2012 XMinds. All rights reserved.
//

#import "phidecksViewController.h"
#import "HomePageViewController.h"

@implementation phidecksViewController

@synthesize homePageViewController;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    homePageViewController = [[HomePageViewController alloc] init];
    homePageViewController.view.frame = CGRectMake(0,0,1024, 768);
    [self.view addSubview:homePageViewController.view];
    
    //decksView = [[phidecksView alloc]initWithFrame:CGRectMake(0, 45, 768, 1004)];
    //[self.view addSubview:decksView];
    
    [super viewDidLoad];
}


- (void)viewDidUnload
{
    [super viewDidUnload];

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortrait);
}

@end
