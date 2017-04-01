//
//  NJPageZoomView.m
//  NeoNotesMacOS
//

#import "NJPageZoomView.h"
#import "NSColor+NJAdditions.h"
#import "NJNotebookPaperInfo.h"
#import "NJNotebookIdStore.h"
#import "NPPaperManager.h"

@implementation NJPageZoomView

+ (NSColor*)backgroundColour
{
    return [NSColor colorWithCalibratedRed:0.75
                                     green:0.75
                                      blue:0.8
                                     alpha:1.0];
}
#pragma mark -
#pragma mark window activations

- (void)windowActiveStateChanged:(NSNotification*)note
{
#pragma unused(note)
    
    if ([[self window] isMainWindow])
        [[self enclosingScrollView] setBackgroundColor:[[self class] backgroundColour]];
    else
        [[self enclosingScrollView] setBackgroundColor:[NSColor veryLightGrey]];
    NSLog(@" size of document view:%@", NSStringFromRect(self.frame));
    [self setNeedsDisplay:YES];
}

#pragma mark -
#pragma mark As part of NSNibAwaking Protocol
- (void)awakeFromNib
{
    NSScrollView* sv = [self enclosingScrollView];
    
    if (sv) {
        [sv setHasHorizontalRuler:YES];
        [sv setHasVerticalRuler:YES];
        
        
        [sv setDrawsBackground:YES];
        [sv setBackgroundColor:[[self class] backgroundColour]];
        
        [[sv horizontalRulerView] setClientView:self];
        [[sv horizontalRulerView] setReservedThicknessForMarkers:6.0];
        
        [[sv verticalRulerView] setClientView:self];
        [[sv verticalRulerView] setReservedThicknessForMarkers:6.0];
        
    }
    [self setFrame:CGRectMake(0, 0, 0, 0)];
    
    [[self window] setAcceptsMouseMovedEvents:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(windowActiveStateChanged:)
                                                 name:NSWindowDidResignMainNotification
                                               object:[self window]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(windowActiveStateChanged:)
                                                 name:NSWindowDidBecomeMainNotification
                                               object:[self window]];
    
}
#pragma mark -
#pragma mark PageZoomView
- (CGFloat)pageScale
{
    return mPageScale;
}
- (void)setPaperWidth:(CGFloat)width height:(CGFloat)height
{
    mPaperWidth = width;
    mPaperHeight = height;
}
- (void) resetZoomView
{
    mScale = 1;
    CGFloat sizeRatio = 1;
    NSRect sfr = [[self superview] frame];
    NSRect sfrOrg = sfr;
    if(mPaperWidth > mPaperHeight) {
        sizeRatio = sfr.size.width / mPaperWidth;
        sfr.size.width = mPaperWidth * sizeRatio;
        sfr.size.height = mPaperHeight * sizeRatio;
    }
    else {
        sizeRatio = sfr.size.height / mPaperHeight;
        sfr.size.width = mPaperWidth * sizeRatio;
        sfr.size.height = mPaperHeight * sizeRatio;
        sfr.origin.x = (sfrOrg.size.width - sfr.size.width)/2;
    }
    mPageScale = MAX(sfr.size.width, sfr.size.height);
    [self setFrame:sfr];
    [self scaleUnitSquareToSize:CGSizeMake(1.0, 1.0)];
}
#pragma mark -
#pragma mark As a NJPageDrawView
- (void)setNotebookUuid:(NSString *)notebookUuid pageNum:(NSUInteger)pageNumber
{
    mPage = [[NJNotebookReaderManager sharedInstance] getPageData:pageNumber notebookUuid:notebookUuid loadStrokes:YES];

    _pageWidth = 498;
    _pageHeight = 768;
    [self setPaperWidth:_pageWidth height:_pageHeight];
    [self resetZoomView];
    [self setNeedsDisplay:YES];
}
@end
