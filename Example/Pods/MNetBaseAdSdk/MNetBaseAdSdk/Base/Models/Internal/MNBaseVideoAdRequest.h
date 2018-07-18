//
//  MNBaseVideoAdRequest.h
//  Pods
//
//  Created by akshay.d on 25/05/17.
//
//

#import "MNBaseImpFormat.h"
#import <Foundation/Foundation.h>
#import <MNetJSONModeller/MNJMManager.h>

@interface MNBaseVideoAdRequest : NSObject <MNJMMapperProtocol>

@property (nonatomic) NSArray<MNBaseImpFormat *> *format;
+ (MNBaseVideoAdRequest *)newInstance;

@end
