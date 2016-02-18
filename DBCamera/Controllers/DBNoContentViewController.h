//
//  DBNoContentViewController.h
//  DBCamera
//
//  Created by Iftekhar Qurashi on 18/02/16.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DBNoContentViewController;

@protocol DBNoContentViewControllerDelegate <NSObject>

@optional
- (void)noContentViewControllerDidTapOnButton:(DBNoContentViewController *)noContentViewController;

@end


@interface DBNoContentViewController : UIViewController

@property(nonatomic, weak) id<DBNoContentViewControllerDelegate> delegate;

@property(nonatomic, assign) BOOL animating;

@property(nonatomic, strong) UIImage *image;

@property(nonatomic, strong) NSString *messageTitle;
@property(nonatomic, strong) NSString *messageDescription;

@property(nonatomic, strong) NSString *buttonTitle;

@end
