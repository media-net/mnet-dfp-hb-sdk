//
//  MNALUtils.m
//  Pods
//
//  Created by nithin.g on 25/05/17.
//
//

#import <objc/runtime.h>

#import "MNALAppLink.h"
#import "MNALBlackList.h"
#import "MNALConstants.h"
#import "MNALLog.h"
#import "MNALUtils.h"
#import "NSString+MNALStringCrypto.h"

#define MNLocalizeString(key) [NSBundle.mainBundle localizedStringForKey:(key) value:@"" table:nil]
#define MNET_ERROR_DOMAIN @"mnet_err"

#define NESTED_LEVEL_LIMIT 10
#define PROPS_COUNT_LIMIT 20

@implementation MNALUtils

+ (NSError *)createErrorWithDescription:(NSString *)descriptionStr {
    return [[self class] createErrorWithDescription:descriptionStr AndFailureReason:@"" AndRecoverySuggestion:@""];
}

+ (NSError *)createErrorWithDescription:(NSString *)descriptionStr
                       AndFailureReason:(NSString *)failureReasonStr
                  AndRecoverySuggestion:(NSString *)recoverySuggestionStr {
    NSDictionary *userInfo = @{
        NSLocalizedDescriptionKey : MNLocalizeString(descriptionStr),
        NSLocalizedFailureReasonErrorKey : MNLocalizeString((failureReasonStr) ? failureReasonStr : descriptionStr),
        NSLocalizedRecoverySuggestionErrorKey : MNLocalizeString((recoverySuggestionStr) ? recoverySuggestionStr : @""),
    };

    return [NSError errorWithDomain:MNET_ERROR_DOMAIN code:500 userInfo:userInfo];
}

+ (NSNumber *)getTimestamp {
    return [NSNumber numberWithDouble:round([[NSDate date] timeIntervalSince1970])];
}

+ (NSString *)truncateNodeIdStr:(NSString *)nodeIdStr {
    NSString *updatedStr = nodeIdStr;
    NSString *sep        = @".";
    if ([nodeIdStr containsString:sep]) {
        NSArray *components = [nodeIdStr componentsSeparatedByString:sep];
        updatedStr          = [components lastObject];
    }

    return updatedStr;
}

+ (NSString *)getBundleId {
    NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];

    NSString *suffix = [MNALAppLink getSuffixForBundleId];
    if (suffix != nil) {
        suffix = [suffix stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([suffix isEqualToString:@""] == NO) {
            bundleId = [NSString stringWithFormat:@"%@.%@", bundleId, suffix];
        }
    }
    return bundleId;
}

+ (NSString *)encodeUrlComponent:(NSString *)str {
    NSString *encodedSegmentLink = @"";
    if (str != nil && ![str isEqualToString:@""]) {
        NSCharacterSet *characterSet = [NSCharacterSet URLHostAllowedCharacterSet];
        encodedSegmentLink           = [str stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
    }
    return encodedSegmentLink;
}

+ (NSString *)getContentHash:(UIViewController *)controller viewTreeContent:(NSString *)content {
    NSString *hashStr;
    NSMutableDictionary *propsDict = [self getBasicPropsForObject:controller];
    [propsDict setObject:[MNALUtils getTitleForController:controller] forKey:@"title"];
    if (content && ![content isEqualToString:@""]) {
        [propsDict setObject:content forKey:@"text-content"];
    }

    NSString *jsonStr = [self convertCollectionToStr:propsDict];
    hashStr           = [jsonStr MD5];

    MNALLinkLog(@"HASH: %@", controller);
    MNALLinkLog(@"HASH: Dict: %@", jsonStr);
    MNALLinkLog(@"HASH: MD5:  %@", hashStr);
    MNALLinkLog(@"HASH: *************");

    return hashStr;
}

+ (NSString *)convertCollectionToStr:(id)collection {
    NSString *collectionStr = @"";
    if (collection == nil) {
        return collectionStr;
    }

    NSError *err;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:collection options:0 error:&err];
    collectionStr    = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    if (err != nil) {
        collectionStr = @"";
        MNALLinkLog(@"Collection str convert ");
    }
    return collectionStr;
}

+ (NSString *)getNSStringFromChar:(const char *)charVal {
    NSString *charStr;
    NSData *charData = [NSData dataWithBytes:charVal length:strlen(charVal)];
    if (charData) {
        charStr = [[NSString alloc] initWithData:charData encoding:NSUTF8StringEncoding];
    }

    return charStr;
}

+ (NSMutableDictionary *)getBasicPropsForObject:(id)obj {
    return [self __getBasicPropsForObject:obj forLevel:0];
}

