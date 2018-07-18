//
//  MNBaseRegulation.h
//  MNBaseAdSdk
//
//  Created by nithin.g on 19/12/17.
//

#import <Foundation/Foundation.h>
#import <MNetJSONModeller/MNJMBoolean.h>
#import <MNetJSONModeller/MNJMManager.h>

@interface MNBaseRequestRegulation : NSObject <MNJMMapperProtocol>
@property (atomic) NSNumber *isChildDirected;
@end
