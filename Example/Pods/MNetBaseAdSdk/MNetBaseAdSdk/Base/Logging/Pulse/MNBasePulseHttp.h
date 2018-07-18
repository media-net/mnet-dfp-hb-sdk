//
//  MNBasePulseHttp.h
//  Pods
//
//  Created by nithin.g on 27/02/17.
//
//

#import "MNBasePulseEvent.h"
#import <Foundation/Foundation.h>

@interface MNBasePulseHttp : NSObject
+ (instancetype)getSharedInstance;
- (void)logEvent:(MNBasePulseEvent *)event;
- (void)logEventsWithArray:(NSArray<MNBasePulseEvent *> *)eventsList;
- (void)checkForBatchHttp;
@end
