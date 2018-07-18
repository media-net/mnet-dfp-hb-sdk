//
//  MNBaseBannerAdRequest.h
//  Pods
//
//  Created by akshay.d on 25/05/17.
//
//

#import "MNBaseImpFormat.h"
#import <Foundation/Foundation.h>

#import <MNetJSONModeller/MNJMManager.h>

@interface MNBaseBannerAdRequest : NSObject <MNJMMapperProtocol>
@property (nonatomic) NSArray<MNBaseImpFormat *> *format;
+ (MNBaseBannerAdRequest *)newInstance;

@end
