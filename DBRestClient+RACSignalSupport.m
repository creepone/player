#import <ReactiveCocoa/ReactiveCocoa.h>
#import "RACDelegateProxy.h"
#import "DBRestClient+RACSignalSupport.h"

@implementation DBRestClient (RACSignalSupport)

static void RACUseDelegateProxy(DBRestClient *self)
{
	if (self.delegate == self.rac_delegateProxy) return;
    
	self.rac_delegateProxy.rac_proxiedDelegate = self.delegate;
	self.delegate = (id)self.rac_delegateProxy;
}

- (RACDelegateProxy *)rac_delegateProxy
{
	RACDelegateProxy *proxy = objc_getAssociatedObject(self, _cmd);
	if (proxy == nil) {
		proxy = [[RACDelegateProxy alloc] initWithProtocol:@protocol(DBRestClientDelegate)];
		objc_setAssociatedObject(self, _cmd, proxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
    
	return proxy;
}

- (RACSignal *)rac_loadMetadataSignal:(NSString *)path
{
    @weakify(self);
    RACSignal *workSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) { @strongify(self);
        [self loadMetadata:path];
        [subscriber sendCompleted];
        return nil;
    }];
    
    RACSignal *successSignal = [[self.rac_delegateProxy signalForSelector:@selector(restClient:loadedMetadata:)]
                                 reduceEach:^(id _, DBMetadata *metadata){ return metadata; }];
    
    RACSignal *errorSignal = [[[self.rac_delegateProxy signalForSelector:@selector(restClient:loadMetadataFailedWithError:)]
                              reduceEach:^(id _, NSError *error){ return error;}]
                              flattenMap:^RACStream *(NSError *error) { return [RACSignal error:error]; }];
    
	RACUseDelegateProxy(self);

    return [workSignal then:^RACSignal *{
        return [[[RACSignal merge:@[successSignal, errorSignal]] take:1] takeUntil:self.rac_willDeallocSignal];
    }];
}

@end
