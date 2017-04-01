//
//  NJOnlinePageDrawView.h
//  NeoNotesMacOS
//

#import "NJPageZoomView.h"

@interface NJOnlinePageDrawView : NJPageZoomView
@property (nonatomic, readonly) CGFloat canvsRatio;
@property (nonatomic, readonly) CGPoint offset;

- (void) touchBeganX: (float)x_coordinate Y: (float)y_coordinate Pressure:(float)pressure PenColor:(NSColor *)pColor PenThickness:(NSUInteger)pThickness;
- (void) touchMovedX:(float)x_coordinate Y:(float)y_coordinate Pressure:(float)pressure;
- (void) strokeUpdated;
- (void) calculateSizes;
@end
