//
//  MNJMCollectionsInfo.m
//  Pods
//
//  Created by nithin.g on 02/08/17.
//
//

#import "MNJMCollectionsInfo.h"
#import "MNJMMapperProtocol.h"

@interface MNJMCollectionsInfo () <MNJMMapperProtocol>
@end

@implementation MNJMCollectionsInfo

+ (instancetype)instanceOfArrayWithClassType:(Class)classType {
    MNJMCollectionsInfo *instance = [[MNJMCollectionsInfo alloc] init];
    instance.collectionType       = MNJMCollectionsTypeArray;
    instance.arrClassType         = classType;
    return instance;
}

+ (instancetype)instanceOfDictionaryWithKeyType:(Class)keyType andValueType:(Class)valueType {
    MNJMCollectionsInfo *instance = [[MNJMCollectionsInfo alloc] init];
    instance.collectionType       = MNJMCollectionsTypeDictionary;
    instance.dictKeyClassType     = keyType;
    instance.dictValueClassType   = valueType;
    return instance;
}

- (NSDictionary *)propertyKeyMap {
    return @{};
}

@end
