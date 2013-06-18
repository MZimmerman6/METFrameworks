//
//  FacebookViewController.m
//  PhilaSciFest2012
//
//  Created by Matthew Zimmerman on 4/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FacebookViewController.h"
#import "AppDelegate.h"
#import "FacebookPost.h"
@interface FacebookViewController ()

@end

@implementation FacebookViewController

@synthesize facebook, feedTable, loginButton, photoViewer, gotFeed;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    photoViewer = [[FacebookPhotoViewController alloc] initWithNibName:@"FacebookPhotoViewController" bundle:nil];
    tableCells = [[NSMutableArray alloc] init];
    fbBlue = [UIColor colorWithRed:0.2314 green:0.3490 blue:0.5961 alpha:1];
    linkTanColor = [UIColor colorWithRed:0.8784 green:0.8039 blue:0.5882 alpha:0.2];
    facebookFeedArray = [[NSMutableArray alloc] init];
    // Do any additional setup after loading the view from its nib.
}

-(void) checkIfFacebookValid {
    
    if ([facebook isSessionValid]) {
        if (wasLoggedOff) {
            wasLoggedOff = NO;
            [self viewDidAppear:YES];
        }
        [loginButton setTitle:@"Logout"];
    } else {
        if ([facebookFeedArray count] != 0) {
            facebookFeedArray = [[NSMutableArray alloc] init];
            gotFeed = NO;
            [feedTable reloadData];
        }
        [loginButton setTitle:@"Login"];
        if (!wasLoggedOff) {
            wasLoggedOff = YES;
        }
    }
}

-(void) viewWillAppear:(BOOL)animated {
    AppDelegate* navigationDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    facebook = [navigationDelegate facebook];
    
    wasLoggedOff = ![facebook isSessionValid];
    [self updateLogButton];
    [self checkIfFacebookValid];
    validityTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self 
                                                   selector:@selector(checkIfFacebookValid) 
                                                   userInfo:nil 
                                                    repeats:YES];
}

-(void) updateLogButton {
    if ([facebook isSessionValid]) {
        [loginButton setTitle:@"Logout"];
    } else {
        [loginButton setTitle:@"Login"];
    } 
}

-(void) viewDidAppear:(BOOL)animated {
    
    feedConnectionDone = NO;
    
    if (!gotFeed) {
        if ([facebook isSessionValid]) {
            UIApplication* app = [UIApplication sharedApplication];
            app.networkActivityIndicatorVisible = YES;
            feedData = [[NSMutableData alloc] init];
            NSString *feedString = [NSString stringWithFormat:@"https://graph.facebook.com/PHLScienceFest/feed?access_token=%@",[facebook accessToken]]; 
            feedRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:feedString] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:15];
            feedConnection = [[NSURLConnection alloc] initWithRequest:feedRequest delegate:self];
        } else {
            facebookFeedArray = [[NSMutableArray alloc] init];
            [feedTable reloadData];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook Not Authorized" message:@"You did not authorize the application to load Facebook, so can not display information" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
}

-(void) viewDidDisappear:(BOOL)animated {
    [validityTimer invalidate];
}


-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    if (connection == feedConnection) {
        [feedData appendData:data];
    } else {
        for (int i = 0;i<[facebookFeedArray count];i++) {
            if (connection  == [[facebookFeedArray objectAtIndex:i] picConnection]) {
                [[[facebookFeedArray objectAtIndex:i] profilePicData] appendData:data];
                break;
            } else if (connection  == [[facebookFeedArray objectAtIndex:i] postPhotoConnection]) {
                [[[facebookFeedArray objectAtIndex:i] postPhotoData] appendData:data];
                break;
                NSLog(@"got post data");
            }
        }
    }
}

