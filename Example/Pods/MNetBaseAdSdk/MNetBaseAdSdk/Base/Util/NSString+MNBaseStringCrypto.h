//
//  NSString+MNBaseStringCrypto.h
//  Pods
//
//  Created by nithin.g on 08/06/17.
//
//

#import <Foundation/Foundation.h>

@interface NSString (MNBaseStringCrypto)
- (NSString *)MD5;
- (NSData *)MD5CharData;
- (NSString *)stringByReplacingOccurrencesOfStringInUrl:(NSString *)target withString:(NSString *)replacement;
@end
