//
//  MNBaseExternalData.h
//  Pods
//
//  Created by nithin.g on 19/04/17.
//
//

#import <Foundation/Foundation.h>
#import <MNetJSONModeller/MNJMManager.h>

@interface MNBaseExternalData : NSObject <MNJMMapperProtocol>
@property (atomic) NSString *url;

- (id)initWithUrl:(NSString *)url;
- (id)init;

@end
