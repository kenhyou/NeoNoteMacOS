//
//  NJZoomView.h
//  NeoNotesMacOS
//

#import <Cocoa/Cocoa.h>

@interface NJZoomView : NSView {
@protected
    CGFloat mScale; // the zoom scale of the view (1.0 = 100%)
    CGFloat mMinScale;
    CGFloat mMaxScale;
    NSUInteger mScrollwheelModifierMask;
    BOOL mIsChangingScale;
}
- (void)zoomIn;
- (void)zoomOut;
- (void)zoomFitInWindow;
- (void)zoomFitInWindowWidth;

- (void)scrollPointToCentre:(NSPoint)aPoint;
- (void) drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx;
@end
