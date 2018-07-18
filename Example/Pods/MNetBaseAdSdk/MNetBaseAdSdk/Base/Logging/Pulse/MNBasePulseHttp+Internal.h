//
//  MNBasePulseHttp+Internal.h
//  MNBaseAdSdk
//
//  Created by nithin.g on 20/12/17.
//

#ifndef MNBasePulseHttp_Internal_h
#define MNBasePulseHttp_Internal_h

#import "MNBasePulseHttp.h"
#import "MNBasePulseStore.h"

@interface MNBasePulseHttp () <MNBasePulseStoreDelegate>
@property (atomic) MNBasePulseStore *pulseStore;

+ (BOOL)isRegulatedForPulseEvent:(MNBasePulseEvent *)pulseEvent;
+ (NSArray<NSString *> *)getRegulatedPulseEvents;

/// This method will be called whenever pulse http requests need to be prevented
/// like in the case of testing.
- (void)__stopFromMakingRequestsForTests;

- (MNBasePulseStoreLimitType)comparatorWithFileSize:(NSUInteger)fileSize
                                         numEntries:(NSUInteger)numEntries
                             andTimeSinceFirstEntry:(NSTimeInterval)timestamp;

- (void)limitExceeded:(MNBasePulseStoreLimitType)limitExceededType withEntries:(NSArray<NSData *> *)entries;

@end

#endif /* MNBasePulseHttp_Internal_h */
