//
//  MNBaseKeychainWrapper.h
//  Pods
//
//  Created by nithin.g on 22/05/17.
//

#import <Foundation/Foundation.h>

@interface MNBaseKeychainWrapper : NSObject {
    NSString *service;
    NSString *group;
}
- (id)initWithService:(NSString *)service_ withGroup:(NSString *)group_;

- (BOOL)insert:(NSString *)key withData:(NSData *)data;
- (BOOL)update:(NSString *)key withData:(NSData *)data;
- (BOOL)upsert:(NSString *)key withData:(NSData *)data;
- (BOOL)remove:(NSString *)key;
- (NSData *)find:(NSString *)key;

+ (MNBaseKeychainWrapper *)getInstance;

@end
