//
//  MNBaseBidResponseTypeInfo.h
//  Pods
//
//  Created by nithin.g on 29/06/17.
//
//

#import <Foundation/Foundation.h>

@interface MNBaseBidResponseTypeInfo : NSObject
+ (id)getSharedInstance;
- (BOOL)isResponseType:(NSString *)responseType;
- (NSString *)getAdControllerClassStrForResponseType:(NSString *)responseType;
- (NSString *)getAdControllerSelStrForResponseType:(NSString *)responseType;
@end
