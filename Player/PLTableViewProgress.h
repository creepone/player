#import <Foundation/Foundation.h>

@interface PLTableViewProgress : NSObject

/**
 Displays a progress indicator in the given table view by swapping its data source temporarily to one
 that has a single cell with the indicator in it. To stop showing the progress, release the given object.
 */
+ (PLTableViewProgress *)showInTableView:(UITableView *)tableView;

+ (PLTableViewProgress *)showInTableView:(UITableView *)tableView afterGraceTime:(NSTimeInterval)graceTime;

@end
