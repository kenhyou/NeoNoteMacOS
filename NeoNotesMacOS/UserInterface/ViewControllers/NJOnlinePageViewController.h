//
//  NJOnlinePageViewController.h
//  NeoNotesMacOS
//


#import <Cocoa/Cocoa.h>
#import "NJViewController.h"

@class NJOnlinePageDrawView;

@interface NJOnlinePageViewController : NJViewController
@property (weak) IBOutlet NJOnlinePageDrawView *onlinePageDrawView;

@property (nonatomic) NSUInteger notebookId;
@property (nonatomic,strong) NSString *notebookUuid;
@property (nonatomic, strong) NSString *matchWord;
@property (nonatomic) NSUInteger pageNum;
//@property (nonatomic, strong) NJOnlinePageScrollView *pageContentView;

- (void) newPageLoaded;
- (void) pageZoomIn;
- (void) pageZoomOut;
- (void) fitToWindowWidth;
- (void) fitPageToWindow;
@end
