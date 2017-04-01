//
//  NJGlobalFunctionsTable.h
//  NeoNotesMacOS
//

#import <Cocoa/Cocoa.h>
typedef enum {
    GFUNC_TAGS,
    GFUNC_BACKUPRESTORE
} gFunctions;

@protocol NJGlobalFunctionHandler
- (void) globalFunctionChanged:(NSInteger) index;
@end

@interface NJGlobalFunctionsTable : NSTableView <NSTableViewDataSource, NSTableViewDelegate>
@property (weak) id <NJGlobalFunctionHandler> functionHandler;
@end
