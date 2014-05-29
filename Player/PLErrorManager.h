typedef NS_ENUM(NSInteger, MGErrorCodes) {
    PLErrorMappingModelNotFound = 1
};

typedef id(^PLErrorHandler)(NSError *);

/**
 Common error domain for all player errors.
 */
extern NSString * const PLErrorDomain;

@interface PLErrorManager : NSObject

/**
 Presents the error message for a given error in the given view controller. If the error is of a globally
 registered type, a corresponding message will be shown. Otherwise, the defaultMessage is used.
 */
+ (void)presentError:(NSError *)error inViewController:(UIViewController *)viewController defaultMessage:(NSString *)defaultMessage;

/**
 Writes the given error into the log.
 */
+ (void)logError:(NSError *)error;

/**
 Convenience method returning a block that calls the logError: method.
 */
+ (PLErrorHandler)logErrorBlock;

/**
 Delivers a new NSError instance whose localizedDescription method returns the given string.
 */
+ (NSError *)errorWithDescription:(NSString *)localizedDescription;

/**
 Delivers a new NSError instance with a given code whose localizedDescription method returns the given string.
 */
+ (NSError *)errorWithCode:(NSInteger)code description:(NSString *)localizedDescription;

/**
 Delivers a new NSError instance with the same domain and code as the given error, with all the data from the given 
 userInfo dictionary added to the original userInfo of the given error.
 */
+ (NSError *)errorFromError:(NSError *)error withAdditionalInfo:(NSDictionary *)userInfo;

/**
 Determines whether the given error is a network connection error.
 */
+ (BOOL)isConnectionError:(NSError *)error;

@end