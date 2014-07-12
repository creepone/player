#import <ReactiveCocoa/ReactiveCocoa.h>
#import <Google-API-Client/GTLDrive.h>
#import <gtm-oauth2/GTMOAuth2ViewControllerTouch.h>
#import "PLGDriveManager.h"
#import "PLErrorManager.h"

@interface PLGDriveManager() {
    GTLServiceDrive *_driveService;
}

@end

static NSString *kKeychainItemName = @"GoogleDriveCredentials";
static NSString *kClientID = @"210955112623-cqjrd6qt7d1fgl9fvclct69kgrtjd2nu.apps.googleusercontent.com";

@implementation PLGDriveManager

+ (PLGDriveManager *)sharedManager
{
    static dispatch_once_t once;
    static PLGDriveManager *sharedManager;
    dispatch_once(&once, ^ { sharedManager = [[self alloc] init]; });
    return sharedManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        NSString *secret = [self clientSecret];
        DDLogInfo(@"Google Drive Secret = %@", secret);
        
        _driveService = [[GTLServiceDrive alloc] init];
        _driveService.shouldFetchNextPages = YES;
        _driveService.authorizer = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName clientID:kClientID clientSecret:[self clientSecret]];
    }
    return self;
}

- (BOOL)isLinked
{
    return [((GTMOAuth2Authentication *)_driveService.authorizer) canAuthorize];
}

- (RACSignal *)link
{
    if (self.isLinked)
        return [RACSignal return:@(YES)];
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        @weakify(self);
        __block BOOL wasCancelled;
        
        GTMOAuth2ViewControllerTouch *authController = [[GTMOAuth2ViewControllerTouch alloc] initWithScope:kGTLAuthScopeDrive
            clientID:kClientID  clientSecret:[self clientSecret] keychainItemName:kKeychainItemName
            completionHandler:^(GTMOAuth2ViewControllerTouch *viewController, GTMOAuth2Authentication *auth, NSError *error) { @strongify(self);
                if (!self) return;
                
                BOOL isLinked;
                
                if (error != nil) {
                    [PLErrorManager logError:error];
                    self->_driveService.authorizer = nil;
                    isLinked = NO;
                }
                else {
                    self->_driveService.authorizer = auth;
                    isLinked = YES;
                }
                
                if (wasCancelled)
                    return;
                
                UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
                [rootViewController dismissViewControllerAnimated:YES completion:^{
                    [subscriber sendNext:@(isLinked)];
                    [subscriber sendCompleted];
                }];
            }];
        
        UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:authController];
        
        authController.navigationItem.title = @"Sign in"; // todo: localize
        
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:nil action:nil];
        cancelButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            wasCancelled = YES;
            [[[[UIApplication sharedApplication] keyWindow] rootViewController] dismissViewControllerAnimated:YES completion:^{
                [subscriber sendNext:@(NO)];
                [subscriber sendCompleted];
            }];
            return [RACSignal empty];
        }];
        
        authController.navigationItem.leftBarButtonItem = cancelButton;
        
        [rootViewController presentViewController:navigationController animated:YES completion:nil];
        
        return nil;
    }];
}

- (void)unlink
{
    if (!self.isLinked)
        return;
    
    [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:kKeychainItemName];
}


- (NSURLRequest *)requestForPath:(NSString *)filePath
{
    // todo: implement
    return nil;
}

- (RACSignal *)listFolder:(NSString *)path
{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        GTLQueryDrive *query = [GTLQueryDrive queryForChildrenListWithFolderId:path];
        
        // todo: set mime types to the query so that only audio files are loaded
        
        [_driveService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLDriveChildList *files, NSError *error) {
            if (error != nil) {
                [subscriber sendError:error];
                return;
            }
            
            [subscriber sendNext:files];
            [subscriber sendCompleted];
        }];
        
        return nil;
    }];
}


- (NSString *)clientSecret
{
#if DEBUG
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    // env. variable, used in the local dev environment
    NSString *envVariable = [[[NSProcessInfo processInfo] environment] objectForKey:@"GDRIVE_SECRET"];
    if (envVariable != nil) {
        [userDefaults setObject:envVariable forKey:@"GDRIVE_SECRET"];
        [userDefaults synchronize];
        return envVariable;
    }
    
    // setting, used when running a locally built version without passing the envvar
    NSString *setting = [userDefaults objectForKey:@"GDRIVE_SECRET"];
    if (setting != nil)
        return setting;
#endif
    
    // bundle variable, used for the build
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"GDriveSecret"];
}

@end
