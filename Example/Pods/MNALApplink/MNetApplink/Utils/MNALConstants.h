//
//  MNALConstants.h
//  Pods
//
//  Created by kunal.ch on 16/05/17.
//
//

#import <Foundation/Foundation.h>

// Key name that's injected onto the view controller
#define UNIQUE_VALUE_KEY_NAME @"mnet_crawler_unique_key"

extern NSString *const MNAL_TEXT;
extern NSString *const MNAL_VIEW_CLASS;
extern NSString *const MNAL_VIEW_TYPE;
extern NSString *const MNAL_RESOURCE_NAME;
extern NSString *const MNAL_VIEW_ID;
extern NSString *const MNAL_SCROLLABLE;
extern NSString *const MNAL_CLICKABLE;
extern NSString *const MNAL_PROPERTIES;
extern NSString *const MNAL_PARENT;
extern NSString *const MNAL_CHILD;
extern NSString *const MNAL_START_OFFSET;
extern NSString *const MNAL_PAGE_COUNT;
extern NSString *const MNAL_SEGMENTS;
extern NSString *const MNAL_CHILD_OFFSET;

extern NSString *const MNAL_VIEW_RECT_NORMALIZED;

// Bundle id
extern NSString *const MNAL_WIKIPEDIA_BUNDLE;
extern NSString *const MNAL_HACKERNEWS_BUNDLE;
extern NSString *const MNAL_NYTIMES_BUNDLE;

@interface MNALConstants : NSObject

@end
