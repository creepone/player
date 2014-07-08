#import <DropboxSDK/DropboxSDK.h>
#import "PLDropboxPathAsset.h"

@interface PLDropboxPathAsset() {
    DBMetadata *_metadata;
    PLDropboxPathAsset *_parent;
}
@end

@implementation PLDropboxPathAsset

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

- (DBMetadata *)metadata
{
    return _metadata;
}

- (NSString *)path
{
    return _metadata ? _metadata.path : @"/";
}

- (id<PLPathAsset>)parent
{
    return _parent;
}

@end