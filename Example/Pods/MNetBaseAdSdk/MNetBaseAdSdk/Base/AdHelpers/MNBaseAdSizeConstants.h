//
//  MNBaseAdSizeConstants.h
//  Pods
//
//  Created by nithin.g on 23/06/17.
//
//

#import "MNBaseAdSize.h"
#import <Foundation/Foundation.h>

/// Helper function to get MNBaseAdSize from CGSize
extern MNBaseAdSize *_Nonnull MNBaseAdSizeFromCGSize(CGSize size);

/// Helper function to to CGSize from MNBaseAdSize
extern CGSize MNBaseCGSizeFromAdSize(MNBaseAdSize *_Nonnull adSize);
