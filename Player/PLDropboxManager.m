#import <DropboxSDK/DropboxSDK.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "DBRestClient+RACSignalSupport.h"
#import "MPOAuthURLRequest.h"
#import "PLDropboxManager.h"

NSString * const PLDropboxURLHandledNotification = @"PLDropboxURLHandledNotification";

@interface PLDropboxManager()
@end

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
        DBSession *session = [[DBSession alloc] initWithAppKey:@"rqjkvshiflgy2qj" appSecret:[self dropboxSecret] root:kDBRootDropbox];
        [DBSession setSharedSession:session];
    }
    return self;
}


- (BOOL)isLinked
{
    return [[DBSession sharedSession] isLinked];
}


- (BOOL)ensureLinked
{
    DBSession *session = [DBSession sharedSession];
    
    if (![session isLinked]) {
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        [session linkFromController:window.rootViewController];
        return NO;
    }
    
    return YES;
}

- (void)unlink
{
    [[DBSession sharedSession] unlinkAll];
}


- (RACSignal *)listFolder:(NSString *)path
{
    DBRestClient *restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    
    return [[restClient rac_loadMetadataSignal:path] map:^(DBMetadata *metadata) {
        return metadata.contents;
    }];
}


- (NSURLRequest *)requestForPath:(NSString *)filePath
{
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
    return urlRequest;
}

- (NSString *)dropboxSecret
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
