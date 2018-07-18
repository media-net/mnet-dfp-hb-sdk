//
//  MNJMClassPropertyManager.h
//  MNetJSONModeller
//
//  Created by nithin.g on 27/10/17.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

@class MNJMClassPropertyDetail;

@interface MNJMClassPropertyManager : NSObject
+ (instancetype)getSharedInstance;
- (NSArray<MNJMClassPropertyDetail *> *_Nullable)getPropertiesForClass:(Class)className;
@end

@interface MNJMClassPropertyDetail : NSObject
@property (nonatomic) NSString *propertyName;
@property (nonatomic, nullable) NSString *objCType;
@property (nonatomic) NSString *className;
@end

NS_ASSUME_NONNULL_END
