//
//  MNViewController.h
//  MNetDfpHbSdk_Example
//
//  Created by nithin.g on 09/07/18.
//  Copyright © 2018 gnithin. All rights reserved.
//

@import UIKit;
#import <CoreLocation/CoreLocation.h>
#define ENUM_VAL(enum) [NSNumber numberWithInt:enum]

@interface MNViewController : UIViewController <CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *adsTableView;
@property (weak, nonatomic) IBOutlet UIView *topBar;
@property (weak, nonatomic) IBOutlet UIButton *configBtn;

@end

@interface MNAdViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIView *separator;

- (void)hideSeparator;
- (void)showSeparator;
@end
