#import <DDLog.h>

#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

@interface PLLogging : NSObject

/**
 Sets up the logging for the whole application. This should be called in the applicationDidFinishLaunching method.
 */
+ (void)setupLogging;

/**
 Archives all the log files into a single zip file.
 @return The full path to the generated zip archive.
 */
+ (NSString *)archiveLogs;

@end