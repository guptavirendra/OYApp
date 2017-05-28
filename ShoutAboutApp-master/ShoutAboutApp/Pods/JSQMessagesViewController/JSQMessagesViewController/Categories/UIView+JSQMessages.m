//
//  Created by Jesse Squires
//  http://www.jessesquires.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSQMessagesViewController
//
//
//  GitHub
//  https://github.com/jessesquires/JSQMessagesViewController
//
//
//  License
//  Copyright (c) 2014 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "UIView+JSQMessages.h"

@implementation UIView (JSQMessages)

- (void)jsq_pinSubview:(UIView *)subview toEdge:(NSLayoutAttribute)attribute
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:attribute
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:subview
                                                     attribute:attribute
                                                    multiplier:1.0f
                                                      constant:0.0f]];
}
- (void)jsq_pinSubview:(UIView *)subview toEdge:(NSLayoutAttribute)attribute andAnother: (UIView *)subview1 toEdge:(NSLayoutAttribute)attribute
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:subview
                                                     attribute:attribute
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:subview1
                                                     attribute:attribute
                                                    multiplier:1.0f
                                                      constant:0.0f]];
    
    [subview addConstraint:[NSLayoutConstraint constraintWithItem:subview
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0f
                                                      constant:50.0f]];
    [subview1 addConstraint:[NSLayoutConstraint constraintWithItem:subview1
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:1.0f
                                                         constant:50.0f]];
}

- (void)jsq_allignSubView:(UIView *)subview andNextSubView:(UIView *)subview1
{
    
    [self jsq_pinSubview:subview toEdge:NSLayoutAttributeTrailing andAnother:subview1 toEdge:NSLayoutAttributeLeading];
}

- (void)jsq_pinLeftEdgesOfSubview:(UIView *)subview
{
    [self jsq_pinSubview:subview toEdge:NSLayoutAttributeBottom];
    [self jsq_pinSubview:subview toEdge:NSLayoutAttributeTop];
    [self jsq_pinSubview:subview toEdge:NSLayoutAttributeLeading];
    //[self jsq_pinSubview:subview toEdge:NSLayoutAttributeTrailing];
}

- (void)jsq_pinAllEdgesOfSubview:(UIView *)subview
{
    [self jsq_pinSubview:subview toEdge:NSLayoutAttributeBottom];
    [self jsq_pinSubview:subview toEdge:NSLayoutAttributeTop];
    [self jsq_pinSubview:subview toEdge:NSLayoutAttributeLeading];
    [self jsq_pinSubview:subview toEdge:NSLayoutAttributeTrailing];
}

@end
