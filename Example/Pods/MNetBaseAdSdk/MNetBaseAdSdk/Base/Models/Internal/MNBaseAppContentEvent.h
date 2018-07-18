//
//  MNBaseAppContentEvent.h
//  Pods
//
//  Created by nithin.g on 07/07/17.
//
//

#import <Foundation/Foundation.h>
#import <MNetJSONModeller/MNJMManager.h>

@interface MNBaseAppContentEvent : NSObject <MNJMMapperProtocol>
@property (atomic) NSString *content;
@property (atomic) NSString *adUnitId;
@property (atomic) NSString *adCycleId;
@property (atomic) NSString *appLink;
@property (atomic) NSString *crawlerLink;
@property (atomic) NSNumber *contentFetchDuration;
@end
