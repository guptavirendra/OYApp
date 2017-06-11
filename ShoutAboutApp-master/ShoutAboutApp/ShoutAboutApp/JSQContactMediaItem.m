//
//  JSQContactMediaItem.m
//  Pods
//
//  Created by VIRENDRA GUPTA on 10/06/17.
//
//

#import "JSQContactMediaItem.h"

@interface JSQContactMediaItem ()

@property (strong, nonatomic) UIView *baseView;


@end

 


@implementation JSQContactMediaItem

#pragma mark - Initialization

- (instancetype)initWithString:(NSString *)string;
{
    self = [super init];
    if (self) {
        _string = [string copy];
        _baseView = nil;
    }
    return self;
}

- (void)clearCachedMediaViews
{
    [super clearCachedMediaViews];
    _baseView = nil;
}

#pragma mark - Setters

-(void)setString:(NSString *)string
{
    _string = [string copy];
    _baseView = nil;

    
}

- (void)setAppliesMediaViewMaskAsOutgoing:(BOOL)appliesMediaViewMaskAsOutgoing
{
    [super setAppliesMediaViewMaskAsOutgoing:appliesMediaViewMaskAsOutgoing];
    _baseView = nil;
}

#pragma mark - JSQMessageMediaData protocol

- (UIView *)mediaView
{
    if (self.string == nil) {
        return nil;
    }
    
    if (self.baseView == nil) {
        CGSize size = [self mediaViewDisplaySize];
        
        NSArray* stringArray = [self.string componentsSeparatedByString:@"-"];
        
        UIView* baseview = [[UIView alloc] init];
        baseview.frame = CGRectMake(0.0f, 0.0f, size.width, size.height);
        baseview.clipsToBounds = YES;
        
        
        UILabel* namelabel = [[UILabel alloc]init];
        UILabel* mobilelabel = [[UILabel alloc]init];
        namelabel.frame = CGRectMake(35.0f, 0.0f, size.width-30, 25);
        mobilelabel.frame = CGRectMake(35.0f, 30.0f, size.width-30, 25);
        
        if ( stringArray.count > 0) namelabel.text =  [stringArray objectAtIndex:0];
        if ( stringArray.count > 1) mobilelabel.text =  [stringArray objectAtIndex:1];
        
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"" ]];
        imageView.frame = CGRectMake(0.0f, 0.0f, 30, 30);
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        
        [baseview addSubview:imageView];
        [baseview addSubview:namelabel];

        [baseview addSubview:mobilelabel];

        
        [JSQMessagesMediaViewBubbleImageMasker applyBubbleImageMaskToMediaView:imageView isOutgoing:self.appliesMediaViewMaskAsOutgoing];
        self.baseView = baseview;
        
    }
    
    return self.baseView;
}

- (NSUInteger)mediaHash
{
    return self.hash;
}

#pragma mark - NSObject

- (NSUInteger)hash
{
    return super.hash ^ self.string.hash;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: image=%@, appliesMediaViewMaskAsOutgoing=%@>",
            [self class], self.string, @(self.appliesMediaViewMaskAsOutgoing)];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _string = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(string))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.string forKey:NSStringFromSelector(@selector(string))];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    JSQContactMediaItem *copy = [[JSQContactMediaItem allocWithZone:zone] initWithString:self.string];
    copy.appliesMediaViewMaskAsOutgoing = self.appliesMediaViewMaskAsOutgoing;
    return copy;
}

@end