+ (NSMutableDictionary *)__getBasicPropsForObject:(id)obj forLevel:(NSInteger)level {
    NSMutableDictionary *propsDict = [[NSMutableDictionary alloc] init];
    if (obj == nil) {
        return propsDict;
    }

    BOOL isPagerController = NO;
    if ([obj isKindOfClass:[UIViewController class]]) {
        UIViewController *controller = (UIViewController *) obj;
        UIViewController *parentVC   = controller.parentViewController;
        if (parentVC != nil && [parentVC isKindOfClass:[UIPageViewController class]]) {
            isPagerController = YES;
        }
    }

    if (level > NESTED_LEVEL_LIMIT) {
        return propsDict;
    }

    // Only going to fetch the string and index paths as of now
    NSMutableArray<NSString *> *basicPropTypes = [[NSMutableArray alloc] initWithArray:@[
        //@"NSString",
        @"NSIndexPath", @"NSURL"
    ]];
    if (isPagerController) {
        NSArray<NSString *> *pagerPropTypes = @[ @"NSUInteger", @"NSInteger" ];
        [basicPropTypes addObjectsFromArray:pagerPropTypes];
    }

    uint count;
    objc_property_t *properties = class_copyPropertyList([obj class], &count);
    if (count > PROPS_COUNT_LIMIT) {
        count = PROPS_COUNT_LIMIT;
    }

    for (int i = 0; i < count; i++) {
        @try {
            const char *propertyNameChar = property_getName(properties[i]);
            const char *propertyTypeChar = [self getPropertyType:properties[i]];

            NSString *propertyName = [self getNSStringFromChar:propertyNameChar];
            ;
            NSString *propertyType = [self getNSStringFromChar:propertyTypeChar];

            if (propertyType == nil) {
                continue;
            }

            propertyType = [self sanitizeTypeName:propertyType];

            if ([propertyType length] > 2) {
                if ([basicPropTypes containsObject:propertyType]) {
                    // Adding all the required types here
                    if ([propertyType isEqualToString:@"NSIndexPath"]) {
                        NSIndexPath *indexPath = [obj valueForKey:propertyName];

                        NSString *rowStr       = [NSString stringWithFormat:@"%ld", (long) [indexPath row]];
                        NSString *sectionStr   = [NSString stringWithFormat:@"%ld", (long) [indexPath section]];
                        NSDictionary *contents = @{ @"row" : rowStr, @"section" : sectionStr };

                        [propsDict setValue:contents forKey:propertyName];

                    } else if ([propertyType isEqualToString:@"NSURL"]) {
                        NSURL *url = [obj valueForKey:propertyName];
                        [propsDict setValue:[url absoluteString] forKey:propertyName];
                    } else if ([propertyType isEqualToString:@"NSString"]) {
                        // Ignore the strings that contain only numbers
                        NSString *stringVal = [obj valueForKey:propertyName];

                        NSCharacterSet *notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
                        if (!([stringVal rangeOfCharacterFromSet:notDigits].location == NSNotFound)) {
                            [propsDict setValue:stringVal forKey:propertyName];
                        }
                    } else if ([propertyType isEqualToString:@"NSInteger"] ||
                               [propertyType isEqualToString:@"NSUInteger"]) {

                        if ([propertyName isEqualToString:@"hash"] == NO) {
                            NSString *stringVal = [obj valueForKey:propertyName];
                            [propsDict setValue:stringVal forKey:propertyName];
                        }
                    }
                } else {
                    // Performing recusive search of custom classes
                    if ([self isReservedPropertyType:propertyType] == NO) {
                        NSArray *skipList = [[MNALBlackList getInstance] getIntentsBlackListForCurrentApp];

                        if (![skipList containsObject:propertyName]) {
                            NSMutableDictionary *respDict =
                                [self __getBasicPropsForObject:[obj valueForKey:propertyName] forLevel:(level + 1)];
                            [propsDict setValue:respDict forKey:propertyName];
                        }
                    }
                }
            }
        } @catch (NSException *exception) {
            MNALLinkLog(@"EXCEPTION: getting properties");
        }
    }
    free(properties);

    return propsDict;
}

+ (BOOL)isReservedPropertyType:(NSString *)propertyStr {
    if (propertyStr == nil) {
        return NO;
    }

    // TODO: Need to find a good way to prevent prefixes such as these to work
    // Maybe a regex here would be ideal.
    // This list is fetched from here -
    // https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/Conventions/Conventions.html#//apple_ref/doc/uid/TP40011210-CH10-SW4
    NSArray<NSString *> *reservedNamespacePrefix = @[ @"NS", @"AV", @"UI", @"AB", @"CA", @"CI", @"MNAL" ];
    return [self doesClassStr:propertyStr havePrefixFromList:reservedNamespacePrefix];
}

+ (BOOL)isClassStrOfAdType:(NSString *)classStr {
    NSArray<NSString *> *adViewPrefixes = @[ @"GAD", @"DFP", @"MP", @"MNet", @"MNetMRAID" ];
    return [self doesClassStr:classStr havePrefixFromList:adViewPrefixes];
}

