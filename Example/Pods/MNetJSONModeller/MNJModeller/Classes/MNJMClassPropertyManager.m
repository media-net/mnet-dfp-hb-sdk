//
//  MNJMClassPropertyManager.m
//  MNetJSONModeller
//
//  Created by nithin.g on 27/10/17.
//

#import "MNJMClassPropertyManager+Internal.h"

@implementation MNJMClassPropertyManager

static MNJMClassPropertyManager *instance;
static NSUInteger lruCacheLimit = 20;

+ (instancetype)getSharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      instance = [MNJMClassPropertyManager new];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.lruMemoisationCache = [MNJMLRUManager getInstanceWithLimit:lruCacheLimit];
    }
    return self;
}

- (NSArray<MNJMClassPropertyDetail *> *)getPropertiesForClass:(Class)className {
    NSString *originalClassNameStr                     = NSStringFromClass(className);
    NSArray<MNJMClassPropertyDetail *> *storedResponse = [self.lruMemoisationCache getEntryforKey:originalClassNameStr];
    if (storedResponse != nil) {
        return storedResponse;
    }

    NSMutableArray<MNJMClassPropertyDetail *> *mergedPropertyDetails = [[NSMutableArray alloc] init];

    Class currentClass = className;
    while ([currentClass isSubclassOfClass:[NSObject class]]) {
        NSArray<MNJMClassPropertyDetail *> *propertyDetails = [self getPropertiesForClassInternal:currentClass];
        [mergedPropertyDetails addObjectsFromArray:propertyDetails];
        currentClass = [currentClass superclass];

        if ([self doesClassContainReservedPrefix:NSStringFromClass(currentClass)]) {
            break;
        }
    }

    NSArray *finalPropertiesForClass = [NSArray arrayWithArray:mergedPropertyDetails];
    [self.lruMemoisationCache addEntry:finalPropertiesForClass withKey:originalClassNameStr];
    return finalPropertiesForClass;
}

- (NSArray<MNJMClassPropertyDetail *> *)getPropertiesForClassInternal:(Class)className {
    NSMutableArray<MNJMClassPropertyDetail *> *propertyDetailsList = [[NSMutableArray alloc] init];

    unsigned int count;
    objc_property_t *classProperties = class_copyPropertyList(className, &count);
    if (count == 0) {
        return nil;
    }

    for (int i = 0; i < count; i++) {
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(classProperties[i])];
        NSString *propertyType = [self getObjCTypeForProperty:classProperties[i]];

        MNJMClassPropertyDetail *detail = [MNJMClassPropertyDetail new];
        [detail setObjCType:propertyType];
        [detail setClassName:NSStringFromClass(className)];
        [detail setPropertyName:propertyName];

        [propertyDetailsList addObject:detail];
    }
    return [NSArray arrayWithArray:propertyDetailsList];
}

- (NSString *_Nullable)getObjCTypeForProperty:(objc_property_t)property {
    const char *attributes = property_getAttributes(property);
    char buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);
    char *state = buffer, *attribute;
    while ((attribute = strsep(&state, ",")) != NULL) {
        if (attribute[0] == 'T' && attribute[1] != '@') {
            // it's a C primitive type:
            return nil;
        } else if (attribute[0] == 'T' && attribute[1] == '@' && strlen(attribute) == 2) {
            // it's an ObjC id type:
            // Excluding id types for now.
            return nil;
        } else if (attribute[0] == 'T' && attribute[1] == '@') {
            // it's another ObjC object type:
            if (strlen(attribute) > 4) {
                NSData *data = [NSData dataWithBytes:(attribute + 3) length:strlen(attribute) - 4];
                if ([data length] > 0) {
                    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                }
            }
            return nil;
        }
    }
    return nil;
}

- (BOOL)doesClassContainReservedPrefix:(NSString *_Nullable)classNameStr {
    if (classNameStr == nil) {
        return NO;
    }

    // TODO: Need to find a good way to prevent prefixes such as these to work
    // Maybe a regex here would be ideal.
    // This list is fetched from here -
    // https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/Conventions/Conventions.html#//apple_ref/doc/uid/TP40011210-CH10-SW4
    NSArray<NSString *> *reservedNamespacePrefix = @[ @"NS", @"AV", @"UI", @"AB", @"CA", @"CI" ];

    NSString *conditionalPrefixes   = [reservedNamespacePrefix componentsJoinedByString:@"|"];
    NSString *reservedPrefixesRegex = [NSString stringWithFormat:@"^(?:%@)[A-Z][a-z]", conditionalPrefixes];

    // Perform regex match here.
    NSError *regexErr;
    NSRegularExpression *regex =
        [NSRegularExpression regularExpressionWithPattern:reservedPrefixesRegex options:0 error:&regexErr];
    if (regexErr != nil) {
        return NO;
    }

    NSUInteger numMatches =
        [regex numberOfMatchesInString:classNameStr options:0 range:NSMakeRange(0, [classNameStr length])];
    return numMatches > 0;
}

@end

@implementation MNJMClassPropertyDetail

@end
