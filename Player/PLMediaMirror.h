#import <Foundation/Foundation.h>

extern NSString * const PLMediaMirrorFinishedTrackNofitication;

@interface PLMediaMirror : NSObject

+ (PLMediaMirror *)sharedInstance;

/**
 Delivers YES if a process of mirroring a track is currently active, NO otherwise.
*/
- (BOOL)isActive;

/**
* Ensures that the process of mirroring a track will be started, if not already the cases.
*/
- (void)ensureActive;

/**
 Suspends the mirroring of the tracks so that no further tracks processing will be started after the 
 current one is finished (if any). If you subscribe to the PLMediaMirrorFinishedTrackNofitication notification, you can call this method
 in the handler and make sure no further work will be done.
 */
- (void)suspend;

@end
