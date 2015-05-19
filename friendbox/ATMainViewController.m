#import "ATMainViewController.h"
/*
 =================================================================================== CHANGELOG ============================================================================================
 *** = live on the appstore
 **# = Done but not yet live on the appstore
 *## = Under Progress
 ### = Not started
 
 **# 1.0
 • Initial Release.
 =================================================================================== CHANGELOG ============================================================================================
 */
#define FACEBOOK_APPID @"1604655383091461"


@implementation ATMainViewController

#pragma mark - Primary Funtions -
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1];
    self.view.frame = [[UIScreen mainScreen]bounds];
    
    shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.FriendboxSharingDefaults"];
    
    horizontalScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    horizontalScrollView.contentSize = CGSizeMake(self.view.bounds.size.width*2, self.view.bounds.size.height);
    horizontalScrollView.bounces = NO;
    horizontalScrollView.delegate = self;
    horizontalScrollView.pagingEnabled = YES;
    horizontalScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    horizontalScrollView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.01];
    [self.view addSubview:horizontalScrollView];
    
    demoWidget = [[TodayViewController alloc]init];
    demoWidget.view.frame = CGRectMake(self.view.bounds.size.width, self.view.center.y-(354/2), self.view.bounds.size.width, 354);
    demoWidget.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    verticalScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    verticalScrollView.contentSize = self.view.bounds.size;
    verticalScrollView.bounces = NO;
    verticalScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    verticalScrollView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.01];
    [horizontalScrollView addSubview:verticalScrollView];
    
    UIImageView *TopBackgroundView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 180 /*arbitrary*/)];
    TopBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    TopBackgroundView.image = [UIImage imageNamed:@"icon1024x1024.png"];
    TopBackgroundView.contentMode = UIViewContentModeScaleAspectFill;
    TopBackgroundView.clipsToBounds = YES;
    TopBackgroundView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1];
    TopBackgroundView.autoresizingMask =  UIViewAutoresizingFlexibleWidth;
    [verticalScrollView insertSubview:TopBackgroundView atIndex:0];
    
    nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, TopBackgroundView.frame.origin.y + TopBackgroundView.bounds.size.height + 20, self.view.bounds.size.width, 20)];
    nameLabel.textColor =  [UIColor colorWithWhite:0.9 alpha:1];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.font =  [UIFont fontWithName:@"Avenir-Black" size:18];
    nameLabel.text = [NSString stringWithFormat:@"%@ %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"] ,[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    nameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [verticalScrollView addSubview:nameLabel];
    
    usernameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, nameLabel.frame.origin.y + nameLabel.bounds.size.height, self.view.bounds.size.width, 20)];
    usernameLabel.textColor =  [UIColor colorWithWhite:0.9 alpha:1];
    usernameLabel.font =  [UIFont fontWithName:@"Avenir-Oblique" size:12];
    usernameLabel.text = @"Made by Akhil Tolani";
    usernameLabel.textAlignment = NSTextAlignmentCenter;
    usernameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [verticalScrollView addSubview:usernameLabel];
    
    InformationTable = [[UITableView alloc]initWithFrame:CGRectMake(0, usernameLabel.frame.origin.y + usernameLabel.bounds.size.height + 20, self.view.bounds.size.width, 250) style:UITableViewStylePlain];
    InformationTable.dataSource = self;
    InformationTable.delegate = self;
    InformationTable.backgroundColor = self.view.backgroundColor;
    InformationTable.rowHeight = 50;
    InformationTable.scrollEnabled = NO;
    InformationTable.userInteractionEnabled = NO;
    InformationTable.sectionHeaderHeight = 0;
    InformationTable.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [InformationTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [verticalScrollView addSubview:InformationTable];
    
    SignInButton = [[BFPaperButton alloc]initWithFrame:CGRectMake(20, InformationTable.frame.origin.y + InformationTable.bounds.size.height + 20, self.view.bounds.size.width - 40, 40)];
    [SignInButton setTitle:@"Setup Facebook Account" forState:UIControlStateNormal];
    SignInButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Light" size:16];
    SignInButton.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
    SignInButton.tapCircleColor = [UIColor colorWithWhite:0.1 alpha:1];
    SignInButton.rippleFromTapLocation = YES;
    SignInButton.rippleBeyondBounds = NO;
    SignInButton.isRaised = NO;
    SignInButton.backgroundFadeColor = [UIColor clearColor];
    SignInButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    SignInButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [SignInButton setTitleColor:[UIColor colorWithWhite:1 alpha:1] forState:UIControlStateNormal];
    [SignInButton addTarget:self action:@selector(setup:) forControlEvents:UIControlEventTouchUpInside];
    [verticalScrollView addSubview:SignInButton];
    
    EmailButton = [[BFPaperButton alloc]initWithFrame:CGRectMake(20, SignInButton.frame.origin.y + SignInButton.bounds.size.height + 10, self.view.bounds.size.width - 40, 40)];
    [EmailButton setTitle:@"Contact Us" forState:UIControlStateNormal];
    EmailButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Light" size:16];
    EmailButton.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
    EmailButton.tapCircleColor = [UIColor colorWithWhite:0.1 alpha:1];
    EmailButton.rippleFromTapLocation = YES;
    EmailButton.rippleBeyondBounds = NO;
    EmailButton.isRaised = NO;
    EmailButton.backgroundFadeColor = [UIColor clearColor];
    EmailButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    EmailButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [EmailButton setTitleColor:[UIColor colorWithWhite:1 alpha:1] forState:UIControlStateNormal];
    [EmailButton addTarget:self action:@selector(mail) forControlEvents:UIControlEventTouchUpInside];
    [verticalScrollView addSubview:EmailButton];
    
    ResetCacheButton = [[BFPaperButton alloc]initWithFrame:CGRectMake(20, EmailButton.frame.origin.y + EmailButton.bounds.size.height + 10, self.view.bounds.size.width - 40, 40)];
    [ResetCacheButton setTitle:@"Reset Widget Cache" forState:UIControlStateNormal];
    ResetCacheButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Light" size:16];
    ResetCacheButton.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
    ResetCacheButton.tapCircleColor = [UIColor colorWithWhite:0.1 alpha:1];
    ResetCacheButton.rippleFromTapLocation = YES;
    ResetCacheButton.rippleBeyondBounds = NO;
    ResetCacheButton.isRaised = NO;
    ResetCacheButton.backgroundFadeColor = [UIColor clearColor];
    ResetCacheButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    ResetCacheButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [ResetCacheButton setTitleColor:[UIColor colorWithWhite:1 alpha:1] forState:UIControlStateNormal];
    [ResetCacheButton addTarget:self action:@selector(resetWidget) forControlEvents:UIControlEventTouchUpInside];
    [verticalScrollView addSubview:ResetCacheButton];
    
    if([shared boolForKey:@"FriendboxsuccessLaunch"] != YES) {
        ResetCacheButton.alpha = 0.25;
    } else {
        ResetCacheButton.alpha = 1;
    }
}
#pragma mark - Facebook -
- (void)setup:(BFPaperButton*)sender {
    ACAccountStore *account_Store = [[ACAccountStore alloc] init];
    ACAccountType *account_Type = [account_Store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    
    NSDictionary *options = @{ACFacebookAppIdKey:FACEBOOK_APPID, ACFacebookPermissionsKey:@[@"read_stream",@"email",@"basic_info",@"publish_actions"], ACFacebookAudienceKey:ACFacebookAudienceEveryone};
    
    [account_Store requestAccessToAccountsWithType:account_Type options:options completion:^(BOOL granted, NSError *error) {
        if (granted) {
            arrayOfAccounts = [[NSMutableArray alloc]initWithArray:[account_Store accountsWithAccountType:account_Type]];
            if(arrayOfAccounts.count != 0) {
                NSURL *url = [NSURL URLWithString:@"https://graph.facebook.com/me/home"];
                SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodGET URL:url parameters:@{@"limit": @"5", @"filter" : @"owner"}];
                request.account = [arrayOfAccounts objectAtIndex:0];
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    SCLAlertView *alertLoading = [[SCLAlertView alloc]init];
                    alertLoading.backgroundType = Shadow;
                    [alertLoading showInfo:self title:@"Authenticating" subTitle:@"Please wait. This should take less than a minute." closeButtonTitle:nil duration:0];
                    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error){
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            if(error == nil){
                                [alertLoading hideView];
                                
                                SCLAlertView *alert1 = [[SCLAlertView alloc]init];
                                alert1.backgroundType = Shadow;
                                [alert1 showSuccess:self title:@"Success" subTitle:@"Facebook account is now setup, please set up the Friendbox widget if you already haven't done it." closeButtonTitle:@"Okay" duration:0];
                                [shared setObject:nil forKey:@"FriendboxcacheTweetArray"];
                                [shared setObject:nil forKey:@"FriendboxcacheUsernameArray"];
                                [shared setObject:nil forKey:@"FriendboxcacheIDsArray"];
                                [shared setObject:nil forKey:@"FriendboxcacheProfileImagesArray"];
                                [shared setObject:[NSKeyedArchiver archivedDataWithRootObject:[arrayOfAccounts objectAtIndex:0]] forKey:@"FriendboxcurrentAccount"];
                                [shared synchronize];
                            } else {
                                [alertLoading hideView];
                                
                                SCLAlertView *alert1 = [[SCLAlertView alloc]init];
                                alert1.backgroundType = Shadow;
                                [alert1 showError:self title:@"Error" subTitle:[NSString stringWithFormat:@"Home > Launch Settings app > Facebook > Login again - %@",[error localizedDescription]] closeButtonTitle:@"Okay" duration:0];
                            }
                        });
                    }];
                });
            } else {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    SCLAlertView *alert1 = [[SCLAlertView alloc]init];
                    alert1.backgroundType = Shadow;
                    [alert1 showError:self title:@"Error" subTitle:@"No account found. Please go to Settings app > Facebook & login there" closeButtonTitle:@"Okay" duration:0];
                });
            }
        } else {
            dispatch_sync(dispatch_get_main_queue(), ^{
                SCLAlertView *alert1 = [[SCLAlertView alloc]init];
                alert1.backgroundType = Shadow;
                [alert1 showError:self title:@"Error" subTitle:@"Please go to Settings app > Facebook > scroll down & enable Friendbox then tap setup facebook account again in this app." closeButtonTitle:@"Okay" duration:0];
            });
        }
    }];
}

