//
//  NSString+MD5.h
//  Pods
//
//  Created by kunal.ch on 26/05/17.
//
//

#import <Foundation/Foundation.h>

@interface NSString (MNALStringCrypto)

- (NSString *)MD5;
- (NSData *)MD5CharData;

@end
