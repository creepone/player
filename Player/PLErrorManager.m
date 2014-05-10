#import <TSMessage.h>
#import "PLErrorManager.h"

NSString * const PLErrorDomain = @"Player";

@implementation PLErrorManager

+ (void)presentError:(NSError *)error inViewController:(UIViewController *)viewController defaultMessage:(NSString *)defaultMessage
{
    NSString *message = defaultMessage;
    TSMessageNotificationType notificationType = TSMessageNotificationTypeError;

    // todo: extract these to an "error factory"

    if ([self isConnectionError:error]) {
        message = NSLocalizedString(@"Messages.ConnectionLost", nil);
        notificationType = TSMessageNotificationTypeWarning;
    }

    [TSMessage showNotificationInViewController:viewController title:message subtitle:nil type:notificationType];
}

+ (void)logError:(NSError *)error
{
    DDLogError(@"%@", [error localizedDescription]);

    if (error.userInfo != nil)
    DDLogError(@"%@", [error.userInfo description]);
}

+ (PLErrorHandler)logErrorBlock
{
    return ^(NSError *error) {
        [self logError:error];
        return (id)nil;
    };
}

+ (NSError *)errorWithDescription:(NSString *)localizedDescription
{
    return [self errorWithCode:0 description:localizedDescription];
}

+ (NSError *)errorWithCode:(NSInteger)code description:(NSString *)localizedDescription
{
    NSDictionary *details = @{ NSLocalizedDescriptionKey: localizedDescription };
    return [NSError errorWithDomain:PLErrorDomain code:code userInfo:details];
}

+ (NSError *)errorFromError:(NSError *)error withAdditionalInfo:(NSDictionary *)userInfo
{
    NSMutableDictionary *mergedInfo = [error.userInfo mutableCopy];
    [mergedInfo addEntriesFromDictionary:userInfo];
    return [NSError errorWithDomain:error.domain code:error.code userInfo:mergedInfo];
}

+ (BOOL)isConnectionError:(NSError *)error
{
    if (![error.domain isEqualToString:NSURLErrorDomain])
        return NO;

    switch (error.code) {
        case NSURLErrorTimedOut:
        case NSURLErrorCannotFindHost:
        case NSURLErrorCannotConnectToHost:
        case NSURLErrorNetworkConnectionLost:
        case NSURLErrorDNSLookupFailed:
        case NSURLErrorResourceUnavailable:
        case NSURLErrorNotConnectedToInternet:
        case NSURLErrorInternationalRoamingOff:
            return YES;
    }

    return NO;
}

@end