-(void) connectionDidFinishLoading:(NSURLConnection *)connection {
    if (connection == feedConnection) {
        [self processNewsFeed];
        gotFeed = YES;
        
    } else {
        for (int i = 0;i<[facebookFeedArray count];i++) {
            FacebookPost *tempPost = [facebookFeedArray objectAtIndex:i];
            if (connection  == [tempPost picConnection]) {
                [tempPost setProfilePic:[UIImage imageWithData:[tempPost profilePicData]]];
                [tempPost setProfileDone:YES];
                [tempPost setPicConnectionDone:YES];
                [tempPost setGotProfilePic:YES];
                [tempPost setPostNeedsUpdating:YES];
                //                NSLog(@"got Picture Data");
                break;
            } else if (connection  == [tempPost postPhotoConnection]) {
                [tempPost setPostPhoto:[UIImage imageWithData:[tempPost postPhotoData]]];
                [tempPost setPostPhotoDone:YES];
                [tempPost setPostPhotoConnectionDone:YES];
                [tempPost setGotPostPhoto:YES];
                [tempPost setPostNeedsUpdating:YES];
                break;
            }
        }
    }
    if ([self allPhotosDoneLoading]) {
        UIApplication* app = [UIApplication sharedApplication];
        app.networkActivityIndicatorVisible = NO;
    }
    [self updateTableCells];
}

-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    for (int i = 0;i<[facebookFeedArray count];i++) {
        FacebookPost *tempPost = [facebookFeedArray objectAtIndex:i];
        if (connection  == [tempPost picConnection]) {
            [tempPost setPicConnectionDone:YES];
            break;
        } else if (connection  == [tempPost postPhotoConnection]) {
            [tempPost setPostPhotoConnectionDone:YES];
            break;
        }
    }
    
    if ([self allPhotosDoneLoading]) {
        UIApplication* app = [UIApplication sharedApplication];
        app.networkActivityIndicatorVisible = NO;
    }
}

