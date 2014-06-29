#import <Foundation/Foundation.h>

@class PLMediaItemTrack;

@interface PLTrackCellViewModel : NSObject

@property (strong, nonatomic, readonly) NSString *titleText;
@property (strong, nonatomic, readonly) NSString *durationText;
@property (strong, nonatomic, readonly) UIImage *imageAddState;
@property (assign, nonatomic, readonly) CGFloat alpha;

- (instancetype)initWithTrack:(PLMediaItemTrack *)track selected:(BOOL)selected;

@end
