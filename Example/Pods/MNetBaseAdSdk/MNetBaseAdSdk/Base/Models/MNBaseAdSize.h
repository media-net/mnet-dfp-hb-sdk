//
//  MNBaseAddSize.h
//  Pods
//
//  Created by akshay.d on 20/02/17.
//
//

#import <Foundation/Foundation.h>

@class MNBaseAdSize;

/// Helper function to create MNBaseAdSize instance
extern MNBaseAdSize *_Nullable MNBaseCreateAdSize(NSInteger width, NSInteger height);

@interface MNBaseAdSize : NSObject

/// Adsize height
@property (atomic, nonnull) NSNumber *h;

/// Adsize width
@property (atomic, nonnull) NSNumber *w;

@end
