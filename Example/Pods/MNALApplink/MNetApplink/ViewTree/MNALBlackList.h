//
//  MNALBlackList.h
//  Pods
//
//  Created by nithin.g on 12/06/17.
//
//

#import <Foundation/Foundation.h>

@interface MNALBlackList : NSObject

+ (instancetype)getInstance;
- (NSDictionary *)getBlackListForCurrentApp;
- (NSArray *)getIntentsBlackListForCurrentApp;
@end
