//
//  MNBaseAdLoader+Internal.h
//  Pods
//
//  Created by nithin.g on 14/09/17.
//
//

#ifndef MNBaseAdLoader_Internal_h
#define MNBaseAdLoader_Internal_h

#import "MNBaseAdLoader.h"
#import "MNBaseAdLoaderProtocol.h"

#define LOADER_ENTRY_TYPE Class<MNBaseAdLoaderProtocol>

@interface MNBaseAdLoader ()

/// List of all the adLoader classes
@property (atomic) NSArray<LOADER_ENTRY_TYPE> *_Nonnull adLoaderClasses;

/// Selects the ad-loader depending on the ad-unit-id and the options given
- (id<MNBaseAdLoaderProtocol> _Nullable)getLoaderForAdUnitId:(NSString *_Nonnull)adUnitId
                                                  andOptions:(MNBaseAdLoaderOptions *_Nullable)options;

@end

#endif /* MNBaseAdLoader_Internal_h */
