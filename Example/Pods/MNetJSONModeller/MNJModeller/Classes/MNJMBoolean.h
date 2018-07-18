//
//  MNJMBoolean.h
//  Pods
//
//  Created by nithin.g on 23/05/17.
//
//

#import <Foundation/Foundation.h>

@interface MNJMBoolean : NSObject
+ (instancetype)createWithBool:(BOOL)boolVal;
- (id)init;
- (void)setBool:(BOOL)boolVal;
- (BOOL)isYes;
@end
