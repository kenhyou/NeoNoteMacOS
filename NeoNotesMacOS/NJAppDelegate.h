//
//  AppDelegate.h
//  NeoNotesMacOS
//

#import <Cocoa/Cocoa.h>

@class NJOnlinePageViewController;
@class NJPageViewController;
@class NJPageReplayViewController;
@class NJPageViewToolbarViewController;
@class NJNeoNoteViewController;

@interface NJAppDelegate : NSObject <NSApplicationDelegate>

@property (strong, nonatomic) NJOnlinePageViewController *onliePageViewController;
@property (strong, nonatomic) NJPageViewController *pageViewController;
@property (strong, nonatomic) NJPageReplayViewController *pageReplayViewController;
@property (strong, nonatomic) NJPageViewToolbarViewController *pageViewToolbarViewController;
@property (strong, nonatomic) NJNeoNoteViewController *neoNoteViewController;

@end

