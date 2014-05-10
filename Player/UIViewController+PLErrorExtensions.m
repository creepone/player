#import "UIViewController+PLErrorExtensions.h"
#import "PLErrorManager.h"

@implementation UIViewController (PLErrorExtensions)

- (void)pl_presentError:(NSError *)error
{
    [PLErrorManager presentError:error inViewController:self defaultMessage:NSLocalizedString(@"Messages.GeneralError", nil)];
}

- (void)pl_presentError:(NSError *)error defaultMessage:(NSString *)defaultMessage
{
    [PLErrorManager logError:error];
    [PLErrorManager presentError:error inViewController:self defaultMessage:defaultMessage];
}

@end