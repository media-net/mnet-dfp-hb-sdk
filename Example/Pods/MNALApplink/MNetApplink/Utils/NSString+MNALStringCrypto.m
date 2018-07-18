//
//  NSString+MD5.m
//  Pods
//
//  Created by kunal.ch on 26/05/17.
//
//

#import "NSString+MNALStringCrypto.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (MNALStringCrypto)

- (NSString *)MD5 {
    // Create pointer to the string as UTF8
    const char *ptr = [self UTF8String];

    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];

    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(ptr, (CC_LONG) strlen(ptr), md5Buffer);

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
    CC_MD5(ptr, (CC_LONG) strlen(ptr), md5Buffer);

    NSData *data = [NSData dataWithBytes:(const void *) md5Buffer length:sizeof(unsigned char) * CC_MD5_DIGEST_LENGTH];

    return data;
}

@end
