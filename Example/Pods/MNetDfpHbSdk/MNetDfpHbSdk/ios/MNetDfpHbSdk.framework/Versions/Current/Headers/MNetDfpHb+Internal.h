//
//  MNetDfpHb+Internal.h
//  MNetDfpHbSdk
//
//  Created by nithin.g on 13/07/18.
//

#ifndef MNetDfpHb_Internal_h
#define MNetDfpHb_Internal_h

#import "MNetBaseAdSdk/MNBase.h"
#import "MNetDfpHb.h"

@interface MNetDfpHb ()
@property (atomic, nonnull) MNBase *baseInstance;

+ (BOOL)isInitialized;
@end

#endif /* MNetDfpHb_Internal_h */
