#import <UIKit/UIKit.h>
#import <NotificationCenter/NotificationCenter.h>
#import <Social/Social.h>

#import "NSDate+TimeAgo.h"
#import "UIImage+FX.h"
#import "SCLAlertView.h"

@interface TodayViewController : UIViewController <NCWidgetProviding, UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *statusText;
    NSMutableArray *profileImages;
    NSMutableArray *statusImages;
    NSMutableArray *usernames;
    NSMutableArray *statusIDs;
    
    NSMutableArray *statuses;
    
    NSUserDefaults *shared;

    UITableView *facebookTable;
    UIActivityIndicatorView *indicator;
}
@end
