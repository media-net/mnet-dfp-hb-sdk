//
//  MNBasePublisher.h
//  Pods
//
//  Created by nithin.g on 15/02/17.
//
//

#import <Foundation/Foundation.h>
#import <MNetJSONModeller/MNJMManager.h>

@interface MNBasePublisher : NSObject <MNJMMapperProtocol>

@property (atomic) NSString *id;

- (id)initWithId:(NSString *)publisherId;

@end
