#import <Foundation/Foundation.h>

@protocol PLPathAsset;

@protocol PLDownloadProvider <NSObject>

- (NSURLRequest *)requestForDownloadURL:(NSURL *)downloadURL;
- (NSURL *)downloadURLForAsset:(id <PLPathAsset>)asset;

@end
