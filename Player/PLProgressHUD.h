#import <Foundation/Foundation.h>

@interface PLProgressHUD : NSObject

+ (RACDisposable *)showWithStatus:(NSString *)status;

@end
