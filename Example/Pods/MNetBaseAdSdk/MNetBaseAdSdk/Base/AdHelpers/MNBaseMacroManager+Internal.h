//
//  MNBaseMacroManager+Internal.h
//  MNBaseAdSdk
//
//  Created by nithin.g on 27/03/18.
//

#ifndef MNBaseMacroManager_Internal_h
#define MNBaseMacroManager_Internal_h

#import "MNBaseMacroManager.h"

@interface MNBaseMacroManager ()
- (NSString *_Nonnull)getReplacementStrForReqUrl:(MNBaseBidResponse *_Nonnull)bidResponse
                            shouldAppendKeywords:(BOOL)shouldAppendKeywords;
@end

#endif /* MNBaseMacroManager_Internal_h */
