//
//  MNBaseImpFormat.h
//  MNBaseAdSdk
//
//  Created by kunal.ch on 04/04/18.
//

#import <Foundation/Foundation.h>
#import <MNetJSONModeller/MNJMManager.h>

@interface MNBaseImpFormat : NSObject <MNJMMapperProtocol>

@property (nonatomic) NSNumber *width;
@property (nonatomic) NSNumber *height;

+ (MNBaseImpFormat *)newInstance;
@end
