#import <Foundation/Foundation.h>

@class RACSignal;

@protocol PLActivity <NSObject>

/**
* The image of the icon to be shown in the activity view.
*/
- (UIImage *)image;

/**
* The title to be shown under the icon in the activity view.
*/
- (NSString *)title;

/**
* Asynchronously performs whatever logic this activity entails.
* Returns a signal that completes when the activity has completed.
*/
- (RACSignal *)performActivity;

@optional

/**
* The image of the icon to be shown in the activity view when highlighted.
*/
- (UIImage *)highlightedImage;

@end