#import <Foundation/Foundation.h>

@class RACSignal;

@interface PLBackgroundProcessProgress : NSObject

- (instancetype)initWithItem:(id)item progressSignal:(RACSignal *)progressSignal;

@property (strong, nonatomic, readonly) id item;
@property (strong, nonatomic, readonly) RACSignal *progressSignal;

@end