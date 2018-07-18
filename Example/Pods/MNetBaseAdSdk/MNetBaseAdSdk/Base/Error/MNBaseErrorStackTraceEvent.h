//
//  MNBaseErrorStackTraceEvent.h
//  Pods
//
//  Created by nithin.g on 31/03/17.
//
//

#import <Foundation/Foundation.h>
#import <MNetJSONModeller/MNJMManager.h>

@interface MNBaseErrorStackTraceEvent : NSObject <MNJMMapperProtocol>
@property (atomic) NSNumber *lineNumber;
@property (atomic) NSString *className;
@property (atomic) NSString *fileName;
@property (atomic) NSString *methodName;

+ (MNBaseErrorStackTraceEvent *)createInstanceWithEvent:(NSString *)csEvent;
- (id)initWithCallStackEvent:(NSString *)csEvent;
- (NSDictionary *)propertyKeyMap;
@end
