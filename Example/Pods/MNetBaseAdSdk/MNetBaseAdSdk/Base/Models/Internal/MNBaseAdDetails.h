//
//  MNBaseAdDetails.h
//  Pods
//
//  Created by nithin.g on 29/06/17.
//
//

#import <Foundation/Foundation.h>
#import <MNetJSONModeller/MNJMManager.h>

@interface MNBaseAdDetails : NSObject <MNJMMapperProtocol>

@property (atomic) double fpBid;
@property (atomic) double lastAdxBid;
@property (atomic) double lastAdxWinBid;
@property (atomic) NSString *lastAdxWinStatus;

- (NSDictionary *)propertyKeyMap;

@end
