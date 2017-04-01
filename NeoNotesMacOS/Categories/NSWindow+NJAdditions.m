//
//  NSWindow.m
//  NeoNotesMacOS
//

#import "NSWindow+NJAdditions.h"

@implementation NSWindow (NJAdditions)
- (BOOL)isFullscreen
{
    return ([self styleMask] & NSFullScreenWindowMask) == NSFullScreenWindowMask;
}
- (BOOL)drawAsActive
{
    return ([self isMainWindow] && [NSApp isActive]) || [self isFullscreen];
}
@end
