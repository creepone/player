#import "PLBackgroundProcessProgress.h"
#import "RACSignal.h"

@interface PLBackgroundProcessProgress()

@property (strong, nonatomic, readwrite) id item;
@property (strong, nonatomic, readwrite) RACSignal *progressSignal;

@end

@implementation PLBackgroundProcessProgress

- (instancetype)initWithItem:(id)item progressSignal:(RACSignal *)progressSignal
{
    self = [super init];
    if (self) {
        self.item = item;
        self.progressSignal = progressSignal;
    }
    return self;
}

@end