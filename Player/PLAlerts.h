#import <Foundation/Foundation.h>

@interface PLAlerts : NSObject

/**
 Checks whether the given error is non-nil and if that's the case displays an alerts with a generic 
 load data error. Should be used for errors returned from a query execution.
 Returns YES for nil error, NO for non-nil error.
 */
+ (BOOL)checkForDataLoadError:(NSError *)error;

/**
 Checks whether the given error is non-nil and if that's the case displays an alerts with a generic 
 store data error. Should be used for errors returned from a query execution.
 Returns YES for nil error, NO for non-nil error.
 */
+ (BOOL)checkForDataStoreError:(NSError *)error;


+ (void)displayInfoText:(NSString *)text;
+ (void)displayErrorText:(NSString *)text;

@end
