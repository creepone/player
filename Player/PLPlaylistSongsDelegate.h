#import <Foundation/Foundation.h>

@interface PLPlaylistSongsDelegate : NSObject <UITableViewDataSource, UITableViewDelegate>

- (instancetype)initWithTableView:(UITableView *)tableView;

@end