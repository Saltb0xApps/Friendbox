#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>
#import <Accounts/Accounts.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMotion/CoreMotion.h>
#import <Social/Social.h>
#import <MessageUI/MessageUI.h>

#import "BFPaperButton.h"
#import "UIColor+BFPaperColors.h"
#import "SCLAlertView.h"
#import "GADBannerView.h"

#import "TodayViewController.h"

@interface ATMainViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate>
{
    UILabel *nameLabel;
    UILabel *usernameLabel;
    UITableView *InformationTable;
    UIScrollView *verticalScrollView;
    UIScrollView *horizontalScrollView;
    UISegmentedControl *browsingStyleSegment;

    NSUserDefaults *shared;
    NSMutableArray *arrayOfAccounts;
    
    BFPaperButton *SignInButton;
    BFPaperButton *ResetCacheButton;
    BFPaperButton *EmailButton;
    GADBannerView *admobBannerView;;
    
    TodayViewController *demoWidget;
}
@end

