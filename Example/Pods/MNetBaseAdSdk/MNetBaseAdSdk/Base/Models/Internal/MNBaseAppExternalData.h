//
//  MNBaseAppExternalData.h
//  MNBaseAdSdk
//
//  Created by nithin.g on 31/10/17.
//

#import <Foundation/Foundation.h>
#import <MNetJSONModeller/MNJMManager.h>

@interface MNBaseAppExternalData : NSObject <MNJMMapperProtocol>
@property (atomic) NSString *hostAppVersionId;
@end
