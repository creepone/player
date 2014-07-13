#import <Google-API-Client/GTLDrive.h>
#import "PLGDrivePathAsset.h"

@interface PLGDrivePathAsset() {
    GTLDriveFile *_driveFile;
    PLGDrivePathAsset *_parent;
}
@end

@implementation PLGDrivePathAsset

@synthesize siblings;

- (instancetype)initWithDriveFile:(GTLDriveFile *)driveFile parent:(PLGDrivePathAsset *)parent
{
    self = [super init];
    if (self) {
        _driveFile = driveFile;
        _parent = parent;
    }
    return self;
}

+ (instancetype)assetWithDriveFile:(GTLDriveFile *)driveFile parent:(PLGDrivePathAsset *)parent
{
    return [[self alloc] initWithDriveFile:driveFile parent:parent];
}


- (NSString *)path
{
    return _parent == nil ? @"root" : [NSString stringWithFormat:@"%@/%@", _parent.path, _driveFile.identifier];
}

- (NSString *)title
{
    return _driveFile.title;
}

- (NSString *)identifier
{
    return _driveFile == nil ? @"root" : _driveFile.identifier;
}

- (GTLDriveFile *)driveFile
{
    return _driveFile;
}

- (id<PLPathAsset>)parent
{
    return _parent;
}

- (BOOL)isRoot
{
    return _driveFile == nil;
}

- (BOOL)isDirectory
{
    return _driveFile == nil || [_driveFile.mimeType isEqualToString:@"application/vnd.google-apps.folder"];
}

@end
