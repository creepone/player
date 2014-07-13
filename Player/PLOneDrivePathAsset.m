#import "PLOneDrivePathAsset.h"

@interface PLOneDrivePathAsset() {
    NSDictionary *_info;
    PLOneDrivePathAsset *_parent;
}

@end

@implementation PLOneDrivePathAsset

@synthesize siblings;

- (instancetype)initWithInfo:(NSDictionary *)info parent:(PLOneDrivePathAsset *)parent
{
    self = [super init];
    if (self) {
        _parent = parent;
        _info = info;
    }
    return self;
}

+ (instancetype)assetWithInfo:(NSDictionary *)info parent:(PLOneDrivePathAsset *)parent
{
    return [[self alloc] initWithInfo:info parent:parent];
}


- (NSString *)path
{
    return _parent == nil ? @"root" : [NSString stringWithFormat:@"%@/%@", _parent.path, _info[@"id"]];
}

- (NSString *)identifier
{
    if (_parent == nil)
        return @"me/skydrive/files";
    
    return [NSString stringWithFormat:@"%@/files", _info[@"id"]];
}

- (NSDictionary *)info
{
    return _info;
}

- (NSString *)title
{
    return _info[@"name"];
}

- (id<PLPathAsset>)parent
{
    return _parent;
}

- (BOOL)isRoot
{
    return _parent == nil;
}

- (BOOL)isDirectory
{
    return [_info[@"id"] hasPrefix:@"folder."];
}

@end
