//
//  MNJMManager.m
//  Pods
//
//  Created by akshay.d on 17/02/17.
//
//

#import "MNJMBoolean.h"
#import "MNJMClassPropertyManager.h"
#import "MNJMCollectionsInfo.h"
#import "MNJMManager+Internal.h"

#import <objc/runtime.h>

NSString *MNJM_ToJSONString(NSObject *source);
void MNJM_FromJSON(NSString *jsonString, NSObject *object);
void MNJM_FromJsonDict(id source, NSObject *object);
NSObject *MNJM_ParseWithPropertiesOfObject(id object);

@implementation MNJMManager

#pragma mark - Public methods

+ (NSString *)toJSONStr:(id)source {
    return MNJM_ToJSONString(source);
}

+ (void)fromJSONStr:(NSString *)jsonString toObj:(id)object {
    MNJM_FromJSON(jsonString, object);
}

+ (void)fromDict:(NSDictionary *)dict toObject:(id<MNJMMapperProtocol>)object {
    MNJM_FromJsonDict(dict, object);
}

+ (id)getCollectionFromObj:(id)object {
    return MNJM_ParseWithPropertiesOfObject(object);
}

#pragma mark - Internal methods

void MNJM_FromJSON(NSString *jsonString, NSObject *object) {
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *e;
    NSDictionary *source = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&e];
    MNJM_FromJsonDict(source, object);
}

