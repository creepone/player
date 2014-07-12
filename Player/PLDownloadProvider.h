#import <Foundation/Foundation.h>

@class RACSignal;

@protocol PLDownloadProvider <NSObject>

- (RACSignal *)requestForDownloadURL:(NSURL *)downloadURL;

@end