#pragma mark - table -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return 1; }
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section { return 5; }
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CYAN";
    UITableViewCell *cell = (UITableViewCell*)[InformationTable dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier]autorelease];
        cell.backgroundColor = [UIColor clearColor];
        UIView *idk = [[UIView alloc]init];
        idk.backgroundColor = [UIColor clearColor];
        cell.selectedBackgroundView = idk;
        [cell.textLabel setTextColor:[UIColor colorWithWhite:0.9 alpha:1]];
        [cell.textLabel setHighlightedTextColor:[UIColor colorWithWhite:0.9 alpha:1]];
        [cell.textLabel setFont:[UIFont fontWithName:@"Avenir" size:15]];
    }
    if(indexPath.row == 0) {
        cell.textLabel.text = @"Bring down the notification center";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"Switch to Today tab";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    } else if (indexPath.row == 2) {
        cell.textLabel.text = @"Tap 'Edit' on the bottom";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    } else if (indexPath.row == 3) {
        cell.textLabel.text = @"Select 'Friendbox' From the list";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    } else if (indexPath.row == 4) {
        cell.textLabel.text = @"All Done!";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Secondary Functions -
-(void)addDividerToView:(UIView*)view atLocation:(CGFloat)location {
    UIView* divider = [[UIView alloc] initWithFrame:CGRectMake(20, location, self.view.bounds.size.width-40, 1)];
    divider.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1];
    divider.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [view addSubview:divider];
}
int i = 1;
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if(scrollView == horizontalScrollView) {
        if(scrollView.contentOffset.x >= self.view.bounds.size.width) {
            if(i == 1) {
                [horizontalScrollView addSubview:demoWidget.view];
                i = 2;
            }
        } else {
            i = 1;
            [demoWidget.view removeFromSuperview];
        }
    }
}
- (void)resetWidget {
    [shared setObject:nil forKey:@"FriendboxcacheIDsArray"];
    [shared setObject:nil forKey:@"FriendboxcacheTweetArray"];
    [shared setObject:nil forKey:@"FriendboxcacheUsernameArray"];
    [shared setObject:nil forKey:@"FriendboxcacheProfileImagesArray"];
    [shared synchronize];
}
- (void)mail {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        [controller setToRecipients:[NSArray arrayWithObject:@"Saltb0xApps@gmail.com"]];
        [controller setSubject:[NSString stringWithFormat:@"Help - %@ %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"] ,[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]]];
        [controller setMailComposeDelegate:self];
        [controller setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
        controller.navigationBar.barStyle = UIBarStyleBlackTranslucent;
        
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        UITextField *textField = [alert addTextField:@"What would you like to tell us?"];
        textField.keyboardAppearance = UIKeyboardAppearanceAlert;
        [alert addButton:@"Okay" actionBlock:^(void) {
            [controller setMessageBody:[NSString stringWithFormat:@"%@\n\nDevice name: %@\niOS Version: %@\nDevice Model: %@\nLocale: %@\nFacebook Account Setup:%@\nWidget successfully setup:%@",
                                        textField.text,
                                        [UIDevice currentDevice].name,
                                        [UIDevice currentDevice].systemVersion,
                                        [UIDevice currentDevice].model,
                                        [[NSLocale currentLocale]objectForKey:NSLocaleCountryCode],
                                        ([shared objectForKey:@"FriendboxcurrentAccount"] != nil)?@"Yes":@"Nope",
                                        ([shared boolForKey:@"FriendboxsuccessLaunch"] == YES)?@"Yes":@"Nope"]
                                isHTML:NO];
            [self presentViewController:controller animated:YES completion:nil];
            [controller release];
        }];
        [alert showEdit:self title:@"Send us an Email" subTitle:@"Whether its a bug or a suggestion, we would love to hear from you. ^_^" closeButtonTitle:@"Cancel" duration:0.0f];
    }
}
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if([shared boolForKey:@"FriendboxsuccessLaunch"] != YES) {
        ResetCacheButton.alpha = 0.25;
    } else {
        ResetCacheButton.alpha = 1;
    }
    
    if(![shared boolForKey:@"RemovedAds"]) {
        if(admobBannerView.superview == nil) {
            if(admobBannerView == nil) {
                admobBannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait /*handles load in landscape too.*/ origin:CGPointMake(0, self.view.frame.origin.y-150 /*safety is important*/)];
                admobBannerView.adUnitID = @"ca-app-pub-9492696811948548/1580758114";
                admobBannerView.rootViewController = self;
                admobBannerView.delegate = self;
                admobBannerView.backgroundColor = self.view.backgroundColor;
                admobBannerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
                GADRequest *request = [[GADRequest alloc]init];
                request.testDevices = @[@"90f065ff5c3a5138d117122cd8b67d53"];
                [admobBannerView loadRequest:request];
            }
            [horizontalScrollView addSubview:admobBannerView];
            [UIView animateWithDuration:0.15 animations:^{
                admobBannerView.frame = CGRectMake(0, self.view.frame.origin.y, admobBannerView.bounds.size.width, admobBannerView.bounds.size.height);
                horizontalScrollView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
                verticalScrollView.frame = CGRectMake(verticalScrollView.frame.origin.x, self.view.frame.origin.y + admobBannerView.bounds.size.height, verticalScrollView.bounds.size.width, self.view.bounds.size.height - admobBannerView.bounds.size.height);
            }];
        }
    }
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [admobBannerView removeFromSuperview];
    [admobBannerView release];
    admobBannerView = nil;
    horizontalScrollView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    verticalScrollView.frame = CGRectMake(verticalScrollView.frame.origin.x, self.view.frame.origin.y, verticalScrollView.bounds.size.width, self.view.bounds.size.height);
}
- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error {
    [UIView animateWithDuration:0.15 animations:^{
        admobBannerView.frame = CGRectMake(0, self.view.frame.origin.y-150 /*safety is important*/, admobBannerView.bounds.size.width,  admobBannerView.bounds.size.height);
        horizontalScrollView.frame = CGRectMake(horizontalScrollView.frame.origin.x, 0, horizontalScrollView.bounds.size.width, self.view.bounds.size.height);
        verticalScrollView.frame = CGRectMake(verticalScrollView.frame.origin.x, self.view.frame.origin.y, verticalScrollView.bounds.size.width, self.view.bounds.size.height);
    } completion:^(BOOL finished) {
        [admobBannerView removeFromSuperview];
        [admobBannerView release];
        admobBannerView = nil;
    }];
}

