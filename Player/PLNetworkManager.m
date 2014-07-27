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

- (RACSignal *)imageFromURL:(NSURL *)imageURL
{
    return [[[self getDataFromURL:imageURL] map:^id(id value) { return [UIImage imageWithData:value];}] deliverOn:[RACScheduler mainThreadScheduler]];
}

- (RACSignal *)getDataFromURL:(NSURL *)url
{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        __block NSURLSessionDataTask *task;
        
        RACDisposable *schedulerDisposable = [[RACScheduler scheduler] schedule:^{
            task = [_session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                if (error) {
                    [subscriber sendError:error];
                    return;
                }
                
                [subscriber sendNext:data];
                [subscriber sendCompleted];
            }];
            
            [task resume];
        }];
        
        RACDisposable *taskDisposable = [RACDisposable disposableWithBlock:^{
            if (task && task.state == NSURLSessionTaskStateRunning)
                [task cancel];
        }];
        
        return [RACCompoundDisposable compoundDisposableWithDisposables:@[schedulerDisposable, taskDisposable]];
    }];
}

@end
