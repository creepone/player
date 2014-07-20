#import <ReactiveCocoa/ReactiveCocoa.h>
#import <RaptureXML/RXMLElement.h>
#import "PLNetworkManager.h"

@interface PLNetworkManager() {
    NSURLSession *_session;
}

@end

@implementation PLNetworkManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:configuration delegate:nil delegateQueue:[NSOperationQueue new]];
    }
    return self;
}

- (RACSignal *)getJSONFromURL:(NSURL *)url
{
    return [[[self getDataFromURL:url] flattenMap:^RACStream*(NSData *data) {
        NSError *error;
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        return error ? [RACSignal error:error] : [RACSignal return:json];
    }] deliverOn:[RACScheduler mainThreadScheduler]];
}

- (RACSignal *)getXMLFromURL:(NSURL *)url
{
    return [[[self getDataFromURL:url] map:^id(NSData *data) {
        return [RXMLElement elementFromXMLData:data];
    }] deliverOn:[RACScheduler mainThreadScheduler]];
}

- (RACSignal *)getImageFromURL:(NSURL *)url
{
    return [[[self getDataFromURL:url] map:^id(NSData *data) {
        return [UIImage imageWithData:data];
    }] deliverOn:[RACScheduler mainThreadScheduler]];
}

- (RACSignal *)getDataFromURL:(NSURL *)url
{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSURLSessionDataTask *task = [_session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error) {
                [subscriber sendError:error];
                return;
            }
            
            [subscriber sendNext:data];
            [subscriber sendCompleted];
        }];
        
        [task resume];

        return [RACDisposable disposableWithBlock:^{
            if (task.state == NSURLSessionTaskStateRunning)
                [task cancel];
        }];
    }];
}

@end
