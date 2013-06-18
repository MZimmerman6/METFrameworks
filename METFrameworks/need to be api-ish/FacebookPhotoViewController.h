//
//  FacebookPhotoViewController.h
//  PhilaSciFest2012
//
//  Created by Matthew Zimmerman on 4/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FacebookPhotoViewController : UIViewController {
    
    IBOutlet UIImageView *photoView;
    UIImage *postPhoto;
    
    
}

@property (strong, nonatomic) IBOutlet UIImageView *photoView;

-(void) loadPhotoIntoView:(UIImage*)image;

-(IBAction)backPressed:(id)sender;

@end