-(void) updateTableCells {
    
    static NSString *CellIdentifier = @"Cell";
    tableCells = [[NSMutableArray alloc] init];
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    if ([facebookFeedArray count]>0) {
        for (int i = 0;i<[facebookFeedArray count];i++) {
            FacebookPost *tempPost = [facebookFeedArray objectAtIndex:i];
            if ([tempPost postNeedsUpdating]) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
                
                cell.backgroundColor = [UIColor whiteColor];
                FacebookPost *tempPost = [facebookFeedArray objectAtIndex:i];
                UIView *postView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, [tempPost postCellHeight])];
                
                UIImageView *profileView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 60, 60)];
                [profileView setBackgroundColor:[UIColor grayColor]];
                
                if ([tempPost gotProfilePic]) {
                    [profileView setImage:[tempPost profilePic]];
                    [tempPost setProfilePicDisplayed:YES];
                } else {
                    [profileView setImage:[UIImage imageNamed:@"facebookBlank.png"]];
                }
                
                [postView addSubview:profileView];
                
                UITextView *nameView = [[UITextView alloc] initWithFrame:CGRectMake(65, -5, 250, 50)];
                nameView.backgroundColor = [UIColor clearColor];
                nameView.textColor = fbBlue;
                nameView.userInteractionEnabled = NO;
                nameView.editable = NO;
                nameView.text = [tempPost fromName];
                nameView.font = [UIFont boldSystemFontOfSize:16];
                [postView addSubview:nameView];
                int nameHeight = nameView.contentSize.height;
                
                UITextView *messageView = [[UITextView alloc] initWithFrame:CGRectMake(65, nameHeight-20, 250, 300)];
                messageView.backgroundColor = [UIColor clearColor];
                messageView.editable = NO;
                messageView.userInteractionEnabled = NO;
                messageView.textColor = [UIColor blackColor];
                messageView.font = [UIFont systemFontOfSize:14];
                messageView.text = [tempPost message];
                [postView addSubview:messageView];
                int messageHeight = messageView.contentSize.height;
                
                float startY = 0;
                if (messageHeight + 30 > 80) {
                    //        NSLog(@"%i,%i",nameHeight, messageHeight);
                    startY = messageHeight+25;
                    //        NSLog(@"%f",startY);
                } else {
                    startY = 80;
                }
                
                UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(73, startY , 250, 20)];
                dateLabel.textColor = [UIColor lightGrayColor];
                dateLabel.userInteractionEnabled = NO;
                dateLabel.font = [UIFont systemFontOfSize:12];
                dateLabel.backgroundColor = [UIColor clearColor];
                dateLabel.text = [tempPost dateString];
                [cell addSubview:dateLabel];
                
                startY += 20;
                
                
                if ([[tempPost type] caseInsensitiveCompare:@"link"] == NSOrderedSame) {
                    
                    float linkHeight = 70;
                    float linkY = 0;
                    UIView *linkView = [[UIView alloc] initWithFrame:CGRectMake(30, startY, 290, linkHeight)];
                    [linkView setBackgroundColor:linkTanColor];
                    UIImageView *linkImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10 , 50, 50)];
                    [linkImage setContentMode:UIViewContentModeScaleAspectFit];
                    [linkImage setBackgroundColor:[UIColor lightGrayColor]];
                    if ([tempPost gotPostPhoto]) {
                        [linkImage setImage:[tempPost postPhoto]];
                        [linkImage setBackgroundColor:[UIColor blackColor]];
                    }
                    [linkView addSubview:linkImage];
                    
                    
                    UITextView *linkNameView = [[UITextView alloc] initWithFrame:CGRectMake(65, -5, 230, 47)];
                    linkNameView.backgroundColor = [UIColor clearColor];
                    linkNameView.textColor = fbBlue;
                    linkNameView.userInteractionEnabled = NO;
                    linkNameView.editable = NO;
                    linkNameView.text = [tempPost name];
                    linkNameView.font = [UIFont boldSystemFontOfSize:14];
                    [linkView addSubview:linkNameView];
                    int linkNameHeight = linkNameView.contentSize.height;
                    if (linkNameHeight > 47) {
                        linkY = 35;
                    } else {
                        linkY = linkNameHeight-20;
                    }
                    linkHeight += linkY;
                    
                    UILabel *linkDetail = [[UILabel alloc] initWithFrame:CGRectMake(73, linkY+2, 250, 20)];
                    linkDetail.textColor = [UIColor lightGrayColor];
                    linkDetail.userInteractionEnabled = NO;
                    linkDetail.font = [UIFont systemFontOfSize:12];
                    linkDetail.backgroundColor = [UIColor clearColor];
                    linkDetail.text = [tempPost caption];
                    
                    [linkView addSubview:linkDetail];
                    linkY += 15;
                
                    UITextView *descriptionView = [[UITextView alloc] initWithFrame:CGRectMake(65, linkY, 225, 75)];
                    descriptionView.backgroundColor = [UIColor clearColor];
                    descriptionView.textColor = [UIColor blackColor];
                    descriptionView.userInteractionEnabled = NO;
                    descriptionView.editable = NO;
                    descriptionView.text = [tempPost description];
                    descriptionView.font = [UIFont systemFontOfSize:13];
                    [linkView addSubview:descriptionView];
                    int descriptionHeight = descriptionView.contentSize.height;
                    if (descriptionHeight > 75) {
                        linkHeight = linkY + 75;
                    } else {
                        linkHeight = linkY + descriptionHeight;
                    }
                    
                    if (linkHeight <70) {
                        linkHeight = 70;
                    }
                    linkView.frame = CGRectMake(30, startY, 290, linkHeight);
                    [cell addSubview:linkView];
                    startY += linkHeight+10;
                } else if ([[tempPost type] caseInsensitiveCompare:@"photo"] == NSOrderedSame) {
                    
                    
                    UIImageView *photoView = [[UIImageView alloc] initWithFrame:CGRectMake(35, startY, 250, 250)];
                    [photoView setBackgroundColor:[UIColor lightGrayColor]];
                    [photoView setContentMode:UIViewContentModeScaleAspectFit];
                    if ([tempPost gotPostPhoto]) {
                        [photoView setImage:[tempPost postPhoto]];
                        [photoView setBackgroundColor:[UIColor clearColor]];
                    }
                    
                    [cell addSubview:photoView];
                    startY += 260;
                    
                } 
                
                [cell addSubview:postView];
