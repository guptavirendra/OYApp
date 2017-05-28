//
//  ChatAsyncPhotoMedia.h
//  
//
//  Created by VIRENDRA GUPTA on 28/05/17.
//
//

//#import <JSQMessagesViewController/JSQMessagesViewController.h>
#import <JSQMessagesViewController/JSQMessages.h>

@interface ChatAsyncPhotoMedia :JSQAudioMediaItem

@property (nonatomic, strong) UIImageView *asyncImageView;

- (instancetype)initWithURL:(NSURL *)URL;

@end