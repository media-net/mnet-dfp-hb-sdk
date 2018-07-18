//
//  MNBaseSdkConfigVCLinks.h
//  Pods
//
//  Created by nithin.g on 07/08/17.
//
//

#import <Foundation/Foundation.h>
#import <MNetJSONModeller/MNJMBoolean.h>
#import <MNetJSONModeller/MNJMManager.h>

@interface MNBaseSdkConfigVCLinks : NSObject <MNJMMapperProtocol>
@property (atomic) MNJMBoolean *isEnabled;
@property (atomic) NSDictionary<NSString *, NSString *> *linkMap;
@end