//                [tableCells addObject:cell];
                [tempPost setPostNeedsUpdating:NO];
                [tempPost setPostCell:cell];
                [tempPost setPostCellHeight:startY];
            }
        }
    }
    if ([self allPhotosDoneLoading]) {
        UIApplication* app = [UIApplication sharedApplication];
        app.networkActivityIndicatorVisible = NO;
    }
    [feedTable reloadData];
}

-(BOOL) allPhotosDoneLoading {
    
    for (int i = 0;i<[facebookFeedArray count];i++) {
        FacebookPost *tempPost = [facebookFeedArray objectAtIndex:i];
        if (![tempPost postPhotoConnectionDone]) {
            return NO;
        } else if (![tempPost picConnectionDone]) {
            return NO;
        }
    }
    return YES;
}

-(void) processNewsFeed {
    
    facebookFeedArray = [[NSMutableArray alloc] init];
    NSDictionary *feedDictionary = [NSJSONSerialization JSONObjectWithData:feedData 
                                                                   options:NSJSONReadingMutableLeaves 
                                                                     error:nil];
    FacebookPost *tempPost = [[FacebookPost alloc] init];
    NSArray *feedArray = [feedDictionary objectForKey:@"data"];
    NSDictionary *tempDict = [[NSDictionary alloc] init];
    for (int i =0;i<[feedArray count];i++) {
        tempDict = [feedArray objectAtIndex:i];
        tempPost = [[FacebookPost alloc] init];
        [tempPost setName:[tempDict objectForKey:@"name"]];
        [tempPost setFromName:[[tempDict objectForKey:@"from"] objectForKey:@"name"]];
        [tempPost setFromID:[[tempDict objectForKey:@"from"] objectForKey:@"id"]];
        [tempPost setLink:[tempDict objectForKey:@"link"]];
        [tempPost setIdentifier:[tempDict objectForKey:@"id"]];
        NSString *profilePicString = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture",[tempPost fromID]];
        [tempPost setPicture:profilePicString];
        [tempPost setMessage:[tempDict objectForKey:@"message"]];
        [tempPost setDescription:[tempDict objectForKey:@"description"]];
        [tempPost setType:[tempDict objectForKey:@"type"]];
        [tempPost setCaption:[tempDict objectForKey:@"caption"]];
        [tempPost setLikes:[[tempDict objectForKey:@"likes"] objectForKey:@"count"]];
        [tempPost setPostCellHeight:70];
        [tempPost setProfileDone:NO];
        
        NSString *postPhotoString = [tempDict objectForKey:@"picture"];
        if ([[tempPost type] caseInsensitiveCompare:@"photo"]==NSOrderedSame) {
            postPhotoString = [postPhotoString stringByReplacingOccurrencesOfString:@"_s.jpg" withString:@"_n.jpg"];   
        }
        
        [tempPost setPostPhotoString:postPhotoString];
        [tempPost setPostPhotoDone:NO];
        [tempPost setPostPhotoData:[[NSMutableData alloc] init]];
        [tempPost setProfilePicData:[[NSMutableData alloc] init]];
        [tempPost setPicConnectionDone:YES];
        [tempPost setPostPhotoConnectionDone:YES];
        [tempPost setPostPhotoConnectionStarted:NO];
        [tempPost setPicConnectionStarted:NO];
        [tempPost setGotPostPhoto:NO];
        [tempPost setGotProfilePic:NO];
        [tempPost setProfilePicDisplayed:NO];
        [tempPost setPostPhotoDisplayed:NO];
        [tempPost setPostNeedsUpdating:YES];
        //        NSLog(@"%@",[tempPost fromName]);
        //        NSLog(@"%@",[tempDict objectForKey:@"to"]);
        //        NSLog(@"%@",[tempPost message]);
        NSArray *actionArray = [tempDict objectForKey:@"actions"];
        NSDictionary *tempAction;
        for (int j =0;j<[actionArray count];j++) {
            tempAction = [actionArray objectAtIndex:j];
            if ([[tempAction objectForKey:@"name"] isEqualToString:@"Comment"]) {
                [tempPost setCommentLink:[tempAction objectForKey:@"link"]];
            } else if ([[tempAction objectForKey:@"name"] isEqualToString:@"Like"]) {
                [tempPost setLikeLink:[tempAction objectForKey:@"link"]];
            }
        }
        
        [tempPost setCreatedTime:[tempDict objectForKey:@"created_time"]];
        [facebookFeedArray addObject:tempPost];
    }
    NSLog(@"Done Getting Facebook posts");
    if ([self allPhotosDoneLoading]) {
        UIApplication* app = [UIApplication sharedApplication];
        app.networkActivityIndicatorVisible = NO;
    }
    
//    tableCells = [[NSMutableArray alloc] initWithCapacity:[facebookFeedArray count]];
    NSString *CellIdentifier = @"cell";
    for (int i =0;i<[facebookFeedArray count];i++) {
        [tableCells addObject:[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier]];
    }
    
    [self updateTableCells];
}

