//
//  NJGlobalFunctionsTable.m
//  NeoNotesMacOS
//

#import "NJGlobalFunctionsTable.h"


@interface NJGlobalFunctionsTable()
@property (strong, nonatomic) NSArray *globalFunctions;

@end

@implementation NJGlobalFunctionsTable

- (NSArray *) globalFunctions
{
    if(_globalFunctions == nil) {
        _globalFunctions = @[@"Tags", @"Backup & Restore"];
    }
    return _globalFunctions;
}
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [self setDataSource:self];
    [self setDelegate:self];
}

#pragma mark - NSTableViewDataSource
- (NSInteger) numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.globalFunctions.count;
}
- (nullable id)tableView:(NSTableView *)tableView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row
{
    __block NSImage *image = nil;
    image = [NSImage imageNamed:@"book cover_unknown@2x.png"];
    
    NSString *columnIdentifer = [tableColumn identifier];
    if([columnIdentifer isEqualToString:@"gFunctionCellImage"]){
        return image;
    }
    else if([columnIdentifer isEqualToString:@"gFunctionCellText"]){
        return [self.globalFunctions objectAtIndex:row];
    }
    
    return nil;
}

#pragma mark - NSTableViewDelegate
- (NSView *) tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSString *columnIdentifer = [tableColumn identifier];
    if([columnIdentifer isEqualToString:@"gFunctionCellImage"]){
        NSImageView *imageView = [[NSImageView alloc] init];
        return imageView;
    }
    else if([columnIdentifer isEqualToString:@"gFunctionCellText"]){
        NSTextField *textView = [[NSTextField alloc] init];
        return textView;
    }
    
    return nil;
}
- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    NSInteger row = [self selectedRow];
    if(row == GFUNC_TAGS){
        
    }
    else {
        
    }
    [self.functionHandler globalFunctionChanged:row];
}
- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    return 35.0;
}
@end
