#import "TodayViewController.h"
@interface UIImage (WithColor)
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;
@end
@implementation UIImage (WithColor)
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}
@end

@implementation TodayViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, 354); /*max height*/
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.FriendboxSharingDefaults"];
    
    statusText = [[NSMutableArray alloc] init];
    statusIDs = [[NSMutableArray alloc] init];
    profileImages = [[NSMutableArray alloc] init];
    statusImages = [[NSMutableArray alloc] init];
    usernames = [[NSMutableArray alloc] init];
    
    indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    indicator.alpha = 1;
    [indicator startAnimating];
    [self.view addSubview:indicator];
    
    if(((NSMutableArray*)[shared objectForKey:@"FriendboxcacheTweetArray"]).count == 0) /*no cache*/ {
        indicator.frame = CGRectMake(0, 0, self.view.bounds.size.width, 354); /*fullscreen*/
        indicator.transform = CGAffineTransformMakeScale(1, 1);
        
        [shared setObject:nil forKey:@"FriendboxcacheIDsArray"];
        [shared setObject:nil forKey:@"FriendboxcacheTweetArray"];
        [shared setObject:nil forKey:@"FriendboxcacheUsernameArray"];
        [shared setObject:nil forKey:@"FriendboxcacheProfileImagesArray"];
        [shared setFloat:0 forKey:@"FriendboxcacheHeight"];
        [shared synchronize];
        
        self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, 354); /*max height*/
    } else {
        indicator.frame = CGRectMake(self.view.bounds.size.width-25, 0, 25, 25); /*top right corner*/
        indicator.transform = CGAffineTransformMakeScale(0.75, 0.75);
        
        statusText = [NSMutableArray arrayWithArray:[shared objectForKey:@"FriendboxcacheTweetArray"]];
        statusIDs = [NSMutableArray arrayWithArray:[shared objectForKey:@"FriendboxcacheIDsArray"]];
        usernames = [NSMutableArray arrayWithArray:[shared objectForKey:@"FriendboxcacheUsernameArray"]];
        profileImages = [NSMutableArray arrayWithArray:[shared objectForKey:@"FriendboxcacheProfileImagesArray"]];
    }
    
    if([shared floatForKey:@"FriendboxcacheHeight"] && [shared floatForKey:@"FriendboxcacheHeight"] > 30 /*arbitrary*/) {
        self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, [shared floatForKey:@"FriendboxcacheHeight"]);
    } else {
        self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, 354); /*max height*/
    }

    
    facebookTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 354) style:UITableViewStylePlain];
    facebookTable.dataSource = self;
    facebookTable.delegate = self;
    facebookTable.rowHeight = 354/5;
    facebookTable.scrollEnabled = NO;
    facebookTable.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];
    [facebookTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [facebookTable setSeparatorColor:[UIColor colorWithWhite:1 alpha:0]];
    [facebookTable setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self.view insertSubview:facebookTable atIndex:0];
    
    [self load];
}
- (void)load {
    if([shared objectForKey:@"FriendboxcurrentAccount"] != nil) {
        NSURL *url = [NSURL URLWithString:@"https://graph.facebook.com/me/home"];
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodGET URL:url parameters:@{@"limit": @"5", @"filter" : @"owner"}];
        request.account = [NSKeyedUnarchiver unarchiveObjectWithData:[shared objectForKey:@"FriendboxcurrentAccount"]];
        
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error){
            dispatch_async(dispatch_get_main_queue(), ^{
                if(error != nil){
                    [UIView animateWithDuration:0.15 animations:^{
                        indicator.alpha = 0;
                        facebookTable.alpha = 0;
                    } completion:^(BOOL finished) {
                        [indicator stopAnimating];
                        [indicator removeFromSuperview];
                        self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, 100);
                        
                        [facebookTable removeFromSuperview];
                        [[self.view viewWithTag:0246123] removeFromSuperview];
                        
                        UILabel *errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 100)];
                        errorLabel.text = [NSString stringWithFormat:@"Error connecting to Facebook - %@", [error localizedDescription]];
                        errorLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
                        errorLabel.textAlignment = NSTextAlignmentCenter;
                        errorLabel.textColor = [UIColor whiteColor];
                        errorLabel.numberOfLines = 2;
                        errorLabel.tag = 0246123;
                        errorLabel.font = [UIFont fontWithName:@"Avenir" size:12];
                        errorLabel.userInteractionEnabled = YES;
                        [self.view addSubview:errorLabel];
                    }];
                    return;
                }
                NSError *errorn;
                NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&errorn];
                if(errorn != nil) {
                    [UIView animateWithDuration:0.15 animations:^{
                        indicator.alpha = 0;
                    } completion:^(BOOL finished) {
                        [indicator stopAnimating];
                        [indicator removeFromSuperview];
                        self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, 100);
                        
                        [facebookTable removeFromSuperview];
                        [[self.view viewWithTag:0246123] removeFromSuperview];
                        
                        UILabel *errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 100)];
                        errorLabel.text = [NSString stringWithFormat:@"Error connecting to Facebook. - %@", [errorn localizedDescription]];
                        errorLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
                        errorLabel.textAlignment = NSTextAlignmentCenter;
                        errorLabel.textColor = [UIColor whiteColor];
                        errorLabel.numberOfLines = 2;
                        errorLabel.tag = 0246123;
                        errorLabel.font = [UIFont fontWithName:@"Avenir" size:12];
                        errorLabel.userInteractionEnabled = YES;
                        [self.view addSubview:errorLabel];
                    }];
                    return;
                }
                if(statuses.count != 0) {
                    [statuses removeAllObjects];
                }
                statuses = [[NSMutableArray alloc] initWithArray:[result objectForKey:@"data"]];
                if(statuses.count == 0) /*fucking try again & keep trying, no need to show error since cache shows old stuff*/ {
                    [self performSelector:@selector(load) withObject:nil afterDelay:0.25];
                    return;
                }
                /*remove previous data*/
                if(statusText.count != 0) {
                    [statusText removeAllObjects];
                }
                if(statusIDs.count != 0) {
                    [statusIDs removeAllObjects];
                }
                if(profileImages.count != 0) {
                    [profileImages removeAllObjects];
                }
                if(statusImages.count != 0) {
                    [statusImages removeAllObjects];
                }
                if(usernames.count != 0) {
                    [usernames removeAllObjects];
                }
                
                /*got the stuff*/
                for(int i = 0; i < statuses.count; i++) {
                    NSString *content = nil;
                    if (statuses[i][@"story"])
                        content = statuses[i][@"story"];
                    else if (statuses[i][@"message"])
                        content = statuses[i][@"message"];
                    
                    if(!content) {
                        content = @" ";
                    }
                    
                    NSString *text = [[statuses objectAtIndex:i] valueForKey:@"description"];
                    if(!text) {
                        text = @" ";
                    }
                    [statusText addObject:[NSString stringWithFormat:@"%@",text]];
                    
                    [statusIDs addObject:[NSString stringWithFormat:@"%@",[statuses objectAtIndex:i][@"id"]]];

                    [statusImages addObject:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture", [statuses objectAtIndex:i][@"object_id"]]];
                    
                    [profileImages addObject:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=normal&width=60&height=60", [statuses objectAtIndex:i][@"from"][@"id"]]];

                    NSArray *to = [[[[statuses objectAtIndex:i] objectForKey:@"to"] objectForKey:@"data"] valueForKey:@"name"];
                    if(to.count == 0) {
                        [usernames addObject:[NSString stringWithFormat:@"%@ - %@", [[[statuses objectAtIndex:i] objectForKey:@"from"] valueForKey:@"name"], content]];
                    } else {
                        [usernames addObject:[NSString stringWithFormat:@"%@ ▸ %@ - %@", [[[statuses objectAtIndex:i] objectForKey:@"from"] valueForKey:@"name"], [to firstObject], content]];
                    }
                    if(statusIDs.count == 5) {
                        break;
                    }
                }
                [facebookTable reloadData];
                
                
                [shared setBool:YES forKey:@"FriendboxsuccessLaunch"];
                [shared synchronize];
                
                [UIView animateWithDuration:0.15 animations:^{
                    indicator.alpha = 0;
                    self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, statusIDs.count*(354/5)); /*adjust height*/
                    [[self.view viewWithTag:0246123] setAlpha:0];
                } completion:^(BOOL finished) {
                    [indicator stopAnimating];
                    [indicator removeFromSuperview];
                    [[self.view viewWithTag:0246123] removeFromSuperview];
                }];
            });
        }];
    } else {
        self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, 100);
        
        indicator.alpha = 0;
        [indicator stopAnimating];
        [indicator removeFromSuperview];
        
        [facebookTable removeFromSuperview];
        
        [[self.view viewWithTag:0246123] removeFromSuperview];
        
        UILabel *error = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 100)];
        error.text = @"Please Setup a Facebook account\nfrom the Friendbox app before you can use the widget.";
        error.numberOfLines = 3;
        error.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        error.textAlignment = NSTextAlignmentCenter;
        error.textColor = [UIColor whiteColor];
        error.tag = 0246123;
        error.font = [UIFont fontWithName:@"Avenir" size:13];
        error.userInteractionEnabled = YES;
        [self.view addSubview:error];
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return 1; }
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [facebookTable dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
        [cell.textLabel setTextColor:[UIColor whiteColor]];
        [cell.textLabel setFont:[UIFont fontWithName:@"Avenir-Medium" size:10]];
        [cell.textLabel setHighlightedTextColor:[UIColor whiteColor]];
        [cell.textLabel setNumberOfLines:2];
        [cell.detailTextLabel setTextColor:[UIColor whiteColor]];
        [cell.detailTextLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [cell.detailTextLabel setFont:[UIFont fontWithName:@"Avenir-Light" size:10]];
        [cell.detailTextLabel setHighlightedTextColor:[UIColor whiteColor]];
        [cell.detailTextLabel setNumberOfLines:3];
        cell.imageView.frame = CGRectMake(cell.imageView.frame.origin.x, 0, 40, 40);
        cell.imageView.center = CGPointMake(cell.imageView.center.x, cell.imageView.center.y);
        cell.imageView.layer.cornerRadius = 5;
        cell.imageView.layer.masksToBounds = YES;
        cell.imageView.clipsToBounds = YES;
        cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [cell setClipsToBounds:YES];
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.25];
        [cell setSelectedBackgroundView:bgColorView];
        [cell setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.1]];
    }
    if(indexPath.row < statusText.count) {
        cell.detailTextLabel.text = [statusText objectAtIndex:indexPath.row];
    } else {
        cell.detailTextLabel.text = @"";
    }
    
    if(indexPath.row < usernames.count) {
        cell.textLabel.text = [usernames objectAtIndex:indexPath.row];
    } else {
        cell.textLabel.text = @"";
    }
    
    if(CGSizeEqualToSize(cell.imageView.image.size, CGSizeZero)) {
        cell.imageView.image = [UIImage imageWithColor:[UIColor colorWithWhite:0 alpha:0.01] size:CGSizeMake(40, 40)];
    }
    if(indexPath.row < profileImages.count) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[profileImages objectAtIndex:indexPath.row]]]];
            dispatch_async(dispatch_get_main_queue(), ^{
                UITableViewCell * cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                if (CGSizeEqualToSize(img.size, CGSizeZero)) {
                    [UIView transitionWithView:cell.imageView duration:0.25 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                        cell.imageView.image = [UIImage imageNamed:@""];
                    } completion:nil];
                } else {
                    [UIView transitionWithView:cell.imageView duration:0.25 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                        cell.imageView.image = [img imageScaledToSize:CGSizeMake(40, 40)];
                    } completion:nil];
                }
            });
        });
    } else {
        UITableViewCell * cell12 = (UITableViewCell *)[facebookTable cellForRowAtIndexPath:indexPath];
        cell12.imageView.image = [UIImage imageNamed:@""];
        cell12.imageView.frame = CGRectZero;
    }
    
    if(indexPath.row < statusImages.count) {
        if([statusImages objectAtIndex:indexPath.row]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                UIImage *img = [[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[statusImages objectAtIndex:indexPath.row]]]] imageScaledToSize:CGSizeMake(40, 40)];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(!CGSizeEqualToSize(CGSizeZero, img.size)) {
                        UIImageView *img2 = [[UIImageView alloc] initWithImage:[UIImage imageWithColor:[UIColor colorWithWhite:1 alpha:0.1] size:CGSizeMake(40, 40)]];
                        img2.layer.cornerRadius = 5;
                        img2.layer.masksToBounds = YES;
                        img2.clipsToBounds = YES;
                        img2.contentMode = UIViewContentModeScaleAspectFit;
                        cell.accessoryView = img2;
                        [cell.accessoryView setFrame:CGRectMake(cell.accessoryView.frame.origin.x, 0, 40, 40)];
                        [cell.accessoryView setCenter:CGPointMake(cell.accessoryView.center.x, cell.center.y)];
                        UITableViewCell *cell3 = (UITableViewCell *)[facebookTable cellForRowAtIndexPath:indexPath];
                        [UIView transitionWithView:((UIImageView*)cell3.accessoryView) duration:0.25 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                            ((UIImageView*)cell3.accessoryView).image = img;
                        } completion:nil];
                    }
                });
            });
        } else {
            UITableViewCell *cell2 = (UITableViewCell *)[facebookTable cellForRowAtIndexPath:indexPath];
            [cell2.accessoryView setFrame:CGRectZero];
            cell2.accessoryView = nil;
            [cell2 setNeedsLayout];
        }
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell * cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if(cell.detailTextLabel.text != nil) {
        [UIView animateWithDuration:0.15 delay:0.15 options:UIViewAnimationOptionCurveLinear animations:^{
            cell.imageView.alpha = 0.25;
            cell.textLabel.alpha = 0.25;
            cell.detailTextLabel.alpha = 0.25;
        } completion:^(BOOL finished) {
            [[cell viewWithTag:0704] removeFromSuperview]; /*just in case*/
            
            UIView *tabContainer = [[UIView alloc] initWithFrame:CGRectMake(cell.frame.origin.x, 0, cell.bounds.size.width, cell.bounds.size.height)];
            tabContainer.userInteractionEnabled = YES;
            tabContainer.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
            tabContainer.tag = 0704;
            tabContainer.alpha = 0;
            tabContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [cell addSubview:tabContainer];
            [UIView animateWithDuration:0.15 delay:0.15 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                tabContainer.alpha = 1;
            } completion:^(BOOL finished) {
                [self createButtonWithTitle:@"" /*Like*/ andAction:@"likePost:" withCellIndex:(int)indexPath.row andFrame:CGRectMake(0, 0, tabContainer.bounds.size.width/3, tabContainer.bounds.size.height)];
                [self createButtonWithTitle:@"" /*Launch*/ andAction:@"launchfbApp:" withCellIndex:(int)indexPath.row andFrame:CGRectMake(1*(tabContainer.bounds.size.width/3), 0, tabContainer.bounds.size.width/3, tabContainer.bounds.size.height)];
                [self createButtonWithTitle:@"" /*Done*/ andAction:@"cancel:" withCellIndex:(int)indexPath.row andFrame:CGRectMake(2*(tabContainer.bounds.size.width/3), 0, tabContainer.bounds.size.width/3, tabContainer.bounds.size.height)];
            }];
        }];
    }
}
- (void)cancel:(UIButton*)sender {
    UITableViewCell *cell = (UITableViewCell *)[facebookTable cellForRowAtIndexPath:[NSIndexPath indexPathForItem:sender.tag inSection:0]];
    [UIView animateWithDuration:0.15 animations:^{
        [cell viewWithTag:0704].alpha = 0;
    } completion:^(BOOL finished) {
        [[cell viewWithTag:0704] removeFromSuperview];
        [UIView animateWithDuration:0.15 animations:^{
            cell.imageView.alpha = 1;
            cell.textLabel.alpha = 1;
            cell.detailTextLabel.alpha = 1;
        }];
    }];
}
- (void)likePost:(UIButton*)sender {
    sender.alpha = 0.15;
    
    NSString *object_id = [[[statusImages objectAtIndex:sender.tag] stringByReplacingOccurrencesOfString:@"http://graph.facebook.com/" withString:@""] stringByReplacingOccurrencesOfString:@"/picture" withString:@""];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/likes",object_id]];
    
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodPOST URL:url parameters:nil];
    request.account = [NSKeyedUnarchiver unarchiveObjectWithData:[shared objectForKey:@"FriendboxcurrentAccount"]];
    
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error){
        dispatch_async(dispatch_get_main_queue(), ^{
            if(!error) {
                sender.alpha = 1;
                [sender setTitleColor:[UIColor colorWithRed:52.0/255.0 green:152.0/255.0 blue:219.0/255.0 alpha:1.0] forState:UIControlStateNormal];
            } else {
                sender.alpha = 1;
                [sender setTitleColor:[UIColor colorWithRed:231.0/255.0 green:76.0/255.0 blue:60.0/255.0 alpha:1.0] forState:UIControlStateNormal];
            }
        });
    }];
}
- (void)launchfbApp:(UIButton*)sender {
    NSURL *test = [NSURL URLWithString:[NSString stringWithFormat:@"fb://story?id=%@",[statusIDs objectAtIndex:sender.tag]]];
    [self.extensionContext openURL:test completionHandler:nil];
}
- (void)createButtonWithTitle:(NSString*)title andAction:(NSString*)action withCellIndex:(int)row andFrame:(CGRect)frame {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button addTarget:self action:NSSelectorFromString(action) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTintColor:[UIColor whiteColor]];
    [button setTag:row];
    [button setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.01]];
    [button setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [button.titleLabel setNumberOfLines:0];
    [button.titleLabel setFont:[UIFont fontWithName:@"googleicon" size:24]];
    [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [button.titleLabel setNumberOfLines:0];
    button.frame = frame;
    button.alpha = 0;
    
    UITableViewCell * cell = (UITableViewCell *)[facebookTable cellForRowAtIndexPath:[NSIndexPath indexPathForItem:row inSection:0]];
    [[cell viewWithTag:0704] addSubview:button];
    
    [UIView animateWithDuration:0.25 delay:0.15 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        button.alpha = 1;
    } completion:nil];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if(facebookTable) {
        [UIView animateWithDuration:0.15 animations:^{
            facebookTable.alpha = 0;
        } completion:^(BOOL finished) {
            facebookTable = nil;
        }];
    }
    if(statusText.count != 0) {
        [shared setObject:statusText forKey:@"FriendboxcacheTweetArray"];
        [statusText removeAllObjects];
        statusText = nil;
    }
    if(statusIDs.count != 0) {
        [shared setObject:statusIDs forKey:@"FriendboxcacheIDsArray"];
        [statusIDs removeAllObjects];
        statusIDs = nil;
    }
    if(profileImages.count != 0) {
        [shared setObject:profileImages forKey:@"FriendboxcacheProfileImagesArray"];
        [profileImages removeAllObjects];
        profileImages = nil;
    }
    if(statusImages.count != 0) {
        [statusImages removeAllObjects];
        statusImages = nil;
    }
    if(usernames.count != 0) {
        [shared setObject:usernames forKey:@"FriendboxcacheUsernameArray"];
        [usernames removeAllObjects];
        usernames = nil;
    }
    [shared setFloat:self.preferredContentSize.height forKey:@"FriendboxcacheHeight"];
    
    [shared synchronize];
    if(shared) {
        shared = nil;
    }
}


#pragma mark - useless stuff
- (void)didReceiveMemoryWarning { [super didReceiveMemoryWarning]; }
- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets { return UIEdgeInsetsMake(0, 0, 0, 0); }
- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler { completionHandler(NCUpdateResultNoData); }
@end