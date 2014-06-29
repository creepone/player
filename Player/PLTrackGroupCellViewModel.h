#import <Foundation/Foundation.h>

@class PLMediaItemTrackGroup;

@interface PLTrackGroupCellViewModel : NSObject

@property (strong, nonatomic, readonly) UIImage *imageArtwork;
@property (strong, nonatomic, readonly) UIImage *imageAddState;
@property (strong, nonatomic, readonly) NSString *titleText;
@property (strong, nonatomic, readonly) NSString *artistText;
@property (strong, nonatomic, readonly) NSAttributedString *infoText;
@property (assign, nonatomic, readonly) CGFloat alpha;

- (instancetype)initWithTrackGroup:(PLMediaItemTrackGroup *)trackGroup selected:(BOOL)selected;

@end