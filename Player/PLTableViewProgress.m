#import "PLTableViewProgress.h"
#import "PLProgressTableViewCell.h"

@interface PLTableViewProgress() <UITableViewDataSource, UITableViewDelegate> {
    UITableView *_tableView;
    UIView *_originalFooterView;
    BOOL _originalScrollEnabled;
    __weak id<UITableViewDataSource> _originalDataSource;
    __weak id<UITableViewDelegate> _originalDelegate;
    CGFloat _originalRowHeight;
}

@end

@implementation PLTableViewProgress

- (instancetype)initWithTableView:(UITableView *)tableView
{
    self = [super init];
    if (self) {
        _originalScrollEnabled = tableView.scrollEnabled;
        _originalDataSource = tableView.dataSource;
        _originalDelegate = tableView.delegate;
        _originalRowHeight = tableView.rowHeight;
        _originalFooterView = tableView.tableFooterView;
        _tableView = tableView;
    }
    return self;
}

+ (PLTableViewProgress *)showInTableView:(UITableView *)tableView
{
    return [self showInTableView:tableView afterGraceTime:0.4];
}

+ (PLTableViewProgress *)showInTableView:(UITableView *)tableView afterGraceTime:(NSTimeInterval)graceTime
{
    // already showing in the given table view
    if ([tableView.delegate isKindOfClass:[PLTableViewProgress class]])
        return (PLTableViewProgress *)tableView.delegate;
    
    PLTableViewProgress *progress = [[PLTableViewProgress alloc] initWithTableView:tableView];
    [progress showIn:graceTime];
    return progress;
}


- (void)showIn:(NSTimeInterval)graceTime
{
    @weakify(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, graceTime * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        @strongify(self);
        
        if (!self)
            return;
        
        UITableView *tableView = self->_tableView;
        
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.scrollEnabled = NO;
        tableView.rowHeight = 98.f;
        
        // remove the extra separators under the table view
        tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        
        [tableView reloadData];
    });
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[PLProgressTableViewCell alloc] init];
}

- (void)dealloc
{
    _tableView.scrollEnabled = _originalScrollEnabled;
    _tableView.delegate = _originalDelegate;
    _tableView.dataSource = _originalDataSource;
    _tableView.rowHeight = _originalRowHeight;
    _tableView.tableFooterView = _originalFooterView;
}

@end
