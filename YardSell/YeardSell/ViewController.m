//
//  ViewController.m
//  YeardSell
//
//  Created by A. K. M. Saleh Sultan on 9/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "MapViewController.h"



@interface ViewController ()

@end

@implementation ViewController


- (void) guestButtonPressed {
    MapViewController *mapVeiw = [[MapViewController alloc]initWithNibName:@"MapViewController" bundle:nil];
    UIBarButtonItem *barBtton = [[UIBarButtonItem alloc]init ];
    barBtton.title = @"Back";
    self.navigationItem.backBarButtonItem = barBtton;
    [self.navigationController pushViewController:mapVeiw animated:YES];
}


- (void) signUpButtonPressed {
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.title = @"Yard Sell";
    activityIndicator.hidden = TRUE;
    
    UIBarButtonItem *guestbutton = [[UIBarButtonItem alloc]initWithTitle:@"Guest" style:UIBarButtonItemStyleDone target:self action:@selector(guestButtonPressed)];
    self.navigationItem.rightBarButtonItem = guestbutton;
    
    UIBarButtonItem *signUp = [[UIBarButtonItem alloc]initWithTitle:@"SignUp" style:UIBarButtonItemStylePlain target:self action:@selector(signUpButtonPressed)];
    self.navigationItem.leftBarButtonItem = signUp;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
