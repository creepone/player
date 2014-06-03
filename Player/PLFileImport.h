#import <Foundation/Foundation.h>
@class RXPromise;

@interface PLFileImport : NSObject

+ (RXPromise *)importFile:(NSURL *)fileURL;

@end
