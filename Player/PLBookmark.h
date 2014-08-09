#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "PLEntity.h"
#import "PLTrackWithPosition.h"

@class PLTrack;

@interface PLBookmark : PLEntity

@property (nonatomic, retain) NSDate *timestamp;
@property (nonatomic, retain) NSNumber *position;
@property (nonatomic, retain) PLTrack *track;

- (void)remove;

@end
