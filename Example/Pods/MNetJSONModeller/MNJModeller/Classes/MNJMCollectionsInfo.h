//
//  MNJMCollectionsInfo.h
//  Pods
//
//  Created by nithin.g on 02/08/17.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    MNJMCollectionsTypeNone,
    MNJMCollectionsTypeArray,
    MNJMCollectionsTypeDictionary,
} MNJMCollectionsType;

@interface MNJMCollectionsInfo : NSObject
@property (nonatomic) MNJMCollectionsType collectionType;
@property (nonatomic) Class arrClassType;
@property (nonatomic) Class dictKeyClassType;
@property (nonatomic) Class dictValueClassType;

+ (instancetype)instanceOfArrayWithClassType:(Class)classType;
+ (instancetype)instanceOfDictionaryWithKeyType:(Class)keyType andValueType:(Class)valueType;

@end
