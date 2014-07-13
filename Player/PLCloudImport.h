#import <Foundation/Foundation.h>
#import "PLDownloadProvider.h"

@protocol PLPathAsset;
@class RACSignal;

@protocol PLCloudManager <NSObject, PLDownloadProvider>

- (BOOL)isLinked;
- (RACSignal *)link;
- (RACSignal *)unlink;

- (id <PLPathAsset>)rootAsset;
- (RACSignal *)loadChildren:(id <PLPathAsset>)asset;
- (NSURL *)downloadURLForAsset:(id <PLPathAsset>)asset;

@end

@interface PLCloudImport : NSObject

- (instancetype)initWithManager:(id<PLCloudManager>)manager;
- (RACSignal *)selectAndImport;

@end
