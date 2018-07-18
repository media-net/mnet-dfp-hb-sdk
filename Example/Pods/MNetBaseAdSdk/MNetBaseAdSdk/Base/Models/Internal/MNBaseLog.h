//
//  MNBaseLog.h
//  Pods
//
//  Created by nithin.g on 15/02/17.
//
//

#import <Foundation/Foundation.h>
#import <MNetJSONModeller/MNJMManager.h>

@interface MNBaseLog : NSObject <MNJMMapperProtocol>

@property (atomic) NSString *tag;

@property (atomic) NSString *message;

@property (atomic) NSString *error;

- (id)initWith:(NSString *)tag message:(NSString *)message;

- (id)initWith:(NSString *)tag message:(NSString *)message error:(NSString *)error;

@end