#pragma mark - Unimportant Stuff -
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView { }
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if([UIScreen mainScreen].bounds.size.width < [UIScreen mainScreen].bounds.size.height){
        admobBannerView.adSize = kGADAdSizeSmartBannerPortrait;
    } else {
        admobBannerView.adSize = kGADAdSizeSmartBannerLandscape;
    }
    
    [verticalScrollView setContentSize:CGSizeMake(self.view.bounds.size.width, ResetCacheButton.bounds.size.height + ResetCacheButton.frame.origin.y + 30)];
    [horizontalScrollView setContentSize:CGSizeMake(self.view.bounds.size.width*2, self.view.bounds.size.height)];
    
    if(admobBannerView) {
        admobBannerView.frame = CGRectMake(admobBannerView.frame.origin.x, 0, admobBannerView.bounds.size.width, admobBannerView.bounds.size.height);
    }
    
    demoWidget.view.frame = CGRectMake(self.view.bounds.size.width, self.view.center.y-(354/2), self.view.bounds.size.width, 354);
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}
- (void)didReceiveMemoryWarning{[super didReceiveMemoryWarning];}
- (void)dealloc { [super dealloc]; }
- (BOOL)canBecomeFirstResponder {return YES;}
- (BOOL)prefersStatusBarHidden {return YES;}
- (BOOL)shouldAutorotate{return YES;}
- (NSUInteger)supportedInterfaceOrientations{return UIInterfaceOrientationMaskAll;}
@end
