//
//  MNBaseErrorStackTraceEvent.m
//  Pods
//
//  Created by nithin.g on 31/03/17.
//
//

#import "MNBaseErrorStackTraceEvent.h"
#import "MNBaseLogger.h"
#import "MNBaseUtil.h"

@implementation MNBaseErrorStackTraceEvent
static NSRegularExpression *stackTraceRegex;
static NSRegularExpression *fileNameRegex;

+ (void)load {
    NSError *stackTraceRegexError;
    NSError *fileNameRegexError;

    // Parsing regex - ^[0-9]+\s+([^\s]+)\s+[^\s]+\s+(\+?[^+]+)[^\d]+(\d+).*$
    // Regex explanation - https://regex101.com/r/bqaI7X/4
    NSString *stackTraceRegexStr = @"^[0-9]+\\s+([^\\s]+)\\s+[^\\s]+\\s+(\\+?[^+]+)[^\\d]+(\\d+).*$";
    stackTraceRegex              = [NSRegularExpression regularExpressionWithPattern:stackTraceRegexStr
                                                                options:NSRegularExpressionCaseInsensitive
                                                                  error:&stackTraceRegexError];
    if (fileNameRegexError != nil) {
        MNLogD(@"Error creating the regular expression for stacktrace - %@", fileNameRegexError);
        stackTraceRegex = nil;
        return;
    }

    // Extra effort for the filename
    // Regex - \[\s*([^\s]+)
    // Explanation - https://regex101.com/r/7GYG5H/1
    NSString *fileNameRegexStr = @"\\[\\s*([^\\s]+)";
    fileNameRegex              = [NSRegularExpression regularExpressionWithPattern:fileNameRegexStr
                                                              options:NSRegularExpressionCaseInsensitive
                                                                error:&fileNameRegexError];
    if (fileNameRegexError != nil) {
        MNLogD(@"Error creating the regular expression for fileName - %@", fileNameRegexError);
        fileNameRegex = nil;
        return;
    }
}

+ (MNBaseErrorStackTraceEvent *)createInstanceWithEvent:(NSString *)csEvent {
    return [[[self class] alloc] initWithCallStackEvent:csEvent];
}

- (id)initWithCallStackEvent:(NSString *)csEvent {
    self = [super init];
    if (self != nil) {
        self.lineNumber = [NSNumber numberWithInteger:-1];
        self.className  = @"";
        self.fileName   = @"";
        self.methodName = @"";

        [self parseStacktraceEntry:csEvent];
    }
    return self;
}

- (BOOL)parseStacktraceEntry:(NSString *)stEntry {
    if (stEntry == nil) {
        return NO;
    }
    stEntry = [stEntry stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([stEntry isEqualToString:@""]) {
        return NO;
    }

    /*
     NOTE: Sample entries -
     1   MNBaseAdSdk                           0x000000010be78aa8 -[MNBaseError initWithError:] + 72
     4   CoreFoundation                      0x0000000111bb1440 -[NSInvocation invoke] + 320
     5   XCTest                              0x000000012ceb8949 __24-[XCTestCase invokeTest]_block_invoke + 591
     30  UIKit                               0x000000010e749d30 UIApplicationMain + 159
     33  ???                                 0x0000000000000007 0x0 + 7
     */

    if (stackTraceRegex == nil) {
        MNLogD(@"Error creating the stack-trace regex");
        return NO;
    }

    NSArray *matches = [stackTraceRegex matchesInString:stEntry options:0 range:NSMakeRange(0, stEntry.length)];
    if ([matches count] == 0) {
        return NO;
    }

    NSTextCheckingResult *match = [matches objectAtIndex:0];
    if ([match numberOfRanges] <= 3) {
        return NO;
    }

    NSRange frameworkNameRange = [match rangeAtIndex:1];
    NSString *frameworkName    = [stEntry substringWithRange:frameworkNameRange];
    frameworkName  = [frameworkName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.className = frameworkName;

    NSRange methodNameRange = [match rangeAtIndex:2];
    NSString *methodName    = [stEntry substringWithRange:methodNameRange];
    methodName              = [methodName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.methodName         = methodName;

    NSString *fileName = [self getFileNameFromMethodName:methodName];
    if (fileName == nil) {
        fileName = methodName;
    }
    self.fileName = fileName;

    NSRange lineRange = [match rangeAtIndex:3];
    NSString *line    = [stEntry substringWithRange:lineRange];
    line              = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.lineNumber   = [NSNumber numberWithInteger:[line integerValue]];

    return YES;
}

- (NSString *_Nullable)getFileNameFromMethodName:(NSString *_Nonnull)methodName {
    if (methodName == nil) {
        return nil;
    }

    if (fileNameRegex == nil) {
        MNLogD(@"Error creating the regular expression for fileName");
        return nil;
    }

    NSArray *matches = [fileNameRegex matchesInString:methodName options:0 range:NSMakeRange(0, methodName.length)];
    if ([matches count] == 0) {
        return nil;
    }

    NSTextCheckingResult *match = [matches objectAtIndex:0];
    if ([match numberOfRanges] <= 1) {
        return nil;
    }
    NSRange fileNameRange = [match rangeAtIndex:1];
    NSString *fileNameStr = [methodName substringWithRange:fileNameRange];
    return fileNameStr;
}

- (NSDictionary *)propertyKeyMap {
    return @{
        @"lineNumber" : @"lineNumber",
        @"fileName" : @"fileName",
        @"className" : @"declaringClass",
        @"methodName" : @"methodName"
    };
}
@end
