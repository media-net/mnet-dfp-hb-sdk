//
//  MNBaseBidderInfoDetails.h
//  MNBaseAdSdk
//
//  Created by nithin.g on 23/10/17.
//

#import <Foundation/Foundation.h>
#import <MNetJSONModeller/MNJMBoolean.h>
#import <MNetJSONModeller/MNJMManager.h>

NS_ASSUME_NONNULL_BEGIN
@interface MNBaseBidderInfoDetails : NSObject <MNJMMapperProtocol>

@property (atomic) NSString *size;
@property (atomic) NSString *adurl;
@property (atomic) NSString *adcode;
@property (atomic) MNJMBoolean *winner;
@property (atomic) NSString *creativeType;
@property (atomic) NSArray<NSString *> *loggingPixels;

- (void)setWinnerStatus:(BOOL)winnerStatus;

@end
NS_ASSUME_NONNULL_END
