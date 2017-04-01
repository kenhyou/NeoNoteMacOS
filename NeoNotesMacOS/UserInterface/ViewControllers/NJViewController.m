//
//  NJViewController.m
//  NeoNotesMacOS
//

#import "NJViewController.h"

@interface NJViewController ()

@end

@implementation NJViewController

- (NJAppDelegate *) appDelegate
{
    if(!_appDelegate){
        _appDelegate = (NJAppDelegate *)[[NSApplication sharedApplication] delegate];
    }
    return _appDelegate;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

@end
