//
//  NSString+MNBaseStringCrypto.m
//  Pods
//
//  Created by nithin.g on 08/06/17.
//
//

#import "NSString+MNBaseStringCrypto.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (MNBaseStringCrypto)

- (NSString *)MD5 {
    // Create pointer to the string as UTF8
    const char *ptr = [self UTF8String];

    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];

    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(ptr, (int) strlen(ptr), md5Buffer);

    // Convert MD5 value in the buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", md5Buffer[i]];

    return output;
}

- (NSData *)MD5CharData {
    // Create pointer to the string as UTF8
    const char *ptr = [self UTF8String];

    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];

    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(ptr, (int) strlen(ptr), md5Buffer);

    NSData *data = [NSData dataWithBytes:(const void *) md5Buffer length:sizeof(unsigned char) * CC_MD5_DIGEST_LENGTH];

    return data;
}

- (NSString *)stringByReplacingOccurrencesOfStringInUrl:(NSString *)target withString:(NSString *)replacement {
    if (!replacement || !target) {
        return self;
    }
    target      = [target URLEncodeString];
    replacement = [replacement URLEncodeString];

    return [self stringByReplacingOccurrencesOfString:target withString:replacement];
}

- (NSString *)URLEncodeString {
    static CFStringRef charset = CFSTR("!@#$%&*()+'\";:=,/?[] ");
    CFStringRef str            = (__bridge CFStringRef) self;
    CFStringEncoding encoding  = kCFStringEncodingUTF8;
    return (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, str, NULL, charset, encoding));
}

@end
