//
//  DBLibraryManager.h
//  DBCamera
//
//  Created by iBo on 05/03/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

/**
 *  Completion block for groups items
 *
 *  @param success The success valuefor the operation
 *  @param items   The array items loaded into the Library
 */
typedef void (^GroupsCompletionBlock)(NSError *error, NSArray *items );

/**
 *  Completion block for the first image into the Library
 *
 *  @param success The success valuefor the operation
 *  @param image   The first founded UIImage
 */
typedef void (^LastItemCompletionBlock)( BOOL success, UIImage *image );

/**
 *  The object that manages the Library operations
 */
@interface DBLibraryManager : NSObject {
    GroupsCompletionBlock _groupsCompletionBlock;
    LastItemCompletionBlock _lastItemCompletionBlock;
}

/**
 *  The bool value that indicates if the operation returns all the assets or the first image founded.
 */
@property (nonatomic, assign, readonly) BOOL getAllAssets;

/**
 *  The asset group enumerator property
 */
@property (nonatomic, copy) ALAssetsLibraryGroupsEnumerationResultsBlock assetGroupEnumerator;

/**
 *  DBLibraryManager is a singleton
 *
 *  @return Return the shared instance of DBLibraryManager
 */
+ (DBLibraryManager *) sharedInstance;

/**
 *  The default Asset Library
 *
 *  @return Return the default Asset Library
 */
- (ALAssetsLibrary *) defaultAssetsLibrary;

/**
 *  Set the Album Name font for the title
 */
@property (nonatomic, strong) UIFont * titleFont;

/**
 *  Set the font for the tap to change album label
 */
@property (nonatomic, strong) UIFont * subtitleFont;

/**
 *  Load the last image item
 *
 *  @param blockhandler The completion block of the method
 */
- (void) loadLastItemWithBlock:(LastItemCompletionBlock)blockhandler;

/**
 *  Load the Groups items
 *
 *  @param blockhandler blockhandler The completion block of the method
 */
- (void) loadGroupsAssetWithBlock:(GroupsCompletionBlock)blockhandler;
@end