-(IBAction)backPressed:(id)sender {
    
    [UIView beginAnimations:@"transition" context:nil];
    [UIView setAnimationDuration:0.75];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:self.navigationController.view cache:NO];
    [self.navigationController popViewControllerAnimated:NO];
    [UIView commitAnimations];
    
    gotFeed = NO;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[facebookFeedArray objectAtIndex:indexPath.row] postCellHeight];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return [facebookFeedArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FacebookPost *tempPost = [facebookFeedArray objectAtIndex:indexPath.row];
    if (![tempPost picConnectionStarted]) {
        //            NSLog(@"%@",[tempPost picture]);
        NSURLRequest *tempRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[tempPost picture]] 
                                                          cachePolicy:NSURLRequestReloadIgnoringCacheData 
                                                      timeoutInterval:10];
        [tempPost setPicConnection:[[NSURLConnection alloc] initWithRequest:tempRequest delegate:self]];
        [tempPost setPicConnectionStarted:YES];
        [tempPost setPicConnectionDone:NO];
        UIApplication* app = [UIApplication sharedApplication];
        app.networkActivityIndicatorVisible = YES;
    }
    
    if (([[tempPost type] caseInsensitiveCompare:@"link"] == NSOrderedSame) || ([[tempPost type] caseInsensitiveCompare:@"photo"] ==NSOrderedSame)) {
        if (![tempPost postPhotoConnectionStarted]) {
//            NSLog(@"%@",[tempPost postPhotoString]);
            NSURLRequest *tempRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[tempPost postPhotoString]] 
                                                              cachePolicy:NSURLRequestReloadIgnoringCacheData 
                                                          timeoutInterval:10];
            [tempPost setPostPhotoConnection:[[NSURLConnection alloc] initWithRequest:tempRequest delegate:self]];
            [tempPost setPostPhotoConnectionStarted:YES];
            [tempPost setPostPhotoConnectionDone:NO];
            UIApplication* app = [UIApplication sharedApplication];
            app.networkActivityIndicatorVisible = YES;
        }
    }
    
    return [[facebookFeedArray objectAtIndex:indexPath.row] postCell];
} 

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FacebookPost *tempPost = [facebookFeedArray objectAtIndex:indexPath.row];
    NSString *linkString = @"";
    if ([[tempPost type] caseInsensitiveCompare:@"link"] == NSOrderedSame) {
        linkString = [tempPost link];
        NSURL *linkURL  = [NSURL URLWithString:linkString];
        [[UIApplication sharedApplication] openURL:linkURL];
    } else if ([[tempPost type] caseInsensitiveCompare:@"photo"] == NSOrderedSame) {
        NSLog(@"%@",[tempPost postPhotoString]);
        [photoViewer loadPhotoIntoView:[tempPost postPhoto]];
        [self.navigationController pushViewController:photoViewer animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction)logoutPressed:(id)sender {

    if ([facebook isSessionValid]) {
        [facebook logout];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults removeObjectForKey:@"FBAccessTokenKey"];
        [defaults removeObjectForKey:@"FBExpirationDateKey"];
        [defaults synchronize];
        [self updateLogButton];
    } else {
        [self updateLogButton];
        [facebook authorize:nil];
    }
}

@end