+ (BOOL)doesClassStr:(NSString *)classStr havePrefixFromList:(NSArray<NSString *> *)prefixList {
    NSArray<NSString *> *sortedArray;
    sortedArray = [prefixList sortedArrayUsingComparator:^NSComparisonResult(NSString *a, NSString *b) {
      NSNumber *aLength = [NSNumber numberWithUnsignedInteger:a.length];
      NSNumber *bLength = [NSNumber numberWithUnsignedInteger:b.length];
      return [bLength compare:aLength];
    }];
    prefixList = sortedArray;

    NSString *conditionalPrefixes   = [prefixList componentsJoinedByString:@"|"];
    NSString *reservedPrefixesRegex = [NSString stringWithFormat:@"^(?:%@)[A-Z][a-z]", conditionalPrefixes];

    // Perform regex match here.
    NSError *regexErr;
    NSRegularExpression *regex =
        [NSRegularExpression regularExpressionWithPattern:reservedPrefixesRegex options:0 error:&regexErr];
    if (regexErr != nil) {
        return NO;
    }

    NSUInteger numMatches = [regex numberOfMatchesInString:classStr options:0 range:NSMakeRange(0, [classStr length])];
    return numMatches > 0;
}

+ (NSString *)sanitizeTypeName:(NSString *)typeStr {
    typeStr = [typeStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    if ([typeStr length] > 2) {
        if ([typeStr characterAtIndex:0] == '<' && [typeStr characterAtIndex:([typeStr length] - 1)] == '>') {
            typeStr = [typeStr substringWithRange:NSMakeRange(1, ([typeStr length] - 2))];
        }

        NSString *sep = @"_";
        if ([typeStr containsString:sep]) {
            typeStr = [[typeStr componentsSeparatedByString:sep] lastObject];
        }
    }
    return typeStr;
}

+ (const char *)getPropertyType:(objc_property_t)property {
    const char *attributes = property_getAttributes(property);
    // printf("attributes=%s\n", attributes);
    char buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);
    char *state = buffer, *attribute;
    while ((attribute = strsep(&state, ",")) != NULL) {
        if (attribute[0] == 'T' && attribute[1] != '@') {
            // it's a C primitive type:
            /*
             if you want a list of what will be returned for these primitives, search online for
             "objective-c" "Property Attribute Description Examples"
             apple docs list plenty of examples of what you get for int "i", long "l", unsigned "I", struct, etc.
             */
            if (attribute[0] == 'T' && attribute[1] == 'q') {
                return "NSInteger";
            } else if (attribute[0] == 'T' && attribute[1] == 'Q') {
                return "NSUInteger";
            }
            return (const char *) [[NSData dataWithBytes:(attribute + 1) length:strlen(attribute) - 1] bytes];
        } else if (attribute[0] == 'T' && attribute[1] == '@' && strlen(attribute) == 2) {
            // it's an ObjC id type:
            return "id";
        } else if (attribute[0] == 'T' && attribute[1] == '@') {
            // it's another ObjC object type:
            if (strlen(attribute) > 4) {
                return (const char *) [[NSData dataWithBytes:(attribute + 3) length:strlen(attribute) - 4] bytes];
            }
        }
    }
    return "";
}

+ (NSString *)getTitleForController:(UIViewController *)controller {
    NSString *title = [controller title];
    if (title == nil || [title isEqualToString:@""]) {
        title = NSStringFromClass([controller class]);
    }
    return title;
}

+ (NSString *)getRandomString {
    return [[NSProcessInfo processInfo] globallyUniqueString];
}

+ (NSString *)getAppVersionStr {
    NSString *appBuildNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString *versionStr     = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *sep            = @"b";

    NSString *appVersionStr = [NSString stringWithFormat:@"%@%@%@", versionStr, sep, appBuildNumber];

    // Replace all the dots to hyphens
    appVersionStr = [appVersionStr stringByReplacingOccurrencesOfString:@"." withString:@"-"];
    return appVersionStr;
}

+ (NSNumber *)getNormalizedDimension:(CGFloat)dim isWidth:(BOOL)isWidth {
    CGSize screenSize = UIScreen.mainScreen.bounds.size;
    CGFloat cent      = 100.0;
    CGFloat boundVal  = (isWidth) ? screenSize.width : screenSize.height;

    CGFloat modifiedDim = (dim / boundVal) * cent;
    return [NSNumber numberWithFloat:modifiedDim];
}

