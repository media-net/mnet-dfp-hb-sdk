//
//  MNBasePulseEvent.h
//  Pods
//
//  Created by nithin.g on 27/02/17.
//
//

#import "MNBaseConstants.h"
#import <Foundation/Foundation.h>
#import <MNetJSONModeller/MNJMManager.h>

@interface MNBasePulseEvent : NSObject <NSCoding, MNJMMapperProtocol>

@property (atomic) NSNumber *timestamp;
@property (atomic) NSDictionary *eventObj;
@property (atomic) NSString *loggingLevel;
@property (atomic) NSString *loggingService;
@property (atomic) NSString *tag;
@property (atomic) NSString *platform;

- (MNBasePulseEvent *)initWithType:(NSString *)tag
                       withSubType:(NSString *)subType
                       withMessage:(NSString *)message
                     andCustomData:(id)customData;

@end
