//
//  MNBaseFingerprintData.h
//  Pods
//
//  Created by nithin.g on 22/05/17.
//
//

#import <Foundation/Foundation.h>
#import <MNetJSONModeller/MNJMManager.h>

@interface MNBaseFingerprintData : NSObject <MNJMMapperProtocol>

@property (atomic) NSString *ifa;
@property (atomic) int dpi;
@property (atomic) NSString *deviceType;
@property (atomic) NSString *hardwareVersion;
@property (atomic) NSString *imei;
@property (atomic) NSString *macId;

@end
