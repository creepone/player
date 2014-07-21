@class MPMediaItem;

typedef BOOL (^PLPredicate)(id);

@interface PLUtils : NSObject

/**
 Returns YES if the given object is either nil or equal to [NSNull null].
 */
+ (BOOL)isNilOrNull:(NSObject *)object;

/**
 Attempts to dismiss keyboard if being shown currently.
 */
+ (void)dismissKeyboard;

+ (NSString *)documentDirectoryPath;

+ (NSString *)libraryDirectoryPath;

+ (NSString *)formatDuration:(NSTimeInterval)duration;

+ (NSString *)fileNameFromURL:(NSURL *)url;

/**
* Returns the suffix of the given absolute URL as seen from the Documents folder. If the given URL
* is not located under the Documents folder, nil is returned.
*/
+ (NSString *)pathFromDocuments:(NSURL *)absoluteURL;

/**
* Returns an absolute URL based in the Documents folder, continuing with the given relative path.
*/
+ (NSURL *)URLUnderDocuments:(NSString *)relativePath;

/**
 Uses a workaround to deliver the launch image of the application without duplicating it in the asset catalog.
 For dubious reasons, the launch image does not behave in the same way as ordinary images and requesting it with
 imageNamed: doesn't take the resolution and screen size into account.
 */
+ (UIImage *)launchImage;

+ (PLPredicate)isNotNilPredicate;
+ (PLPredicate)isTruePredicate;
+ (PLPredicate)isFalsePredicate;

+ (NSString *)generateUuid;

@end