void MNJM_FromJsonDict(id source, NSObject *object) {
    if ([source isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *values = [[NSMutableDictionary alloc] init];
        // sanitize dict
        id<MNJMMapperProtocol> mapper;
        if ([object conformsToProtocol:@protocol(MNJMMapperProtocol)]) {
            mapper = (id<MNJMMapperProtocol>) object;
        }
        MNJM_mapKeys(mapper, source, values);
        MNJM_setValue(object, values);
    } else {
        // If the source is not a dictionary, just set it
        MNJM_setValue(object, source);
    }
}

void MNJM_setValue(NSObject *obj, NSDictionary *valuesDict) {
    if ([obj class] == nil) {
        return;
    }
    MNJMClassPropertyManager *propertiesManager             = [MNJMClassPropertyManager getSharedInstance];
    NSArray<MNJMClassPropertyDetail *> *propertyDetailsList = [propertiesManager getPropertiesForClass:[obj class]];
    for (MNJMClassPropertyDetail *propertyDetail in propertyDetailsList) {
        NSString *propertyName    = [propertyDetail propertyName];
        NSObject *propValFromDict = [valuesDict valueForKey:propertyName];

        if (propValFromDict == nil) {
            continue;
        }

        NSString *propertyTypeStr = [propertyDetail objCType];
        Class propertyType        = (propertyTypeStr != nil) ? NSClassFromString(propertyTypeStr) : nil;

        BOOL isCType = (propertyType == nil || ([[propValFromDict class] isSubclassOfClass:[NSObject class]] == NO));

        if (isCType) {
            [obj setValue:propValFromDict forKey:propertyName];
        } else if (propertyType == [NSString class]) {
            [obj setValue:propValFromDict forKey:propertyName];
        } else if (propertyType == [NSNumber class]) {
            [obj setValue:propValFromDict forKey:propertyName];
        } else if (propertyType == [NSDate class]) {
            propValFromDict = [MNJM_getReverseDateFormatter() dateFromString:(NSString *) propValFromDict];
            [obj setValue:propValFromDict forKey:propertyName];
        } else if (propertyType == [MNJMBoolean class]) {
            BOOL boolVal = [[valuesDict valueForKey:propertyName] boolValue];
            [obj setValue:[MNJMBoolean createWithBool:boolVal] forKey:propertyName];
        } else if (propertyType == [NSArray class] || propertyType == [NSMutableArray class]) {
            MNJM_mapNSArrayIntoObj(obj, propertyName, valuesDict);

        } else if (propertyType == [NSDictionary class] || propertyType == [NSMutableDictionary class]) {
            MNJM_mapNSDictionaryIntoObj(obj, propertyName, valuesDict);

        } else if (propertyType != nil) {
            // It's a custom object
            NSObject *propertyObj = [obj valueForKey:propertyName];
            if (propertyObj == nil) {
                propertyObj = [[propertyType alloc] init];
            }

            MNJM_FromJsonDict(propValFromDict, propertyObj);
            [obj setValue:propertyObj forKey:propertyName];
        }
    }
}

void MNJM_mapNSArrayIntoObj(NSObject *obj, NSString *propertyName, NSDictionary *valuesDict) {
    NSObject *propValFromDict = [valuesDict valueForKey:propertyName];

    BOOL isPropValFromDictAnArray =
        ([propValFromDict isKindOfClass:[NSArray class]] || [propValFromDict isKindOfClass:[NSMutableArray class]]);
    if (isPropValFromDictAnArray == NO) {
        return;
    }

    NSArray *propValArray = (NSArray *) propValFromDict;

    NSObject<MNJMMapperProtocol> *protocolObj      = (NSObject<MNJMMapperProtocol> *) obj;
    MNJMCollectionsInfo *collectionInfoForProperty = MNJM_getCollectionInfoForObjWithName(protocolObj, propertyName);
    BOOL isCollectionInfoValid =
        (collectionInfoForProperty != nil && ([collectionInfoForProperty collectionType] == MNJMCollectionsTypeArray) &&
         ([collectionInfoForProperty arrClassType] != nil));

    if (isCollectionInfoValid == NO) {
        [obj setValue:propValFromDict forKey:propertyName];
        return;
    }

    // Creating an array with the contents
    Class arrayContentType             = [collectionInfoForProperty arrClassType];
    NSMutableArray *finalPropertiesArr = [[NSMutableArray alloc] initWithCapacity:[propValArray count]];

    for (NSDictionary *propertyElementDict in propValArray) {
        NSObject *propertyObj;
        if (arrayContentType == [NSString class] || arrayContentType == [NSMutableString class]) {
            propertyObj = (NSString *) propertyElementDict;
        } else if (arrayContentType == [NSNumber class]) {
            propertyObj = (NSNumber *) propertyElementDict;
        } else if (arrayContentType == [MNJMBoolean class]) {
            propertyObj = [MNJMBoolean createWithBool:(BOOL) propertyElementDict];
        } else {
            propertyObj = [[arrayContentType alloc] init];
            MNJM_FromJsonDict(propertyElementDict, propertyObj);
        }

        [finalPropertiesArr addObject:propertyObj];
    }

    [obj setValue:[NSArray arrayWithArray:finalPropertiesArr] forKey:propertyName];
}

void MNJM_mapNSDictionaryIntoObj(NSObject *obj, NSString *propertyName, NSDictionary *valuesDict) {
    NSObject *propValFromDict = [valuesDict valueForKey:propertyName];

    BOOL isPropValFromDictADictionary = ([propValFromDict isKindOfClass:[NSDictionary class]] ||
                                         [propValFromDict isKindOfClass:[NSMutableDictionary class]]);

    if (isPropValFromDictADictionary == NO) {
        return;
    }

    NSObject<MNJMMapperProtocol> *protocolObj      = (NSObject<MNJMMapperProtocol> *) obj;
    MNJMCollectionsInfo *collectionInfoForProperty = MNJM_getCollectionInfoForObjWithName(protocolObj, propertyName);
    BOOL isCollectionInfoValid                     = (collectionInfoForProperty != nil &&
                                  ([collectionInfoForProperty collectionType] == MNJMCollectionsTypeDictionary) &&
                                  ([collectionInfoForProperty dictKeyClassType] != nil) &&
                                  ([collectionInfoForProperty dictValueClassType] != nil));

    if (isCollectionInfoValid == NO) {
        [obj setValue:propValFromDict forKey:propertyName];
        return;
    }

    NSDictionary *propValDictionary = (NSDictionary *) propValFromDict;

    // Creating a dictionary with the contents
    Class dictKeyType   = [collectionInfoForProperty dictKeyClassType];
    Class dictValueType = [collectionInfoForProperty dictValueClassType];

    NSMutableDictionary *finalPropertiesDict = [[NSMutableDictionary alloc] initWithCapacity:[propValDictionary count]];

    for (id key in propValDictionary) {
        id keyObj;
        NSObject *valueObj;

        if (dictKeyType == [NSString class] || dictKeyType == [NSMutableString class]) {
            keyObj = key;
        } else {
            keyObj = [[dictKeyType alloc] init];
            MNJM_setValue(keyObj, key);
        }

        if (dictValueType == [NSString class] || dictValueType == [NSMutableString class]) {
            valueObj = [propValDictionary objectForKey:key];
        } else {
            valueObj = [[dictValueType alloc] init];
            MNJM_FromJsonDict([propValDictionary objectForKey:key], valueObj);
        }

        if (keyObj != nil && valueObj != nil) {
            [finalPropertiesDict setObject:valueObj forKey:keyObj];
        }
    }

    [obj setValue:[NSDictionary dictionaryWithDictionary:finalPropertiesDict] forKey:propertyName];
}

MNJMCollectionsInfo *MNJM_getCollectionInfoForObjWithName(NSObject<MNJMMapperProtocol> *protocolObj,
                                                          NSString *propertyName) {
    MNJMCollectionsInfo *collectionInfoForProperty;

    // Check if the obj conforms to the protocol
    BOOL objHasCollectionDetails = [protocolObj conformsToProtocol:@protocol(MNJMMapperProtocol)] &&
                                   [protocolObj respondsToSelector:@selector(collectionDetailsMap)];

    if (objHasCollectionDetails) {
        NSDictionary<NSString *, MNJMCollectionsInfo *> *collectionDetailsMap = [protocolObj collectionDetailsMap];
        if (collectionDetailsMap != nil) {
            collectionInfoForProperty = [collectionDetailsMap objectForKey:propertyName];
        }
    }

    return collectionInfoForProperty;
}

void MNJM_mapKeys(id<MNJMMapperProtocol> mapper, NSDictionary *source, NSMutableDictionary *dest) {
    NSArray *ignoreParsingKeys;
    NSDictionary *keyMap;

    if (mapper && NO == [mapper isKindOfClass:[MNJMCollectionsInfo class]]) {
        if ([mapper respondsToSelector:@selector(directMapForKeys)]) {
            ignoreParsingKeys = [mapper directMapForKeys];
            if ([ignoreParsingKeys count] == 0) {
                ignoreParsingKeys = nil;
            }
        }

        if ([mapper respondsToSelector:@selector(propertyKeyMap)]) {
            keyMap = [mapper propertyKeyMap];
            if ([keyMap count] == 0) {
                keyMap = nil;
            }
        }
    }

    for (NSString *key in source) {
        NSObject *obj          = [source valueForKey:key];
        NSString *camelCaseKey = MNJM_snakeCaseToCamelCase(key);

        // check if there is any mapping
        NSArray *keyListForObj = [keyMap allKeysForObject:key];
        if (keyMap && keyListForObj && [keyListForObj count] > 0) {
            camelCaseKey = [keyListForObj objectAtIndex:0];
        }

        if ([obj isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *subDict = [[NSMutableDictionary alloc] init];
            dest[camelCaseKey]           = subDict;

            if ([ignoreParsingKeys containsObject:camelCaseKey]) {
                [subDict setDictionary:[source valueForKey:key]];
            } else {
                MNJM_mapKeys(MNJM_getMapperForKey(camelCaseKey, mapper), [source valueForKey:key], subDict);
            }
            continue;
        }
        if ([obj isKindOfClass:[NSArray class]]) {
            if ([obj isKindOfClass:[NSArray<NSString *> class]]) {
                dest[camelCaseKey] = [[NSArray<NSString *> alloc] initWithArray:(NSArray<NSString *> *) obj];
                continue;
            }
        }
        dest[camelCaseKey] = obj;
    }
}

id<MNJMMapperProtocol> MNJM_getMapperForKey(NSString *key, NSObject *obj) {
    if (obj == nil) {
        return nil;
    }

    if ([obj isKindOfClass:[MNJMCollectionsInfo class]]) {
        MNJMCollectionsInfo *collectionInfo = (MNJMCollectionsInfo *) obj;
        if ([collectionInfo collectionType] == MNJMCollectionsTypeArray) {
            return [[[collectionInfo arrClassType] alloc] init];
        } else if ([collectionInfo collectionType] == MNJMCollectionsTypeDictionary) {
            return [[[collectionInfo dictValueClassType] alloc] init];
        }
    }

    MNJMClassPropertyManager *propertyManager               = [MNJMClassPropertyManager getSharedInstance];
    NSArray<MNJMClassPropertyDetail *> *propertyDetailsList = [propertyManager getPropertiesForClass:[obj class]];
    for (MNJMClassPropertyDetail *propertyDetail in propertyDetailsList) {
        if ([[propertyDetail propertyName] isEqualToString:key]) {
            id object = [obj valueForKey:key];
            if (object == nil) {
                Class newClassName = NSClassFromString([propertyDetail objCType]);
                if (newClassName != nil) {
                    if (newClassName == [NSNumber alloc]) {
                        object = [[NSNumber alloc] initWithInt:0];
                    } else {
                        object = [newClassName new];
                    }
                }
            }
            if ([object conformsToProtocol:@protocol(MNJMMapperProtocol)]) {
                return (id<MNJMMapperProtocol>) object;
            }
        }
    }

    // Get the connection details map
    id<MNJMMapperProtocol> mapperObj = (id<MNJMMapperProtocol>) obj;
    if ([mapperObj respondsToSelector:@selector(collectionDetailsMap)]) {
        NSDictionary *collectionMap = [mapperObj collectionDetailsMap];
        return [collectionMap objectForKey:key];
    }

    return nil;
}

NSString *MNJM_ToJSONString(NSObject *source) {
    id parsedObj = MNJM_ParseWithPropertiesOfObject(source);

    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parsedObj options:0 error:&error];
    if (!jsonData) {
        return @"{}";
    }
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

static NSDateFormatter *reverseFormatter;

NSDateFormatter *MNJM_getReverseDateFormatter() {
    if (!reverseFormatter) {
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        reverseFormatter = [[NSDateFormatter alloc] init];
        [reverseFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
        [reverseFormatter setLocale:locale];
    }
    return reverseFormatter;
}

NSObject *MNJM_ParseWithPropertiesOfObject(id obj) {
    if ([obj isKindOfClass:[NSArray class]]) {
        // Do array specific stuff;
        NSMutableArray *responseArr = [[NSMutableArray alloc] init];

        for (NSObject *element in obj) {
            [responseArr addObject:MNJM_ParseWithPropertiesOfObject(element)];
        }

        return responseArr;
    } else {
        NSDictionary *propertyMap;
        NSArray *keyList;
        NSUInteger count;
        NSArray<MNJMClassPropertyDetail *> *propertyDetailsList;

        BOOL isDictionary = [obj isKindOfClass:[NSDictionary class]];

        if (isDictionary) {
            count   = (uint)[obj count];
            keyList = [obj allKeys];
        } else {
            if ([obj conformsToProtocol:@protocol(MNJMMapperProtocol)]) {
                id<MNJMMapperProtocol> protocolObj = (id<MNJMMapperProtocol>) obj;
                if ([protocolObj respondsToSelector:@selector(propertyKeyMap)]) {
                    propertyMap = [protocolObj propertyKeyMap];
                }
            }

            propertyDetailsList = [[MNJMClassPropertyManager getSharedInstance] getPropertiesForClass:[obj class]];
            count               = [propertyDetailsList count];
        }

        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        for (int i = 0; i < count; i++) {
            NSString *key;

            if (isDictionary) {
                key = [keyList objectAtIndex:i];
            } else {
                key = [[propertyDetailsList objectAtIndex:i] propertyName];
            }

            // adding skiplist
            if ([key isEqualToString:@"debugDescription"] || [key isEqualToString:@"description"] ||
                [key isEqualToString:@"hash"] || [key isEqualToString:@"superclass"])
                continue;

            // Skipping private properties
            if ([key length] >= 2 && [[key substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"__"]) {
                continue;
            }

            NSString *snakeCaseKey = MNJM_camelCaseToSnakeCase(key);

            if (propertyMap && [propertyMap objectForKey:key]) {
                snakeCaseKey = propertyMap[key];
            }
            id object = [obj valueForKey:key];

            if (object) {
                if ([object isKindOfClass:[NSArray class]]) {
                    NSMutableArray *subObj = [NSMutableArray array];
                    for (id arrayElement in object) {
                        id updatedElement = arrayElement;

                        if ([arrayElement conformsToProtocol:@protocol(MNJMMapperProtocol)]) {
                            updatedElement = MNJM_ParseWithPropertiesOfObject(arrayElement);
                        }

                        [subObj addObject:updatedElement];
                    }
                    dict[snakeCaseKey] = subObj;
                } else if ([object isKindOfClass:[NSDictionary class]]) {
                    NSMutableDictionary *subObj = [[NSMutableDictionary alloc] init];
                    for (id key in object) {
                        id dictObj = object[key];
                        if ([dictObj conformsToProtocol:@protocol(MNJMMapperProtocol)]) {
                            dictObj = MNJM_ParseWithPropertiesOfObject(dictObj);
                        }
                        [subObj setObject:dictObj forKey:key];
                    }
                    dict[snakeCaseKey] = subObj;
                } else if ([object isKindOfClass:[NSString class]]) {
                    dict[snakeCaseKey] = object;
                } else if ([object isKindOfClass:[NSDate class]]) {
                    dict[snakeCaseKey] = [MNJM_getReverseDateFormatter() stringFromDate:(NSDate *) object];
                } else if ([object isKindOfClass:[NSNumber class]]) {
                    dict[snakeCaseKey] = object;
                } else if ([object isKindOfClass:[MNJMBoolean class]]) {
                    dict[snakeCaseKey] = [object isYes] ? @YES : @NO;
                } else if ([[object class] isSubclassOfClass:[NSObject class]]) {
                    if ([object conformsToProtocol:@protocol(MNJMMapperProtocol)]) {
                        dict[snakeCaseKey] = MNJM_ParseWithPropertiesOfObject(object);
                    }
                }
            }
        }
        return dict;
    }
}

NSString *MNJM_camelCaseToSnakeCase(NSString *input) {
    NSMutableString *output   = [NSMutableString string];
    NSCharacterSet *uppercase = [NSCharacterSet uppercaseLetterCharacterSet];
    for (NSInteger idx = 0; idx < [input length]; idx += 1) {
        unichar c = [input characterAtIndex:idx];
        if ([uppercase characterIsMember:c]) {
            [output appendFormat:@"_%@", [[NSString stringWithCharacters:&c length:1] lowercaseString]];
        } else {
            [output appendFormat:@"%C", c];
        }
    }
    return output;
}

NSString *MNJM_snakeCaseToCamelCase(NSString *underscores) {
    NSMutableString *output         = [NSMutableString string];
    BOOL makeNextCharacterUpperCase = NO;
    for (NSInteger idx = 0; idx < [underscores length]; idx += 1) {
        unichar c = [underscores characterAtIndex:idx];
        if (c == '_') {
            makeNextCharacterUpperCase = YES;
        } else if (makeNextCharacterUpperCase) {
            [output appendString:[[NSString stringWithCharacters:&c length:1] uppercaseString]];
            makeNextCharacterUpperCase = NO;
        } else {
            [output appendFormat:@"%C", c];
        }
    }
    return output;
}

@end
