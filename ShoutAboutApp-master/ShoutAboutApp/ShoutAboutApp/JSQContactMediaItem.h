//
//  JSQContactMediaItem.h
//  Pods
//
//  Created by VIRENDRA GUPTA on 10/06/17.
//
//

#import <JSQMessagesViewController/JSQMessages.h>


@interface JSQContactMediaItem : JSQMediaItem <JSQMessageMediaData, NSCoding, NSCopying>

@property (copy, nonatomic) NSString *string;
@property (assign) BOOL isAddToContact;

- (instancetype)initWithString:(NSString *)string;

@end
