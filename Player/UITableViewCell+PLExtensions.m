#import "UITableViewCell+PLExtensions.h"

@implementation UITableViewCell (PLExtensions)

- (UITableView *)pl_tableView
{
    UIView *superview = [self superview];
    
    while (superview && ![superview isKindOfClass:[UITableView class]]) {
        superview = [superview superview];
    }
    
    return (UITableView *)superview;
}


@end
