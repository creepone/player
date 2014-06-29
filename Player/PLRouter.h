#import <Foundation/Foundation.h>

@interface PLRouter : NSObject

+ (void)showLegacy;

+ (void)showNew;

+ (RACSignal *)showTrackImport;

@end
