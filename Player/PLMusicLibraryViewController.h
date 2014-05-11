typedef void (^PLMusicLibrarySelectionHandler)(NSArray *);

@interface PLMusicLibraryViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *selection;
@property (nonatomic, copy) PLMusicLibrarySelectionHandler doneCallback;

@end