+ (NSString *)getURIForControllerName:(NSString *)controllerName {
    NSString *bundleIdentifier     = [MNALUtils getBundleId];
    NSArray *bundleIdentifierArray = [bundleIdentifier componentsSeparatedByString:@"."];
    NSString *identifier           = @"";
    NSUInteger i                   = [bundleIdentifierArray count];
    for (; i > 0; i--) {
        identifier = [identifier stringByAppendingString:bundleIdentifierArray[i - 1]];
        if ((i - 1) != 0) {
            identifier = [identifier stringByAppendingString:@"."];
        }
    }
    NSString *http = @"http://";
    NSString *url  = [http stringByAppendingString:[identifier lowercaseString]];
    return [url stringByAppendingString:[NSString stringWithFormat:@".imnapp/%@/%@", [MNALUtils getAppVersionStr],
                                                                   controllerName]];
}

+ (NSString *)getEncodedLink:(NSString *)link {
    NSString *encodedSegmentLink = @"";
    if (link != nil && ![link isEqualToString:@""]) {
        NSCharacterSet *characterSet = [NSCharacterSet URLHostAllowedCharacterSet];
        encodedSegmentLink           = [link stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
    }
    return encodedSegmentLink;
}

+ (BOOL)isAdapterChild:(UIView *)view viewController:(UIViewController *)controller {
    return ([controller isKindOfClass:[UITableViewController class]] ||
            [controller isKindOfClass:[UICollectionViewController class]] ||
            [controller isKindOfClass:[UITabBarController class]]);
}

/*
 Resource name = "(Name of view)" + ":" + "index/" + "(index of view in superview)"
 Temporary way to give resource name.
 */

+ (NSString *)getResourceNameForView:(UIView *)view withId:(int)viewId {
    UIView *parentView     = [view superview];
    NSUInteger index       = [parentView.subviews indexOfObject:view];
    NSString *resourceName = [NSStringFromClass(view.class) lowercaseString];
    return [resourceName stringByAppendingString:[NSString stringWithFormat:@":index/%lu", (long) index]];
}

+ (NSInteger)getTotalRowsForView:(UIView *)view forSection:(NSInteger)section andRow:(NSInteger)row {
    if (view == nil) {
        return 0;
    }

    UITableView *tableView;
    UICollectionView *collectionView;
    BOOL isTableView = [view isKindOfClass:[UITableView class]];
    if (isTableView) {
        tableView = (UITableView *) view;
    } else {
        collectionView = (UICollectionView *) view;
    }

    NSInteger sectionIterator;
    NSInteger totalRows = 0;
    for (sectionIterator = 0; sectionIterator < section; sectionIterator++) {
        totalRows += isTableView ? [tableView numberOfRowsInSection:sectionIterator]
                                 : [collectionView numberOfItemsInSection:sectionIterator];
    }
    totalRows += row;

    return totalRows;
}

+ (NSInteger)getTotalRowsForView:(UIView *)view {
    if (view == nil) {
        return 0;
    }

    UITableView *tableView;
    UICollectionView *collectionView;
    BOOL isTableView = [view isKindOfClass:[UITableView class]];
    if (isTableView) {
        tableView = (UITableView *) view;
    } else {
        collectionView = (UICollectionView *) view;
    }

    NSInteger sectionIterator;
    NSInteger section   = isTableView ? [tableView numberOfSections] : [collectionView numberOfSections];
    NSInteger totalRows = 0;
    for (sectionIterator = 0; sectionIterator < section; sectionIterator++) {
        totalRows += isTableView ? [tableView numberOfRowsInSection:sectionIterator]
                                 : [collectionView numberOfItemsInSection:sectionIterator];
    }

    return totalRows;
}

+ (NSIndexPath *)getIndexPathForView:(UIView *)view forIndex:(NSNumber *)index {
    if (!view || index == nil) {
        return nil;
    }

    UITableView *tableView;
    UICollectionView *collectionView;

    BOOL isTableView = [view isKindOfClass:[UITableView class]];
    if (isTableView) {
        tableView = (UITableView *) view;
    } else {
        collectionView = (UICollectionView *) view;
    }
    NSInteger indexVal    = [index integerValue];
    NSInteger numSections = isTableView ? [tableView numberOfSections] : [collectionView numberOfSections];
    NSInteger totalRows   = 0;
    NSInteger currentSection;
    NSInteger finalIndexVal = -1;
    for (currentSection = 0; currentSection < numSections; currentSection++) {
        NSInteger numRows = isTableView ? [tableView numberOfRowsInSection:currentSection]
                                        : [collectionView numberOfItemsInSection:currentSection];
        totalRows += numRows;
        if (totalRows > indexVal) {
            NSInteger prevNum = (totalRows - numRows);
            finalIndexVal     = indexVal - prevNum;
            break;
        }
    }
    if (currentSection == numSections || finalIndexVal == -1) {
        return nil;
    }
    return [NSIndexPath indexPathForRow:finalIndexVal inSection:currentSection];
}

@end
