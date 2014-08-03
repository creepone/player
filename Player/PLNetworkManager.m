#import <ReactiveCocoa/ReactiveCocoa.h>
#import <RaptureXML/RXMLElement.h>
#import "PLNetworkManager.h"

@interface PLNetworkManager() {
    NSURLSession *_session;
    NSURLSession *_ephemeralSession;
}

@end

@implementation PLNetworkManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:configuration delegate:nil delegateQueue:[NSOperationQueue new]];
        
        NSURLSessionConfiguration *ephemeralConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        _ephemeralSession = [NSURLSession sessionWithConfiguration:ephemeralConfiguration delegate:nil delegateQueue:[NSOperationQueue new]];
        
    }
    return self;
}

- (RACSignal *)imageFromURL:(NSURL *)imageURL
{
    return [[[self getDataFromURL:imageURL] map:^id(id value) { return [UIImage imageWithData:value];}] deliverOn:[RACScheduler mainThreadScheduler]];
}

- (RACSignal *)getDataFromURL:(NSURL *)url
{
    return [self getDataFromURL:url useEphemeral:NO];
}

- (RACSignal *)getDataFromURL:(NSURL *)url useEphemeral:(BOOL)useEphemeral
{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        __block NSURLSessionDataTask *task;
        NSURLSession *session = useEphemeral ? _ephemeralSession : _session;
        
        RACDisposable *schedulerDisposable = [[RACScheduler scheduler] schedule:^{
            task = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
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
