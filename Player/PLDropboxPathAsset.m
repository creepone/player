#import <DropboxSDK/DropboxSDK.h>
#import "PLDropboxPathAsset.h"

@interface PLDropboxPathAsset() {
    DBMetadata *_metadata;
    PLDropboxPathAsset *_parent;
}
@end

@implementation PLDropboxPathAsset

@synthesize siblings;

- (instancetype)initWithMetadata:(DBMetadata *)metadata parent:(PLDropboxPathAsset *)parent
{
    self = [super init];
    if (self) {
        _metadata = metadata;
        _parent = parent;
    }
    return self;
}

+ (instancetype)assetWithMetadata:(DBMetadata *)metadata parent:(PLDropboxPathAsset *)parent
{
    return [[self alloc] initWithMetadata:metadata parent:parent];
}

- (NSString *)path
{
    return _metadata ? _metadata.path : @"/";
}

- (NSString *)fileName
{
    return [_metadata.path lastPathComponent];
}

- (id<PLPathAsset>)parent
{
    return _parent;
}

- (BOOL)isRoot
{
    return _metadata == nil;
}

- (BOOL)isDirectory
{
    return _metadata == nil || _metadata.isDirectory;
}

@end
