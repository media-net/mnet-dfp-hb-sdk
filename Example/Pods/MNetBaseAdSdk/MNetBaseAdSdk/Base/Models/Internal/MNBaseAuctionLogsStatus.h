//
//  MNBaseAuctionLogsStatus.h
//  MNBaseAdSdk
//
//  Created by nithin.g on 24/10/17.
//

#import <Foundation/Foundation.h>
#import <MNetJSONModeller/MNJMBoolean.h>
#import <MNetJSONModeller/MNJMManager.h>

NS_ASSUME_NONNULL_BEGIN
@interface MNBaseAuctionLogsStatus : NSObject <MNJMMapperProtocol>

@property (atomic) MNJMBoolean *prflog;
@property (atomic) MNJMBoolean *prlog;
@property (atomic) MNJMBoolean *awlog;
@property (atomic) MNJMBoolean *aplog;

@end
NS_ASSUME_NONNULL_END
