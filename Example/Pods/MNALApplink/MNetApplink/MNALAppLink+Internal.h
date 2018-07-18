//
//  MNALAppLink+Internal.h
//  Pods
//
//  Created by nithin.g on 01/09/17.
//
//

#ifndef MNALAppLink_Internal_h
#define MNALAppLink_Internal_h

#import "MNALAppLink.h"

@interface MNALAppLink ()
@property (nonatomic) UIViewController *vc;
@property (nonatomic) MNALViewTree *viewTree;
@property (nonatomic) NSString *link;
@property (nonatomic) BOOL shouldFetchContent;

/// Returns whether this module should print logs
+ (BOOL)shouldPrintLogs;

@end

#endif /* MNALAppLink_Internal_h */
