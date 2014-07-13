#import <DropboxSDK/DropboxSDK.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "DBRestClient+RACSignalSupport.h"
#import "MPOAuthURLRequest.h"
#import "PLDropboxManager.h"
#import "PLPathAssetSet.h"
#import "PLDropboxPathAsset.h"
#import "NSArray+PLExtensions.h"

NSString * const PLDropboxURLHandledNotification = @"PLDropboxURLHandledNotification";

@interface PLDropboxManager()
@end

static NSString *kAppKey = @"rqjkvshiflgy2qj";

@implementation PLDropboxManager

+ (PLDropboxManager *)sharedManager
{
    static dispatch_once_t once;
    static PLDropboxManager *sharedManager;
    dispatch_once(&once, ^ { sharedManager = [[self alloc] init]; });
    return sharedManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        DBSession *session = [[DBSession alloc] initWithAppKey:kAppKey appSecret:[self clientSecret] root:kDBRootDropbox];
        [DBSession setSharedSession:session];
    }
    return self;
}

- (BOOL)isLinked
{
    return [[DBSession sharedSession] isLinked];
}

- (RACSignal *)link
{
    if (self.isLinked)
        return [RACSignal return:@(YES)];

    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        [[DBSession sharedSession] linkFromController:window.rootViewController];
        
        [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:PLDropboxURLHandledNotification object:nil] take:1] subscribeNext:^(id _) {
            
            BOOL isLinked =  [[DBSession sharedSession] isLinked];
            
            UIViewController *rootViewController = window.rootViewController;
            UIViewController *presentedViewController = [rootViewController presentedViewController];
            
            // wait for the Dropbox authentication view controller (if present) to disappear before we complete the signal
            
            RACSignal *cleanupSignal = [RACSignal empty];
            if (presentedViewController != nil) {
                cleanupSignal = presentedViewController.rac_willDeallocSignal;
            }
            
            [cleanupSignal subscribeCompleted:^{
                [subscriber sendNext:@(isLinked)];
                [subscriber sendCompleted];
            }];
        }];
        
        return nil;
    }];
}

- (RACSignal *)unlink
{
    if (self.isLinked)
        [[DBSession sharedSession] unlinkAll];
    return [RACSignal empty];
}


- (id <PLPathAsset>)rootAsset
{
    return [PLDropboxPathAsset assetWithMetadata:nil parent:nil];
}

- (RACSignal *)loadChildren:(id <PLPathAsset>)asset
{
    DBRestClient *restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    
    return [[restClient rac_loadMetadataSignal:asset.path] map:^(DBMetadata *metadata) {
        return [metadata.contents pl_map:^id(DBMetadata *metadata) {
            return [PLDropboxPathAsset assetWithMetadata:metadata parent:asset];
        }];
    }];
}


- (RACSignal *)requestForDownloadURL:(NSURL *)downloadURL
{
    if (![downloadURL.scheme isEqualToString:@"dropbox"])
        return nil;
    
    NSString *filePath = downloadURL.path;
    DBSession *session = [DBSession sharedSession];
    if (![session isLinked])
        return nil;
    
    NSString *escapedPath = [filePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString* urlString = [NSString stringWithFormat:@"https://api-content.dropbox.com/1/files/dropbox%@", escapedPath];
    NSURL* url = [NSURL URLWithString:urlString];
    
    NSString *userId = session.userIds[0];
    MPOAuthCredentialConcreteStore *credentialStore = [session credentialStoreForUserId:userId];
    
    NSArray *paramList = [credentialStore oauthParameters];
	
    MPOAuthURLRequest* oauthRequest = [[MPOAuthURLRequest alloc] initWithURL:url andParameters:paramList];
    
    NSMutableURLRequest* urlRequest = [oauthRequest
									   urlRequestSignedWithSecret:credentialStore.signingKey
									   usingMethod:credentialStore.signatureMethod];
    return [RACSignal return:urlRequest];
    
}

- (NSURL *)downloadURLForAsset:(id <PLPathAsset>)asset
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"dropbox://%@", [asset.path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
}


- (NSString *)clientSecret
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    // env. variable, used in the local dev environment
    NSString *envVariable = [[[NSProcessInfo processInfo] environment] objectForKey:@"DROPBOX_SECRET"];
    if (envVariable != nil) {
        [userDefaults setObject:envVariable forKey:@"DROPBOX_SECRET"];
        [userDefaults synchronize];
        return envVariable;
    }
    
    // setting, used when running a locally built version without passing the envvar
    NSString *setting = [userDefaults objectForKey:@"DROPBOX_SECRET"];
    if (setting != nil)
        return setting;

    // bundle variable, used for the build
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"DropboxSecret"];
}

@end
