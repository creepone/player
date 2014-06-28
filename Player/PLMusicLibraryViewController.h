@class RACSignal;

@interface PLMusicLibraryViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *selection;

- (RACSignal *)doneSignal;

@end
