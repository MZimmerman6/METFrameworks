//
//  FacebookViewController.h
//  PhilaSciFest2012
//
//  Created by Matthew Zimmerman on 4/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"
#import "FacebookPhotoViewController.h"

@interface FacebookViewController : UIViewController <UIWebViewDelegate, NSURLConnectionDelegate, NSURLConnectionDownloadDelegate, UITableViewDataSource, UITableViewDelegate> {
    
    Facebook *facebook;
    NSURLRequest *feedRequest;
    NSURLConnection *feedConnection;
    NSMutableData *feedData;
    BOOL feedConnectionDone;
    NSMutableArray *facebookFeedArray;
    IBOutlet UITableView *feedTable;
    UIColor *fbBlue;
    UIColor *linkTanColor;
    NSMutableArray *tableCells;
    NSTimer *validityTimer;
    BOOL wasLoggedOff;
    BOOL gotFeed;
    
    FacebookPhotoViewController *photoViewer;
    
    
}

@property BOOL gotFeed;
@property (strong, nonatomic) FacebookPhotoViewController *photoViewer;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *loginButton;
@property (strong, nonatomic) Facebook *facebook;
@property (strong, nonatomic) IBOutlet UITableView *feedTable;

-(IBAction)backPressed:(id)sender;

-(void) processNewsFeed;

-(void) tableReload;

-(void) updateTableCells;

-(void) startConnectionForObject:(int)number;

-(BOOL) allPhotosDoneLoading;

-(void) updateLogButton;

-(IBAction)logoutPressed:(id)sender;

-(void) checkIfFacebookValid;

@end
