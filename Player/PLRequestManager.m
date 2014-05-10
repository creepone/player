#import <RXPromise/RXPromise.h>
#import "PLRequestManager.h"
#import "PLPromise.h"
#import "PLRequestOptions.h"
#import "AFHTTPSessionManager.h"
#import "PLErrorManager.h"
#import "NSString+PLExtensions.h"

@interface PLRequestManager() {
    AFHTTPSessionManager *_sessionManager;
}
@end

typedef void(^RequestCompletionBlock)(NSURLResponse *, id, NSError *);
typedef NSURL *(^RequestDestinationBlock)(NSURL *, NSURLResponse *);
typedef id(^ErrorHandlerBlock)(NSError *);

@implementation PLRequestManager

- (id)init
{
    self = [super init];
    if (self) {
        _sessionManager = [AFHTTPSessionManager manager];

        AFCompoundResponseSerializer *compoundSerializer = [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:@[[AFJSONResponseSerializer serializer], [AFHTTPResponseSerializer serializer]]];
        _sessionManager.responseSerializer = compoundSerializer;

    }
    return self;
}

+ (PLRequestManager *)sharedManager
{
    static dispatch_once_t once;
    static PLRequestManager *sharedManager;
    dispatch_once(&once, ^ { sharedManager = [[self alloc] init]; });
    return sharedManager;
}

- (RXPromise *)sendRequestWithOptions:(PLRequestOptions *)options
{
    NSError *error;
    NSURLRequest *request = [self requestFromOptions:options error:&error];

    if (error)
        return [RXPromise promiseWithResult:error];


    RXPromise *promise = [[RXPromise alloc] init];
    NSURLSessionDataTask *task = [_sessionManager dataTaskWithRequest:request
                                                    completionHandler:[self requestCompletionHandler:promise]];
    [task resume];
    return promise.then(nil, [self handleCancellationBlock:task]);
}

- (PLPromise *)downloadWithOptions:(PLRequestOptions *)options
{
    NSError *error;
    NSURLRequest *request = [self requestFromOptions:options error:&error];

    if (error)
        return [PLPromise promiseWithResult:error];


    PLPromise *promise = [[PLPromise alloc] init];
    NSProgress *progress;

    RequestDestinationBlock destination = ^(NSURL *targetPath, NSURLResponse *response) {
        return options.fileURL;
    };

    NSURLSessionDownloadTask *task = [_sessionManager downloadTaskWithRequest:request progress:&progress
                                                                  destination:destination
                                                            completionHandler:[self requestCompletionHandler:promise]];
    promise.progress = progress;
    [task resume];

    promise.then(nil, [self handleCancellationBlock:task]);

    return promise;
}


- (NSURLRequest *)requestFromOptions:(PLRequestOptions *)options error:(NSError **)error
{
    NSString *url = [options.urlArguments count] ? [NSString pl_stringWithFormat:options.url array:options.urlArguments] : options.url;

    NSDictionary *parameters = [options.parameters count] == 0 ? nil : options.parameters;
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:options.method URLString:url parameters:parameters error:error];

    if (*error)
        return nil;

    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    if (options.headers)
        [headers addEntriesFromDictionary:options.headers];
    if (options.cookies)
        [headers addEntriesFromDictionary:[NSHTTPCookie requestHeaderFieldsWithCookies:options.cookies]];

    // apply HTTP headers
    for (NSString *key in [headers allKeys])
        [request setValue:headers[key] forHTTPHeaderField:key];

    return request;
}

- (RequestCompletionBlock)requestCompletionHandler:(RXPromise *)promise
{
    return ^(NSURLResponse *response, id result, NSError *error) {
        if (!error) {
            [promise resolveWithResult:result];
            return;
        }

        if (response || result) {
            NSMutableDictionary *additionalInfo = [NSMutableDictionary dictionary];
            if (response)
                additionalInfo[@"response"] = response;
            if (result)
                additionalInfo[@"result"] = result;
            [promise rejectWithReason:[PLErrorManager errorFromError:error withAdditionalInfo:additionalInfo]];
        }
        else {
            [promise rejectWithReason:error];
        }
    };
}

- (ErrorHandlerBlock)handleCancellationBlock:(NSURLSessionTask *)task
{
    return ^id(NSError *error) {
        if (task.state == NSURLSessionTaskStateRunning || task.state == NSURLSessionTaskStateSuspended)
            [task cancel];
        return error;
    };

}

@end