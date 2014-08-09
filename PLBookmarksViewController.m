#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PLBookmarksViewController.h"
#import "PLBookmarksViewModel.h"
#import "PLBookmarkCell.h"
#import "PLBookmarkCellViewModel.h"
#import "UITableView+PLExtensions.h"
#import "PLErrorManager.h"

@interface PLBookmarksViewController()

- (IBAction)tappedDone:(id)sender;

@end

@implementation PLBookmarksViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupBindings];
}

- (void)setupBindings
{
    @weakify(self);
    [self.viewModel.updatesSignal subscribeNext:^(NSArray *updates) { @strongify(self);
        [self.tableView pl_applyUpdates:updates];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.viewModel bookmarksCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PLBookmarkCell *cell = [tableView dequeueReusableCellWithIdentifier:@"bookmarkCell"];
    PLBookmarkCellViewModel *viewModel = [self.viewModel bookmarkViewModelAt:indexPath];
    cell.viewModel = viewModel;
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView isEditing] ? UITableViewCellEditingStyleNone : UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PLBookmarkCell *cell = (PLBookmarkCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell.viewModel selectCell];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[self.viewModel removeBookmarkAt:indexPath] subscribeError:[PLErrorManager logErrorVoidBlock]
              completed:^{
                  [self.tableView reloadData];
              }];
    }
}

- (IBAction)tappedDone:(id)sender
{
    [self.viewModel dismiss];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
