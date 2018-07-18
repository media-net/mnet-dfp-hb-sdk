//
//  MNALLog.h
//  Pods
//
//  Created by nithin.g on 01/09/17.
//
//

#import <Foundation/Foundation.h>

#define MNALLinkLog(format_string, ...) ((MNLogLink([NSString stringWithFormat:format_string, ##__VA_ARGS__])))

void MNLogLink(NSString *log);

@interface MNALLog : NSObject

@end
