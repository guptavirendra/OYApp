#import "ChatAsyncPhotoMedia.h"
#import "UIColor+JSQMessages.h"
#import "JSQMessagesMediaPlaceholderView.h"
#import "UIImageView+WebCache.h"

@implementation ChatAsyncPhotoMedia

- (instancetype)init
{
    return [self initWithMaskAsOutgoing:YES];
}

- (instancetype)initWithURL:(NSURL *)URL
{
    self = [super init];
    if (self) {
        CGSize size = [self mediaViewDisplaySize];
        
        self.asyncImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        self.asyncImageView.contentMode = UIViewContentModeScaleToFill;
        self.asyncImageView.clipsToBounds = YES;
        self.asyncImageView.layer.cornerRadius = 20;
        self.asyncImageView.backgroundColor = [UIColor jsq_messageBubbleLightGrayColor];
        
        UIView *activityIndicator = [JSQMessagesMediaPlaceholderView viewWithActivityIndicator];
        activityIndicator.frame = self.asyncImageView.frame;
        
        [self.asyncImageView addSubview:activityIndicator];
        
        UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:URL.absoluteString];
        if(image == nil)
        {
            [self.asyncImageView sd_setImageWithURL:URL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (error == nil) {
                    [self.asyncImageView setImage:image];
                    [activityIndicator removeFromSuperview];
                } else {
                    NSLog(@"Image downloading error: %@", [error localizedDescription]);
                }
            }];
        } else {
            [self.asyncImageView setImage:image];
            [activityIndicator removeFromSuperview];
        }
    }
    
    return self;
}

#pragma mark - JSQMessageMediaData protocol
- (UIView *)mediaView
{
    return self.asyncImageView;
}

#pragma mark - NSCoding
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    NSLog(@"init coder has not been implemented");
    
    return self;
}

@end

