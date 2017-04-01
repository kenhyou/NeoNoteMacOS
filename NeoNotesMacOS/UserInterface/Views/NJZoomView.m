//
//  NJZoomView.m
//  NeoNotesMacOS
//

#import "NJZoomView.h"

@implementation NJZoomView

#pragma mark -

- (void)zoomIn
{
    [self zoomViewByFactor:2.0];
}

- (void)zoomOut
{
    [self zoomViewByFactor:0.5];
}

- (void)zoomToActualSize
{
    [self zoomViewToAbsoluteScale:1.0];
}
- (void)zoomFitInWindow
{
    NSRect sfr = [[self superview] frame];
    [self zoomViewToFitRect:sfr];
}
- (void)zoomFitInWindowWidth
{
    NSRect sfr = [[self superview] frame];
    NSRect fr = [self frame];
    CGFloat sx = sfr.size.width / fr.size.width;
    [self zoomViewByFactor:sx];
}

- (void)zoomToPercentage:(CGFloat)percent
{
    [self zoomViewToAbsoluteScale:percent];
}

- (void)zoomMax
{
    [self zoomViewToAbsoluteScale:[self maximumScale]];
}

- (void)zoomMin
{
    [self zoomViewToAbsoluteScale:[self minimumScale]];
}

#pragma mark -
- (void)zoomViewByFactor:(CGFloat)factor
{
    NSPoint p = [self centredPointInDocView];
    [self zoomViewByFactor:factor
            andCentrePoint:p];
}
- (void)zoomViewToAbsoluteScale:(CGFloat)newScale
{
    [self setScale:newScale];
}

- (void)zoomViewToFitRect:(NSRect)aRect
{
    NSRect fr = [self frame];
    
    CGFloat sx, sy;
    
    sx = aRect.size.width / fr.size.width;
    sy = aRect.size.height / fr.size.height;
    
    [self zoomViewByFactor:MIN(sx, sy)];
}
- (void)zoomViewToRect:(NSRect)aRect
{
    NSRect fr = [(NSClipView*)[self superview] documentVisibleRect];
    NSPoint cp;
    
    CGFloat sx, sy;
    
    sx = fr.size.width / aRect.size.width;
    sy = fr.size.height / aRect.size.height;
    
    cp.x = aRect.origin.x + aRect.size.width / 2.0;
    cp.y = aRect.origin.y + aRect.size.height / 2.0;
    
    [self zoomViewByFactor:MIN(sx, sy)
            andCentrePoint:cp];
}
- (void)zoomViewByFactor:(CGFloat)factor andCentrePoint:(NSPoint)p
{
    if (factor != 1.0) {
        [self setScale:[self scale] * factor];
        [self scrollPointToCentre:p];
    }
}
- (void)zoomWithScrollWheelDelta:(CGFloat)delta toCentrePoint:(NSPoint)cp
{
    CGFloat factor = (delta > 0) ? 0.9 : 1.1;
    
    [self zoomViewByFactor:factor
            andCentrePoint:cp];
}

#pragma mark -
- (NSPoint)centredPointInDocView
{
    NSRect fr;
    
    if ([[self superview] respondsToSelector:@selector(documentVisibleRect)])
        fr = [(NSClipView*)[self superview] documentVisibleRect];
    else
        fr = [self visibleRect];
    
    return NSMakePoint(NSMidX(fr), NSMidY(fr));
}
- (void)scrollPointToCentre:(NSPoint)aPoint
{
    NSRect fr;
    
    if ([[self superview] respondsToSelector:@selector(documentVisibleRect)])
        fr = [(NSClipView*)[self superview] documentVisibleRect];
    else
        fr = [self visibleRect];
    
    NSPoint sp;
    
    sp.x = aPoint.x - (fr.size.width / 2.0);
    sp.y = aPoint.y - (fr.size.height / 2.0);
    
    [self scrollPoint:sp];
}
- (void)scrollWheel:(NSEvent*)theEvent
{
    NSScrollView* scroller = [self enclosingScrollView];
    
    if (scroller != nil && ([theEvent modifierFlags] & NSEventModifierFlagControl)) {
        
        NSPoint p = [self centredPointInDocView];
        CGFloat delta = [theEvent deltaY];
        
        [self zoomWithScrollWheelDelta:delta
                         toCentrePoint:p];
    } else
        [super scrollWheel:theEvent];
}

#pragma mark -
- (void)setScale:(CGFloat)sc
{
    if (sc < [self minimumScale])
        sc = [self minimumScale];
    
    if (sc > [self maximumScale])
        sc = [self maximumScale];
    
    if (sc != [self scale]) {
//        [self startScaleChange]; // stop is called by retriggerable timer
        
        NSSize newSize;
        NSRect fr;
        CGFloat factor = sc / [self scale];
        
//        [[NSNotificationCenter defaultCenter] postNotificationName:kDKDrawingViewWillChangeScale
//                                                            object:self];
        mScale = sc;
        fr = [self frame];
        
        newSize.width = newSize.height = factor;
        
        [self scaleUnitSquareToSize:newSize];
        
        fr.size.width *= factor;
        fr.size.height *= factor;
        [self setFrameSize:fr.size];
        [self setNeedsDisplay:YES];
        
        
//        [[NSNotificationCenter defaultCenter] postNotificationName:kDKDrawingViewDidChangeScale
//                                                            object:self];
    }
}
- (CGFloat)scale
{
    return mScale;
}

- (BOOL)isChangingScale
{
    return mIsChangingScale;
}

- (void)setMinimumScale:(CGFloat)scmin
{
    mMinScale = scmin;
}

- (CGFloat)minimumScale
{
    return mMinScale;
}

- (void)setMaximumScale:(CGFloat)scmax
{
    mMaxScale = scmax;
}

- (CGFloat)maximumScale
{
    return mMaxScale;
}

#pragma mark -
#pragma mark Init
- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil) {
        mScale = 1.0;
        mMinScale = 0.025;
        mMaxScale = 250.0;
        [self setWantsLayer:YES];
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)coder
{
    if ((self = [super initWithCoder:coder])) {
        if ([self respondsToSelector:@selector(setTranslatesAutoresizingMaskIntoConstraints:)]) {
            [self setTranslatesAutoresizingMaskIntoConstraints:YES];
        }
        
        mScale = 1.0;
        mMinScale = 0.025;
        mMaxScale = 250.0;
        [self setWantsLayer:YES];
        
    }
    return self;
}
#pragma mark -
#pragma mark As an NSView
- (BOOL)isFlipped
{
    return YES;
}

- (BOOL)isOpaque
{
    return YES;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void) drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    //[super drawLayer:layer inContext:ctx];
}

@end
