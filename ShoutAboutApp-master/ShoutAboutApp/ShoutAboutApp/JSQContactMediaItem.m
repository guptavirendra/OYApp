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

- (CGSize)mediaViewDisplaySize
{
    return CGSizeMake(210.0f, 100.0f);
}

- (UIView *)mediaView
{
    if (self.string == nil) {
        return nil;
    }
    
    if (self.baseView == nil)
    {
        CGSize size = [self mediaViewDisplaySize];
        
        NSArray* stringArray = [self.string componentsSeparatedByString:@"-"];
        
        UIView* baseview = [[UIView alloc] init];
        
        baseview.backgroundColor = [UIColor  colorWithRed:31.0/255.0 green:141.0/255.0 blue:200.0/255.0 alpha:1.0];
        baseview.frame = CGRectMake(0.0f, 0.0f, size.width, size.height);
        baseview.clipsToBounds = YES;
        
        
        UILabel* namelabel = [[UILabel alloc]init];
        namelabel.font = [UIFont systemFontOfSize:14];
        UILabel* mobilelabel = [[UILabel alloc]init];
        namelabel.frame = CGRectMake(52.0, 5.0f, size.width-50, 25);
        mobilelabel.font = [UIFont systemFontOfSize:14];
        mobilelabel.frame = CGRectMake(52.0f, 35.0f, size.width-50, 25);
        
        
        UILabel* messagelabel = [[UILabel alloc]init];
        messagelabel.frame = CGRectMake(5, 65.0f, size.width-10, 25);
        messagelabel.text  = self.isAddToContact ? @"Add to Contact" : @"View Contact";
        mobilelabel.font = [UIFont boldSystemFontOfSize:16];
        messagelabel.textAlignment = NSTextAlignmentCenter;
        namelabel.textColor = [UIColor  whiteColor];
        messagelabel.textColor = [UIColor  whiteColor];
        mobilelabel.textColor = [UIColor  whiteColor];
        
        if ( stringArray.count > 0) namelabel.text =  [stringArray objectAtIndex:0];
        if ( stringArray.count > 1) mobilelabel.text =  [stringArray objectAtIndex:1];
        
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"profile_user" ]];
        imageView.frame = CGRectMake(5.0f, 5.0f, 45, 45);
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        
        [baseview addSubview:imageView];
        [baseview addSubview:namelabel];

        [baseview addSubview:mobilelabel];
        [baseview addSubview:messagelabel];

        
        [JSQMessagesMediaViewBubbleImageMasker applyBubbleImageMaskToMediaView:baseview isOutgoing:self.appliesMediaViewMaskAsOutgoing];
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

