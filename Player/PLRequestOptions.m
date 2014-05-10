#import "PLRequestOptions.h"

@implementation PLRequestOptions

- (id)init
{
    self = [super init];
    if (self) {
        self.headers = [NSMutableDictionary dictionary];
        self.parameters = [NSMutableDictionary dictionary];
        self.urlArguments = [NSMutableArray array];
    }
    return self;
}

@end