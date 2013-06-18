//
//  FacebookPhotoViewController.m
//  PhilaSciFest2012
//
//  Created by Matthew Zimmerman on 4/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FacebookPhotoViewController.h"

@interface FacebookPhotoViewController ()

@end

@implementation FacebookPhotoViewController

@synthesize photoView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


-(void) loadPhotoIntoView:(UIImage *)image {
    postPhoto = image;
}

-(void) viewWillAppear:(BOOL)animated {
    [photoView setImage:postPhoto];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [photoView setContentMode:UIViewContentModeScaleAspectFit];
    [photoView setBackgroundColor:[UIColor blackColor]];
//    [photoView setBackgroundColor:[UIColor blackColor]];
//    [self.view setBackgroundColor:[UIColor blackColor]];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
