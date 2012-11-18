#import "PLAlerts.h"

@interface PLAlerts()

+ (BOOL)checkForError:(NSError *)error withTitle:(NSString *)title message:(NSString *)message;

@end

@implementation PLAlerts

+ (BOOL)checkForDataLoadError:(NSError *)error {
    return [self checkForError:error 
                     withTitle:@"Error"
                       message:@"There was an error loading the data."];
}

+ (BOOL)checkForDataStoreError:(NSError *)error {
    return [self checkForError:error 
                     withTitle:@"Error"
                       message:@"There was an error saving the data."];
}


+ (void)displayInfoText:(NSString *)text {	
	UIAlertView *alert = [[UIAlertView alloc] 
						  initWithTitle:@"Info"
						  message:text
						  delegate:self
						  cancelButtonTitle:@"OK" 
						  otherButtonTitles:nil];
	
	[alert show];
}

+ (void)displayErrorText:(NSString *)text {	
	UIAlertView *alert = [[UIAlertView alloc] 
						  initWithTitle:@"Error"
						  message:text
						  delegate:self
						  cancelButtonTitle:@"OK" 
						  otherButtonTitles:nil];
	
	[alert show];
}


+ (BOOL)checkForError:(NSError *)error withTitle:(NSString *)title message:(NSString *)message {
    if(error == nil)
        return YES;
    
    NSLog(@"error %@", [error localizedDescription]);

	UIAlertView *alert = [[UIAlertView alloc] 
						  initWithTitle:title
						  message:message
						  delegate:nil
						  cancelButtonTitle:@"OK" 
						  otherButtonTitles:nil];
	
	[alert show];
    
    return NO;
}

@end
