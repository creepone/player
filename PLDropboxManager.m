#import <DropboxSDK/DropboxSDK.h>
#import "MPOAuthURLRequest.h"
#import "PLDropboxManager.h"

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
        
        NSString *dropboxSecret = [self dropboxSecret];
        DDLogInfo(@"Dropbox secret = %@", dropboxSecret);
        
        DBSession *session = [[DBSession alloc] initWithAppKey:@"rqjkvshiflgy2qj" appSecret:dropboxSecret root:kDBRootDropbox];
         
        [DBSession setSharedSession:session];

        if (![session isLinked]) {
            // todo: extract to PLRouter

            UIWindow *window = [[UIApplication sharedApplication] keyWindow];
            [session linkFromController:window.rootViewController];

            // todo: complete the signal at this point, we will have to be reinvoked when the authentication is done
        }
    }
    return self;
}

- (NSURL *)downloadURLForPath:(NSString *)filePath
{
    DBSession *session = [DBSession sharedSession];
    
    // todo: escape filePath
    NSString* urlString = [NSString stringWithFormat:@"https://api-content.dropbox.com/1/files/dropbox%@",filePath];
    NSURL* url = [NSURL URLWithString:urlString];
		
    NSString *userId = session.userIds[0];
    MPOAuthCredentialConcreteStore *credentialStore = [session credentialStoreForUserId:userId];
    
    NSArray *paramList = [credentialStore oauthParameters];
	
    MPOAuthURLRequest* oauthRequest = [[MPOAuthURLRequest alloc] initWithURL:url andParameters:paramList];
    
    NSMutableURLRequest* urlRequest = [oauthRequest
									   urlRequestSignedWithSecret:credentialStore.signingKey
									   usingMethod:credentialStore.signatureMethod];
	
    return [urlRequest URL];
    
}

- (NSString *)dropboxSecret
{
    // env. variable, used in the local dev environment
    NSString *envVariable = [[[NSProcessInfo processInfo] environment] objectForKey:@"DROPBOX_SECRET"];
    if (envVariable != nil)
        return envVariable;

    // bundle variable, used for the build
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"DropboxSecret"];
}

@end
