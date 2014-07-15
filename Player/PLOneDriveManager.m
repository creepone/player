#import <ReactiveCocoa/ReactiveCocoa.h>
#import "LiveSDK/LiveConnectClient.h"
#import "PLOneDriveManager.h"
#import "PLOneDrivePathAsset.h"
#import "PLUtils.h"
#import "NSArray+PLExtensions.h"

@interface PLOneDriveManager() <LiveAuthDelegate, LiveOperationDelegate> {
    LiveConnectClient *_client;
    NSArray *_scopes;
}

@property (nonatomic, strong) RACReplaySubject *authSubject;
@property (nonatomic, assign) BOOL isLinked;

@end

static NSString *kSchemePrefix = @"onedrive+";
static NSString *kClientID = @"000000004C12140D";

@implementation PLOneDriveManager

+ (PLOneDriveManager *)sharedManager
{
    static dispatch_once_t once;
    static PLOneDriveManager *sharedManager;
    dispatch_once(&once, ^ { sharedManager = [[self alloc] init]; });
    return sharedManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.authSubject = [RACReplaySubject replaySubjectWithCapacity:1];
        
        _scopes = @[@"wl.signin", @"wl.skydrive", @"wl.offline_access"];
        _client = [[LiveConnectClient alloc] initWithClientId:kClientID scopes:_scopes delegate:self userState:self.authSubject];
    }
    return self;
}


- (RACSignal *)link
{
    if (_client == nil)
        _client = [[LiveConnectClient alloc] initWithClientId:kClientID scopes:_scopes delegate:self userState:self.authSubject];
    
    return [[self.authSubject take:1] flattenMap:^RACStream *(NSNumber *authenticated) {
        if (![authenticated boolValue]) {
            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
                [_client login:rootViewController delegate:self userState:subscriber];
                return nil;
            }];
        }
        
        return [RACSignal return:@(YES)];
    }];
}

- (RACSignal *)unlink
{
    return [[self.authSubject take:1] flattenMap:^RACStream *(NSNumber *authenticated) {
        if ([authenticated boolValue]) {
            [_client logout];
            _client = nil;
            self.authSubject = [RACReplaySubject replaySubjectWithCapacity:1];
        }
        
        self.isLinked = NO;
        return nil;
    }];
}


- (id <PLPathAsset>)rootAsset
{
    return [[PLOneDrivePathAsset alloc] initWithInfo:nil parent:nil];
}

- (RACSignal *)loadChildren:(id <PLPathAsset>)asset
{
    PLOneDrivePathAsset *driveAsset = (PLOneDrivePathAsset *)asset;
    
    RACSubject *subject = [RACSubject subject];
    [_client getWithPath:driveAsset.identifier delegate:self userState:subject];
    
    return [subject flattenMap:^RACStream *(NSDictionary *result) {
        
        if (result[@"data"]) {
            NSArray *items = [[result[@"data"] pl_filter:^BOOL(NSDictionary *info, NSUInteger idx) {
                NSString *type = info[@"type"];
                return [type isEqual:@"folder"] || [type isEqual:@"audio"];
            }] pl_map:^id(NSDictionary *info) {
                return [[PLOneDrivePathAsset alloc] initWithInfo:info parent:driveAsset];
            }];
            return [RACSignal return:items];
        }

        return nil;
    }];
}

- (NSURL *)downloadURLForAsset:(id <PLPathAsset>)asset
{
    PLOneDrivePathAsset *driveAsset = (PLOneDrivePathAsset *)asset;
    NSString *downloadURL = driveAsset.info[@"source"];
    
    NSURLComponents *components = [NSURLComponents componentsWithString:downloadURL];
    components.scheme = [NSString stringWithFormat:@"%@%@", kSchemePrefix, components.scheme];
    return [components URL];
}

- (RACSignal *)requestForDownloadURL:(NSURL *)downloadURL
{
    if (![downloadURL.scheme hasPrefix:kSchemePrefix])
        return nil;
    
    NSURLComponents *components = [NSURLComponents componentsWithURL:downloadURL resolvingAgainstBaseURL:NO];
    components.scheme = [components.scheme substringFromIndex:[kSchemePrefix length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:components.URL];

    [request setValue:[NSString stringWithFormat:@"bearer %@", _client.session.accessToken] forHTTPHeaderField:@"Authorization"];
    
    return [RACSignal return:request];
}


#pragma mark -- Delegate methods

- (void)authCompleted:(LiveConnectSessionStatus)status session:(LiveConnectSession *)session userState:(id)userState
{
    BOOL isAuthenticated = session != nil;
    self.isLinked = isAuthenticated;
    
    id<RACSubscriber> subscriber = (id<RACSubscriber>)userState;
    [subscriber sendNext:@(isAuthenticated)];
    [subscriber sendCompleted];
}

- (void)authFailed:(NSError *)error userState:(id)userState
{
    self.isLinked = NO;
    
    id<RACSubscriber> subscriber = (id<RACSubscriber>)userState;
    [subscriber sendError:error];
}

- (void)liveOperationSucceeded:(LiveOperation *)operation
{
    id<RACSubscriber> subscriber = (id<RACSubscriber>)operation.userState;
    [subscriber sendNext:operation.result];
    [subscriber sendCompleted];
}

- (void)liveOperationFailed:(NSError *)error operation:(LiveOperation*)operation
{
    id<RACSubscriber> subscriber = (id<RACSubscriber>)operation.userState;
    [subscriber sendError:error];
}

- (NSString *)clientSecret
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    // env. variable, used in the local dev environment
    NSString *envVariable = [[[NSProcessInfo processInfo] environment] objectForKey:@"ONEDRIVE_SECRET"];
    if (envVariable != nil) {
        [userDefaults setObject:envVariable forKey:@"ONEDRIVE_SECRET"];
        [userDefaults synchronize];
        return envVariable;
    }
    
    // setting, used when running a locally built version without passing the envvar
    NSString *setting = [userDefaults objectForKey:@"ONEDRIVE_SECRET"];
    if (setting != nil)
        return setting;
    
    // bundle variable, used for the build
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"OneDriveSecret"];
}

@end
