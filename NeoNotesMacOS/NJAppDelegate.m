//
//  AppDelegate.m
//  NeoNotesMacOS
//

#import "NJAppDelegate.h"
#import "NJPenCommManager.h"
#import "NPPaperManager.h"
#import "NJVoiceManager.h"
#import "NJNotebookReaderManager.h"
#import "NJOnlinePageViewController.h"

void ShowPopupMessage(NSString *title,NSString *msg)
{
    if(!title)
        title = @"";
}

@interface NJAppDelegate ()
@property (strong, nonatomic) NJPenCommManager *commManager;
@end

@implementation NJAppDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    self.commManager = [NJPenCommManager sharedInstance];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    NJNotebookReaderManager *mgr = [NJNotebookReaderManager sharedInstance];
    NSString *docPath = [mgr documentDirectory];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    [fm removeItemAtPath:docPath error:&error];
    
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

- (void)processStepInstallNewNotebookInfos
{

}
- (IBAction)btConnect:(id)sender {
    [self.commManager btStart];
}

- (IBAction)fitToWindowWidth:(id)sender {
    [self.onliePageViewController fitToWindowWidth];
}
- (IBAction)fitPageToWindow:(id)sender {
    [self.onliePageViewController fitPageToWindow];
}

@end
