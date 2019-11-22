//
//  MNViewController.m
//  MNetDfpHbSdk_Example
//
//  Created by nithin.g on 09/07/18.
//  Copyright © 2018 gnithin. All rights reserved.
//

#import "MNViewController.h"
#import "MNDemoConstants.h"
#import "MNShowAdViewController.h"

#import "MNURLConfigViewController.h"
#import <EventKit/EventKit.h>
#import <Photos/Photos.h>
#import <QuartzCore/QuartzCore.h>

#define ROW_CONTENTS_KEY @"rowContents"
#define SECTION_TITLE_KEY @"sectionTitle"

#define SECTION_HEADER_TEXT_COLOR [UIColor colorWithRed:146 / 255.0f green:152 / 255.0f blue:160 / 255.0f alpha:1]
#define TABLEVIEW_CELL_TEXT_COLOR [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.73]
#define TABLEVIEW_COLOR [UIColor colorWithRed:250.0 / 255 green:250.0 / 255 blue:250.0 / 255 alpha:1]
#define TABLEVIEW_CELL_SHADOW_OPACITY 0.08

static NSArray *adsListArr;
static const CGFloat tableviewCellSideMargin = 10.0f;
static const CGFloat sectionTitleHeight      = 50.0f;
static const CGFloat sectionFooterViewHeight = 30.0f;

@interface MNViewController () <UITableViewDelegate, UITableViewDataSource>
- (IBAction)configAction:(id)sender;
- (IBAction)consentAction:(id)sender;

@end

@implementation MNViewController {
    CLLocationManager *locationManager;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.configBtn.hidden = YES;

#if !defined(IS_FRAMEWORK) && defined(DEBUG)
    self.configBtn.hidden = NO;
#endif

    [self initializeAdsListArr];
    [self askAllPermissions];
    [self setupTableView];

    CGFloat blurRadius              = 4.0f;
    self.topBar.layer.shadowOpacity = 0.4f;
    self.topBar.layer.shadowOffset  = CGSizeMake(0, blurRadius);
    self.topBar.layer.shadowRadius  = blurRadius;
    self.topBar.layer.shadowColor   = [[UIColor blackColor] CGColor];
}

- (void)initializeAdsListArr {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      adsListArr = @[
          @{
              @"sectionTitle" : @"Manual HB",
              @"rowContents" : @[
                  @{@"title" : @"DFP Banner HB", @"name" : ENUM_VAL(DFP_BANNER_MANUAL_HB)},
                  @{@"title" : @"DFP Interstitial HB", @"name" : ENUM_VAL(DFP_INSTERSTITIAL_MANUAL_HB)},
                  @{@"title" : @"GAD DFP", @"name" : ENUM_VAL(GAD_DFP)},
                  @{@"title" : @"Concurrent GAD DFP", @"name" : ENUM_VAL(CONCURRENT_GAD_DFP)}
              ]
          },
          @{
              @"sectionTitle" : @"Automation Tests",
              @"rowContents" : @[ @{@"title" : @"Auto-DFP-Ad", @"name" : ENUM_VAL(MNET_AUTOMATION_DFP_ADVIEW)} ]
          },

      ];
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationPortrait]
                                forKey:@"orientation"];
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Permissions
- (void)askAllPermissions {
    [self askForLocationPermission];
    // These permissions need to be enabled for MRAID only
    //[self askForCalendarPermission];
    //[self askForPhotosPermission];
}

- (void)askForLocationPermission {
    locationManager          = [[CLLocationManager alloc] init];
    locationManager.delegate = self;

    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [locationManager requestAlwaysAuthorization];
    }
}

- (void)askForCalendarPermission {
    EKEventStore *store          = [EKEventStore new];
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    switch (status) {
    case EKAuthorizationStatusNotDetermined:
        [store requestAccessToEntityType:EKEntityTypeEvent
                              completion:^(BOOL granted, NSError *error) {
                                if (!granted) {
                                    NSLog(@"Calendar permission not granted");
                                }
                              }];
        break;

    default:
        break;
    }
}

