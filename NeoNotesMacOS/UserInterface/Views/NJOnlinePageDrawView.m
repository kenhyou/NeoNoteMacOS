//
//  NJOnlinePageDrawView.m
//  NeoNotesMacOS
//


#import "NJOnlinePageDrawView.h"
#import <Quartz/Quartz.h>
#import "NSBezierPath+BezierPathQuartzUtilities.h"
#import "NJStroke.h"

#define STROKE_NUMBER_MAGNITUDE 4
#define MAX_NODE (1024 * STROKE_NUMBER_MAGNITUDE)

@implementation NJOnlinePageDrawView
{
    NSColor *penColor;
    NSUInteger penThickness;
    
    float point_x[MAX_NODE];
    float point_y[MAX_NODE];
    float point_p[MAX_NODE];
    int time_diff[MAX_NODE];
    int point_count;
    
//    CGFloat canvasScale;
    CGFloat _normalizer;
    
    NSBezierPath *tempPath;
    // we now need to keep track of the four points of a Bezier segment and the first control point of the next segment
    CGPoint pts[5];
    uint ctr;
    
    BOOL touchEnded;
    BOOL pageLoaded;
    NSMutableArray *_drawnStrokes;
    CAShapeLayer *_guideLayer;
    CGRect bounds;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil) {
//        CALayer* hostedLayer = [CALayer layer];
//        hostedLayer.bounds = frame;
//        [self setLayer:hostedLayer];
//        CALayer* sub = [CALayer layer];
//        sub.bounds = frame;
//        [self.layer addSublayer:sub];
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)coder
{
    if ((self = [super initWithCoder:coder])) {
//        CALayer* hostedLayer = [CALayer layer];
//        hostedLayer.bounds = self.frame;
//        [self setLayer:hostedLayer];
//        CALayer* sub = [CALayer layer];
//        sub.bounds = self.frame;
//        [self.layer addSublayer:sub];
    }
    return self;
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    [super drawLayer:layer inContext:ctx];
    NSMutableArray *strokeArray;
    CGRect strokeBounds;

    CGRect ctxBox = CGContextGetClipBoundingBox(ctx);
    CGFloat H = ctxBox.size.height;
    CGContextSetRGBFillColor(ctx, 1.0f, 1.0f, 1.0f, 1.0f); // White
    CGContextFillRect(ctx, CGContextGetClipBoundingBox(ctx)); // Fill
    
    NSLog(@"pageScale %f", [self pageScale]);
    for(NJStroke *stroke in mPage.strokes) {
        if(stroke.type == MEDIA_STROKE)
            [stroke renderWithScale:[self pageScale]];
    }
    strokeArray = [NSMutableArray arrayWithArray:mPage.strokes];
    //NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(CGContextGetClipBoundingBox(ctx)));
    if (_PDFPageRef != NULL) {
        CGContextSaveGState(ctx);
        CGContextTranslateCTM(ctx, 0.0f, H);
        CGContextScaleCTM(ctx, 1.0f, -1.0f);
        CGContextConcatCTM(ctx, CGPDFPageGetDrawingTransform(_PDFPageRef, kCGPDFCropBox, ctxBox, 0, true));
        CGContextDrawPDFPage(ctx, _PDFPageRef); // Render the PDF page into the context
        CGContextRestoreGState(ctx);
    }
    for(NJStroke *stroke in strokeArray) {
        if(stroke.type == MEDIA_STROKE) {
            strokeBounds = stroke.totalBounds;
            if(CGRectIntersectsRect(ctxBox, strokeBounds))
                [stroke drawStrokeInContext:ctx];
        }
    }

}
- (void) calculateSizes
{
    NJPage *activePage = [NJNotebookWriterManager sharedInstance].activePageDocument.page;
    _normalizer = activePage.normalizer;
    _offset = activePage.paperOffset;
    [self addGuideLayer];
}
#pragma mark - draw functions
- (void) touchBeganX: (float)x_coordinate Y: (float)y_coordinate Pressure:(float)pressure PenColor:(NSColor *)pColor PenThickness:(NSUInteger)pThickness
{
    penColor = pColor;
    penThickness = pThickness;
    
    CGPoint currentLocation;
    currentLocation.x = x_coordinate;
    currentLocation.y = y_coordinate;
    
    point_count = 0;
    point_x[point_count] = currentLocation.x;
    point_y[point_count] = currentLocation.y;
    point_p[point_count] = pressure;
    point_count++;
    
    
    _guideLayer.strokeColor = pColor.CGColor;
    CGPoint p;
    //jr
    //    p.x = x_coordinate * _canvsRatio;
    //    p.y = y_coordinate * _canvsRatio;
    p.x = (x_coordinate - _offset.x)/_normalizer * [self pageScale];
    p.y = (y_coordinate - _offset.y)/_normalizer * [self pageScale];
    
    tempPath = [NSBezierPath bezierPath];
    ctr = 0;
    pts[0] = p;
    [self scrollPointToCentre:p];
    
}
- (void) touchMovedX:(float)x_coordinate Y:(float)y_coordinate Pressure:(float)pressure
{
    
    CGPoint currentLocation;
    currentLocation.x = x_coordinate;
    currentLocation.y = y_coordinate;
    
    point_x[point_count] = currentLocation.x;
    point_y[point_count] = currentLocation.y;
    point_p[point_count] = pressure;
    point_count++;
    
    CGPoint p;
    //    p.x = x_coordinate * _canvsRatio;
    //    p.y = y_coordinate * _canvsRatio;
    p.x = (x_coordinate - _offset.x)/_normalizer * [self pageScale];
    p.y = (y_coordinate - _offset.y)/_normalizer * [self pageScale];
    NSLog(@"Touch point %@", NSStringFromPoint(p));
    ctr++;
    pts[ctr] = p;
    if (ctr == 4)
    {
        pts[3] = CGPointMake((pts[2].x + pts[4].x)/2.0, (pts[2].y + pts[4].y)/2.0);
        // move the endpoint to the middle of the line joining the second control point of
        // the first Bezier segment and the first control point of the second Bezierß segment
        
        [tempPath moveToPoint:pts[0]];
        [tempPath curveToPoint:pts[3] controlPoint1:pts[1] controlPoint2:pts[2]];
        // add a cubic Bezier from pt[0] to pt[3], with control points pt[1] and pt[2]
        
        //CGRect rect = tempPath.bounds;
//        [self setNeedsDisplay:YES];
        // replace points and get ready to handle the next segment
        pts[0] = pts[3];
        pts[1] = pts[4];
        ctr = 1;
    }
    if(_guideLayer != nil)
        [_guideLayer removeFromSuperlayer];
    _guideLayer = [CAShapeLayer layer];
    CGPathRef path = [tempPath quartzPath];
    [_guideLayer setPath:path];
    _guideLayer.fillColor = CGColorCreateGenericRGB(0.0, 0.0, 0.0, 1.0);
    _guideLayer.lineJoin = kCALineJoinRound;
    _guideLayer.lineCap = kCALineCapRound;
    [self.layer addSublayer:_guideLayer];
}
- (void) strokeUpdated
{

    UInt32 nColor = 0xffffffff;
    CGSize paperSize;
    NJStroke *aStroke = [[NJStroke alloc] initWithRawDataX:point_x Y:point_y pressure:point_p time_diff:time_diff
                                                  penColor:nColor penThickness:penThickness startTime:[[NSDate date] timeIntervalSince1970] size:point_count
                                                normalizer:_normalizer paperSize:paperSize shouldFilter:YES];
    [aStroke normalize:_normalizer offset:_offset]; // this is important!!
    [aStroke renderWithScale:[self pageScale]];
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    //layer.frame = self.bounds;
    //layer.bounds = self.bounds;
    [layer setPath: aStroke.renderingPath.quartzPath];
    layer.fillColor = CGColorCreateGenericRGB(0.0, 0.0, 0.0, 1.0);
    layer.lineJoin = kCALineJoinRound;
    layer.lineCap = kCALineJoinRound;
    [self.layer addSublayer:layer];
    NSLog(@"View frame = %@", NSStringFromRect(self.frame));
    [tempPath removeAllPoints];
    ctr = 0;
    [_guideLayer setPath: tempPath.quartzPath];
}
- (void)addGuideLayer
{
    if(_guideLayer != nil) return;
    _guideLayer = [CAShapeLayer layer];
    _guideLayer.lineJoin = kCALineJoinRound;
    _guideLayer.lineCap = kCALineCapRound;
    _guideLayer.fillColor = CGColorCreateGenericRGB(0.0, 0.0, 0.0, 1.0);
    _guideLayer.lineWidth = 2.0f;
    _guideLayer.frame = self.frame;
    [self.layer addSublayer:_guideLayer];
}
@end
