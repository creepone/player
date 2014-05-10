@interface UIViewController (PLErrorExtensions)

/**
 Presents the error message for a given error in this view controller. If the error is of a globally
 registered type, a corresponding message will be shown. Otherwise, a default message is used.
 */
- (void)pl_presentError:(NSError *)error;

/**
 Presents the error message for a given error in this view controller. If the error is of a globally
 registered type, a corresponding message will be shown. Otherwise, the given defaultMessage is used.
 */
- (void)pl_presentError:(NSError *)error defaultMessage:(NSString *)defaultMessage;

@end