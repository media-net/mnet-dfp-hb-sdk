//
//  MNALLog.m
//  Pods
//
//  Created by nithin.g on 01/09/17.
//
//

#import "MNALLog.h"
#import "MNALAppLink+Internal.h"

@implementation MNALLog

void MNLogLink(NSString *log) {
    if ([MNALAppLink shouldPrintLogs]) {
        NSLog(@"%@", log);
    }
}
@end
