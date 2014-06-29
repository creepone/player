#import <Foundation/Foundation.h>

@class RACSignal;

@interface PLFileImport : NSObject

+ (RACSignal *)importFile:(NSURL *)fileURL;

/**
* Moves the given (temporary) file into the documents directory.
* Returns a signal that delivers the new NSURL of the file and completes.
*/
+ (RACSignal *)moveToDocumentsFolder:(NSURL *)fileURL;

/**
 * Moves the given (temporary) file into the documents directory, under the given new file name.
 * Returns a signal that delivers the new NSURL of the file and completes.
 */
+ (RACSignal *)moveToDocumentsFolder:(NSURL *)fileURL underFileName:(NSString *)fileName;

@end
