//
//  DBNoContentViewController.m
//  DBCamera
//
//  Created by Iftekhar Qurashi on 18/02/16.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import "DBNoContentViewController.h"

@implementation DBNoContentViewController
{
    UIActivityIndicatorView *activityIndicator;
    
    UIImageView *imageView;
    UILabel *labelTitle;
    UILabel *labelMessage;
    UIButton *buttonAction;
}

-(void)viewDidLoad
{
    [super viewDidLoad];

    UIView *containerView = [[UIView alloc] init];
    containerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:containerView];
    //Constraint
    {
        NSLayoutConstraint *constraint1 = [NSLayoutConstraint constraintWithItem:containerView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
        
        NSLayoutConstraint *constraint2 = [NSLayoutConstraint constraintWithItem:containerView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
        
        NSLayoutConstraint *constraint3 = [NSLayoutConstraint constraintWithItem:containerView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
        
        NSLayoutConstraint *constraint4 = [NSLayoutConstraint constraintWithItem:containerView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
        
        [self.view addConstraints:@[constraint1,constraint2,constraint3,constraint4]];
    }
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    
    if (self.animating)
    {
        [activityIndicator startAnimating];
    }
    else
    {
        [activityIndicator stopAnimating];
    }

    activityIndicator.tintColor = [UIColor lightGrayColor];
    [containerView addSubview:activityIndicator];
    
    imageView = [[UIImageView alloc] init];
    imageView.image = self.image;
    imageView.tintColor = [UIColor lightGrayColor];
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView addSubview:imageView];
    
    labelTitle = [[UILabel alloc] init];
    labelTitle.text = self.messageTitle;
    labelTitle.translatesAutoresizingMaskIntoConstraints = NO;
    labelTitle.font = [UIFont boldSystemFontOfSize:20.0];
    labelTitle.textColor = [UIColor lightGrayColor];
    labelTitle.numberOfLines = 0;
    labelTitle.textAlignment = NSTextAlignmentCenter;
    [containerView addSubview:labelTitle];
    
    labelMessage = [[UILabel alloc] init];
    labelMessage.text = self.messageDescription;
    labelMessage.translatesAutoresizingMaskIntoConstraints = NO;
    labelMessage.font = [UIFont systemFontOfSize:13.0];
    labelMessage.textColor = [UIColor lightGrayColor];
    labelMessage.numberOfLines = 0;
    labelMessage.textAlignment = NSTextAlignmentCenter;
    [containerView addSubview:labelMessage];
    
    buttonAction = [UIButton buttonWithType:UIButtonTypeSystem];
    [buttonAction setTitle:self.buttonTitle forState:UIControlStateNormal];
    buttonAction.enabled = (self.buttonTitle.length != 0);
    buttonAction.translatesAutoresizingMaskIntoConstraints = NO;
    [buttonAction addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    buttonAction.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [containerView addSubview:buttonAction];
    
    //Constraint
    {
        NSLayoutConstraint *constraint11 = [NSLayoutConstraint constraintWithItem:activityIndicator attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:containerView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        
        NSLayoutConstraint *constraint12 = [NSLayoutConstraint constraintWithItem:activityIndicator attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:containerView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
        
        
        NSLayoutConstraint *constraint21 = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:activityIndicator attribute:NSLayoutAttributeBottom multiplier:1 constant:5];
        
        NSLayoutConstraint *constraint22 = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:activityIndicator attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
        
        
        NSLayoutConstraint *constraint31 = [NSLayoutConstraint constraintWithItem:labelTitle attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:imageView attribute:NSLayoutAttributeBottom multiplier:1 constant:5];
        
        NSLayoutConstraint *constraint32 = [NSLayoutConstraint constraintWithItem:labelTitle attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:containerView attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
        
        NSLayoutConstraint *constraint33 = [NSLayoutConstraint constraintWithItem:labelTitle attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:containerView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
        
        
        NSLayoutConstraint *constraint41 = [NSLayoutConstraint constraintWithItem:labelMessage attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:labelTitle attribute:NSLayoutAttributeBottom multiplier:1 constant:5];
        
        NSLayoutConstraint *constraint42 = [NSLayoutConstraint constraintWithItem:labelMessage attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:containerView attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
        
        NSLayoutConstraint *constraint43 = [NSLayoutConstraint constraintWithItem:labelMessage attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:containerView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
        
        
        NSLayoutConstraint *constraint51 = [NSLayoutConstraint constraintWithItem:buttonAction attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:labelMessage attribute:NSLayoutAttributeBottom multiplier:1 constant:15];
        
        NSLayoutConstraint *constraint52 = [NSLayoutConstraint constraintWithItem:buttonAction attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:containerView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
        
        NSLayoutConstraint *constraint53 = [NSLayoutConstraint constraintWithItem:buttonAction attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:containerView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        
        
        [containerView addConstraints:@[constraint11,constraint12,constraint21,constraint22,constraint31,constraint32,constraint33,constraint41,constraint42,constraint43,constraint51,constraint52,constraint53]];
    }
}

-(void)setAnimating:(BOOL)animating
{
    _animating = animating;
    
    if (animating)
    {
        [activityIndicator startAnimating];
    }
    else
    {
        [activityIndicator stopAnimating];
    }
}

-(void)setImage:(UIImage *)image
{
    _image = image;
    imageView.image = image;
}

-(void)setMessageTitle:(NSString *)messageTitle
{
    _messageTitle = messageTitle;
    labelTitle.text = messageTitle;
}

-(void)setMessageDescription:(NSString *)messageDescription
{
    _messageDescription = messageDescription;
    labelMessage.text = messageDescription;
}

-(void)setButtonTitle:(NSString *)buttonTitle
{
    _buttonTitle = buttonTitle;
    [buttonAction setTitle:buttonTitle forState:UIControlStateNormal];
    buttonAction.enabled = (buttonTitle.length != 0);
}

-(void)buttonAction:(UIButton*)button
{
    if ([self.delegate respondsToSelector:@selector(noContentViewControllerDidTapOnButton:)])
    {
        [self.delegate noContentViewControllerDidTapOnButton:self];
    }
}

@end