- (void)askForPhotosPermission {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    switch (status) {
    case PHAuthorizationStatusNotDetermined:
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
        }];
        break;
    default:
        break;
    }
}

- (NSString *)getBuildVersionStr {
    NSString *version    = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *build      = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *) kCFBundleVersionKey];
    NSString *versionStr = [NSString stringWithFormat:@"Build:%@, Version:%@", build, version];
    return versionStr;
}

#pragma mark - All the click events

- (void)showAdForType:(AdType)adType {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    MNShowAdViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"showad_controller"];
    [controller setAdType:adType];

    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark - Tableview events
- (void)setupTableView {
    self.adsTableView.delegate                     = self;
    self.adsTableView.dataSource                   = self;
    UIColor *bgColor                               = TABLEVIEW_COLOR;
    self.adsTableView.backgroundColor              = bgColor;
    self.view.backgroundColor                      = bgColor;
    self.adsTableView.showsVerticalScrollIndicator = NO;
    self.adsTableView.separatorStyle               = UITableViewCellSeparatorStyleNone;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger defaultVal = 0;
    NSArray *rowContents = [self getRowContentsForSectionNumber:section];
    if (rowContents) {
        defaultVal = [rowContents count];
    }
    return defaultVal;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [adsListArr count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return sectionTitleHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle        = @"Empty";
    NSDictionary *sectionContents = [adsListArr objectAtIndex:section];
    if (sectionContents) {
        NSString *title = [sectionContents objectForKey:SECTION_TITLE_KEY];
        if (title) {
            sectionTitle = title;
        }
    }

    CGSize bounds       = UIScreen.mainScreen.bounds.size;
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bounds.width, sectionTitleHeight)];

    UILabel *titleView         = [[UILabel alloc] initWithFrame:sectionView.bounds];
    titleView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;

    [titleView setTextColor:SECTION_HEADER_TEXT_COLOR];
    [titleView setFont:[UIFont boldSystemFontOfSize:titleView.font.pointSize]];
    [titleView setText:sectionTitle];
    [titleView setTextAlignment:NSTextAlignmentCenter];
    [titleView sizeToFit];

    [titleView setCenter:sectionView.center];
    [sectionView addSubview:titleView];

    return sectionView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == ([adsListArr count] - 1)) {
        return sectionFooterViewHeight + 30;
    }
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == [adsListArr count] - 1) {
        // Make the build string here
        NSString *buildVerStr = [self getBuildVersionStr];

        // Creating the footer
        CGRect frame                    = CGRectMake(0, 0, tableView.frame.size.width, sectionFooterViewHeight);
        CGRect labelText                = frame;
        labelText.size                  = CGSizeMake(tableView.frame.size.width, sectionFooterViewHeight);
        UIView *footerView              = [[UIView alloc] initWithFrame:frame];
        UILabel *buildVersionLabel      = [[UILabel alloc] initWithFrame:frame];
        buildVersionLabel.text          = buildVerStr;
        buildVersionLabel.textAlignment = NSTextAlignmentCenter;
        buildVersionLabel.textColor     = SECTION_HEADER_TEXT_COLOR;
        [buildVersionLabel setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
        [footerView addSubview:buildVersionLabel];
        return footerView;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"adsListCell";
    MNAdViewCell *cell              = (MNAdViewCell *) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    NSString *title           = @"Empty";
    NSInteger sectionNumber   = indexPath.section;
    NSArray *rowContentsList  = [self getRowContentsForSectionNumber:sectionNumber];
    NSDictionary *rowContents = [rowContentsList objectAtIndex:indexPath.row];
    if (rowContents) {
        title = [rowContents objectForKey:@"title"];
    }

    // Create a view and add to the cell
    cell.contentLabel.text      = title;
    cell.contentLabel.textColor = TABLEVIEW_CELL_TEXT_COLOR;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber *name;
    NSArray *rowContentsList  = [self getRowContentsForSectionNumber:indexPath.section];
    NSDictionary *rowContents = [rowContentsList objectAtIndex:indexPath.row];
    if (rowContents) {
        name = [rowContents objectForKey:@"name"];
    }

    if (name) {
        AdType type = (AdType)[name intValue];
        [self showAdForType:type];
    }
    [self.adsTableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView
      willDisplayCell:(UITableViewCell *)tCell
    forRowAtIndexPath:(NSIndexPath *)indexPath {
    MNAdViewCell *cell = (MNAdViewCell *) tCell;

    CGSize shadowOffset;
    UIEdgeInsets edgeInsets;
    NSUInteger radius = 15;
    CGFloat opacity   = TABLEVIEW_CELL_SHADOW_OPACITY;

    if (indexPath.row == 0 && indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1) {
        shadowOffset = CGSizeMake(0, 0);
        edgeInsets   = UIEdgeInsetsMake(0, 0, 0, 0);

        [cell hideSeparator];
    } else if (indexPath.row == 0) {
        shadowOffset = CGSizeMake(0, 0);
        edgeInsets   = UIEdgeInsetsMake(0, 0, radius, 0);

        [cell showSeparator];
    } else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1) {
        shadowOffset = CGSizeMake(0, radius);
        edgeInsets   = UIEdgeInsetsMake(radius, 0, radius, 0);

        [cell hideSeparator];
    } else {
        shadowOffset = CGSizeMake(0, 0);
        edgeInsets   = UIEdgeInsetsMake(radius, 0, radius, 0);

        [cell showSeparator];
    }

    [self applyShadowToCell:cell
                 withRadius:radius
           withShadowOffset:shadowOffset
              withEdgeInset:edgeInsets
                 andOpacity:opacity];

    cell.layer.cornerRadius = 2;
}

#pragma mark - Tableview helpers

- (void)applyShadowToCell:(UITableViewCell *)cell
               withRadius:(NSUInteger)radius
         withShadowOffset:(CGSize)shadowOffset
            withEdgeInset:(UIEdgeInsets)edgeInsets
               andOpacity:(CGFloat)opacity {
    cell.layer.shadowOffset = shadowOffset;

    cell.layer.shadowColor   = [[UIColor blackColor] CGColor];
    cell.layer.shadowRadius  = radius;
    cell.layer.shadowOpacity = opacity;
    cell.clipsToBounds       = NO;

    CGRect shadowFrame = cell.layer.bounds;
    // Create edge insets
    UIEdgeInsets contentInsets = edgeInsets;

    // Create rect with inset and view's bounds
    CGRect shadowPathOnlyIncludingRight = UIEdgeInsetsInsetRect(shadowFrame, contentInsets);
    // Apply it on the layer's shadowPath property

    CGPathRef shadowPath  = [UIBezierPath bezierPathWithRect:shadowPathOnlyIncludingRight].CGPath;
    cell.layer.shadowPath = shadowPath;
}

- (NSArray *)getRowContentsForSectionNumber:(NSInteger)sectionNumber {
    NSDictionary *sectionContents = [adsListArr objectAtIndex:sectionNumber];
    if (sectionContents) {
        NSArray *rowContents = [sectionContents objectForKey:ROW_CONTENTS_KEY];
        if (rowContents) {
            return rowContents;
        }
    }
    return nil;
}

- (IBAction)configAction:(id)sender {
    UIStoryboard *storyboard            = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MNURLConfigViewController *configVC = [storyboard instantiateViewControllerWithIdentifier:@"urlConfigVC"];
    [self presentViewController:configVC animated:YES completion:nil];
}

- (IBAction)consentAction:(id)sender {
    // Pass
}

@end

@implementation MNAdViewCell

- (void)setFrame:(CGRect)frame {
    CGFloat inset = tableviewCellSideMargin;
    frame.origin.x += inset;
    frame.size.width -= 2 * inset;
    [super setFrame:frame];
}

- (void)hideSeparator {
    [self.separator setHidden:YES];
}

- (void)showSeparator {
    [self.separator setHidden:NO];
}

@end
