//
//  NJOnlinePageViewController.m
//  NeoNotesMacOS
//
#import "NJAppDelegate.h"
#import "NJOnlinePageViewController.h"
//#import "NJOnlinePageScrollView.h"
#import "NJOnlinePageDrawView.h"
#import "NJNode.h"
#import "NJVoiceManager.h"

extern NSString * NJPenCommParserPageChangedNotification;

@interface NJOnlinePageViewController () <NJPenCommParserPasswordDelegate, NJPenCommParserStrokeHandler>
@property (strong, nonatomic) NJVoiceManager *voiceManager;

@property (nonatomic) BOOL firstEntry;
@property (nonatomic) NSColor * penColor;
@property (nonatomic) NSUInteger penThickness;
@end

@implementation NJOnlinePageViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.appDelegate.onliePageViewController = self;
    // Do view setup here.
    [[NJPenCommManager sharedInstance] setPenCommParserPasswordDelegate:self];
    [[NJPenCommManager sharedInstance] setPenCommParserStrokeHandler:self];

    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(handlePageChangedNotification:) name:NJPenCommParserPageChangedNotification object:nil];
}

- (void)screenInitialSetup
{
    if(self.notebookUuid == nil || self.pageNum == 0) return;
    
    [[NJPenCommManager sharedInstance] setPenCommParserStrokeHandler:self];
    [self.onlinePageDrawView setNotebookUuid:self.notebookUuid pageNum:self.pageNum];
    [self.onlinePageDrawView calculateSizes];
}

- (NJVoiceManager *) voiceManager
{
    if (_voiceManager == nil) {
        _voiceManager = [NJVoiceManager sharedInstance];
    }
    
    return _voiceManager;
}

- (void) newPageLoaded
{
    [self screenInitialSetup];
}
- (void)showCanvasView
{
    NJNotebookWriterManager *writer = [NJNotebookWriterManager sharedInstance];
    
    NSString *notebookUuid = writer.activeNotebookUuid;
    NSUInteger pageNumber = writer.activePageNumber;
    self.pageNum = pageNumber;
    self.notebookUuid = notebookUuid;
    [self newPageLoaded];
}

#pragma mark - Notification Handlers
- (void)handlePageChangedNotification:(NSNotification *)notification
{
    [self showCanvasView];
}

#pragma mark - NJPenCommParserPasswordDelegate
-(void) performComparePassword:(PenPasswordRequestStruct *)request
{
//    int resetCount = (int)request->resetCount;
//    int retryCount = (int)request->retryCount;
//    int count = resetCount - retryCount - 1;
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Please enter password."];
    [alert addButtonWithTitle:@"Ok"];
    [alert addButtonWithTitle:@"Cancel"];
    
    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
    [input setStringValue:@""];
    
    [alert setAccessoryView:input];
    NSInteger button = [alert runModal];
    if (button == NSAlertFirstButtonReturn) {
        NSString *password = [input stringValue];
        [[NJPenCommManager sharedInstance] setBTComparePassword:password];
    } else if (button == NSAlertSecondButtonReturn) {
        
    }
}
#pragma mark - NNPenCommParserStrokeHandler
- (void) processStroke:(NSDictionary *)stroke
{
    static BOOL penDown = NO;
    static BOOL startNode = NO;
    
    NSString *type = [stroke objectForKey:@"type"];
    if ([type isEqualToString: @"stroke"]) {
        
        if (_firstEntry) {
            _firstEntry = NO;
        }
        
        if (penDown == NO) return;
        
        NJNode *node = [stroke objectForKey:@"node"];
        float x = node.x;
        float y = node.y;
        float p = node.pressure;
        
        if (startNode == NO) {
            [self.onlinePageDrawView touchMovedX: x Y: y Pressure: p];
        } else {
            [self.onlinePageDrawView touchBeganX: x Y: y Pressure: p PenColor:self.penColor PenThickness:self.penThickness];
            startNode = NO;
        }
        
    } else if ([type isEqualToString: @"updown"]) {
        
        NSString *status = [stroke objectForKey:@"status"];
        
        if ([status isEqualToString:@"down"]) {
            
            penDown = YES;
            startNode = YES;
            
        } else {
            _firstEntry = YES;
            penDown = NO;
            [self.onlinePageDrawView strokeUpdated];
        }
    }
}
- (void)notifyPageChanging
{
    //self.pageCanvas.pageChanging = YES;
}
- (void)notifyDataUpdating:(BOOL)updating
{
    //   self.pageCanvas.dataUpdating = updating;
}

- (UInt32)setPenColor
{
    return [NJUtilities convertUIColorToAlpahRGB:self.penColor];
}
#pragma mark - User Controlls
- (void) pageZoomIn
{
    [self.onlinePageDrawView zoomIn];
}
- (void) pageZoomOut
{
    [self.onlinePageDrawView zoomOut];
}
- (void) fitToWindowWidth
{
    [self.onlinePageDrawView zoomFitInWindowWidth];
}
- (void) fitPageToWindow
{
    [self.onlinePageDrawView zoomFitInWindow];
}
@end
