#import <Foundation/Foundation.h>

@interface PLRequestOptions : NSObject

#pragma mark -- Properties for options object

/**
 The URL string of the request.
 */
@property (nonatomic, strong) NSString *url;

/**
 An HTTP method (GET, POST, ...) to be used for the request.
 */
@property (nonatomic, strong) NSString *method;

/**
 The URL of a file to be uploaded or a destination for a file to be downloaded to.
 */
@property (nonatomic, strong) NSURL *fileURL;

/**
 A dictionary of HTTP headers to be applied to the request.
 */
@property (nonatomic, strong) NSMutableDictionary *headers;

/**
 A dictionary of parameters to be applied to the request. Depending on the method, these will be serialized as URL parameters or JSON properties of the root object.
 */
@property (nonatomic, strong) NSMutableDictionary *parameters;

/**
 An array of arguments that will be replaced in the configured url. The order should be as in the url format string.
 */
@property (nonatomic, strong) NSMutableArray *urlArguments;

/**
 An array of cookies to be used when constructing the request. The default is to use the shared HTTP cookie storage.
 */
@property (nonatomic, strong) NSArray *cookies;

@end