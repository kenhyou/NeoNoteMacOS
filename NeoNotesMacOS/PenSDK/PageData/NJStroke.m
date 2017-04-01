 //
//  NJStroke.m
//  NeoJournal
//
//  Copyright (c) 2014 Neolab. All rights reserved.
//

#import "NJStroke.h"
#import "NJNode.h"
#import "NJTransformation.h"
#import "NJRDPFilter.h"
#import "math.h"
#import "NSBezierPath+BezierPathQuartzUtilities.h"


#define MAX_NODE_NUMBER 1024*STROKE_NUMBER_MAGNITUDE
#define NODE_FILTER_ANGLE 5 // degrees

@interface NJStroke()
{
    float colorRed, colorGreen, colorBlue, colorAlpah;
    CGFloat _tScale;
    CGPoint _offset;

}

@end
@implementation NJStroke
@synthesize transformation  = _transformation;
@synthesize bounds          = _bounds;
- (instancetype) init
{
    self = [super init];
    if (self == nil) {
        return nil;
    }
    self.type = MEDIA_STROKE;
     _penThickness = 0;
    return self;
}
- (instancetype) initWithSize:(int)size
{
    self = [self init];
    if (!self) return nil;
    _dataCount = size;
    point_x = (float *)calloc(size, sizeof(float));
    point_y = (float *)calloc(size, sizeof(float));
    point_p = (float *)calloc(size, sizeof(float));
    time_stamp = (UInt64 *)calloc(size, sizeof(UInt64));
    start_time = 0;
    //_normalizer = 1;
    _penType = NJPenTypeNeoPen;
    [self initColor];
    return self;
}
- (instancetype)initWithStroke:(NJStroke *)stroke
{
    self = [self init];
    if (!self) return nil;
    _dataCount = stroke.dataCount;
    point_x = (float *)malloc(sizeof(float) * _dataCount);
    point_y = (float *)malloc(sizeof(float) * _dataCount);
    point_p = (float *)malloc(sizeof(float) * _dataCount);
    time_stamp = (UInt64 *)malloc(sizeof(UInt64) * _dataCount);
    start_time = stroke->start_time;
    //_inputScale = stroke.inputScale;
    //_normalizer = 1;
    _penColor = stroke.penColor;
    _penThickness = stroke.penThickness;
    _penType = stroke.penType;
    
    memcpy(point_p, stroke->point_p, sizeof(float) * _dataCount);
    memcpy(point_x, stroke->point_x, sizeof(float) * _dataCount);
    memcpy(point_y, stroke->point_y, sizeof(float) * _dataCount);
    memcpy(time_stamp, stroke->time_stamp, sizeof(UInt64) * _dataCount);
    
    return self;
}
- (instancetype) initWithRawDataX:(float *)x Y:(float*)y pressure:(float *)p time_diff:(int *)time
penColor:(UInt32)penColor penThickness:(NSUInteger)thickness startTime:(UInt64)start_at size:(int)size normalizer:(float)inputScale paperSize:(CGSize)paperSize shouldFilter:(BOOL)shouldFilter
{
    self = [self init];
    if (!self) return nil;
    int time_lapse = 0;
    int i = 0;
    if (size < 3) {
        //We nee at least 3 point to render.
        //Warning!! I'm assume x, y, p are c style arrays that have at least 3 spaces.
        for (i = size; i < 3; i++) {
            x[i] = x[size -1];
            y[i] = y[size -1];
            p[i] = p[size -1];
            time[i]=0;
        }
        size = 3;
    }
    
    //self.paperSize = paperSize;
    NSMutableArray *simplifiedPath = nil;
//    if(shouldFilter && (size > 10)) {
//        NSMutableArray *points  = [NSMutableArray array];
//        for(int i=0; i < size; i++) {
//            [points addObject:[[DataPoint alloc] initWithX:x[i] andY:y[i] andP:(p[i]/255.0)*inputScale]];
//        }
//        
//        simplifiedPath = [NJRDPFilter douglasPeuckerReduction:points withTolerance:0.2f];
//        NSLog(@"original points count --> %tu ---> simplified  to ---> %tu",points.count,simplifiedPath.count);
//        
//        int newSize = (int)simplifiedPath.count;
//        if(newSize < 3) {
//            simplifiedPath = nil;
//        } else {
//            size = newSize;
//        }
//    }
    _dataCount = size;
    point_x = (float *)malloc(sizeof(float) * size);
    point_y = (float *)malloc(sizeof(float) * size);
    point_p = (float *)malloc(sizeof(float) * size);
    time_stamp = (UInt64 *)malloc(sizeof(UInt64) * size);
    start_time = start_at;
    //_normalizer = 1;
    _penThickness = thickness;
//    memcpy(point_p, p, sizeof(float) * size);
    for (i=0; i<size; i++) {
        NSUInteger num = (simplifiedPath == nil)? i : [[simplifiedPath objectAtIndex:i] integerValue];
        //point_x[i] = x[num] / inputScale;
        //point_y[i] = y[num] / inputScale;
        point_x[i] = x[num];
        point_y[i] = y[num];
        point_p[i] = p[num];
        time_lapse += time[i];
        time_stamp[i] = start_at + time_lapse;
    }
    //_inputScale = inputScale;
    if (penColor == 0) {
        [self initColor];
    }
    else {
        self.penColor = penColor;
    }
    return self;
}
- (void) normalize:(float)normalizer offset:(CGPoint)offset;
{
    _normalizer = normalizer;
    _offset = offset;
    for (int i=0; i < _dataCount; i++) {
        point_x[i] -= offset.x;
        point_y[i] -= offset.y;
        point_x[i] /= normalizer;
        point_y[i] /= normalizer;
    }
}
- (void)simplify
{
    int size = _dataCount;
    NSMutableArray *simplifiedPath = nil;
    if(size > 30) {
        NSMutableArray *points  = [NSMutableArray array];
        for(int i=0; i < size; i++)
            [points addObject:[[DataPoint alloc] initWithX:point_x[i] andY:point_y[i] andP:point_p[i]]];
        
        simplifiedPath = [NJRDPFilter douglasPeuckerReduction:points withTolerance:0.005f];
        NSLog(@"original points count --> %tu ---> simplified  to ---> %tu",points.count,simplifiedPath.count);
        
        int newSize = (int)simplifiedPath.count;
        if(newSize < 3) {
            simplifiedPath = nil;
        } else {
            size = newSize;
        }
    }
    _dataCount = size;
    
    float *point_x2, *point_y2, *point_p2;
    UInt64 *time_stamp2;
    
    point_x2 = (float *)malloc(sizeof(float) * size);
    point_y2 = (float *)malloc(sizeof(float) * size);
    point_p2 = (float *)malloc(sizeof(float) * size);
    time_stamp2 = (UInt64 *)malloc(sizeof(UInt64) * size);

    for (int i=0; i<size; i++) {
        NSUInteger num = (simplifiedPath == nil)? i : [[simplifiedPath objectAtIndex:i] integerValue];
        point_x2[i] = point_x[num];
        point_y2[i] = point_y[num];
        point_p2[i] = point_p[num];
        time_stamp2[i] = time_stamp[num];
    }

    free(point_x);
    free(point_y);
    free(point_p);
    free(time_stamp);

    point_x = point_x2;
    point_y = point_y2;
    point_p = point_p2;
    time_stamp = time_stamp2;
}



//static float penThicknessScale[] = {960.0, 480.0, 230.0};
static float neoPenThicknessScale[] = {600.0, 300.0, 180.0, 110.0, 55.0};
static float normalPenThicknessScale[] = {1.0, 2.0, 4.0, 8.0, 16.0};
static float highlightPenThicknessScale[] = {1.0, 2.0, 4.0, 8.0, 16.0};
+ (CGFloat)lineWidthFromThickness:(NSUInteger)thickness forPenType:(NJPenType)penType scale:(CGFloat)scale
{
    int thicknessIdex = (int)thickness; // for current version store 0 ~ (n-1)
    CGFloat h = (penType == NJPenTypeNeoPen)? 118.6f : 7.6f;//magic number
    CGFloat ratio = (scale / h);
    
    if(penType == NJPenTypeNeoPen) {
        int maxT = (sizeof(neoPenThicknessScale)/sizeof(float)) - 1;
        if (thickness > maxT) thicknessIdex = maxT;
        return (neoPenThicknessScale[thicknessIdex] * ratio);
        
    } else if(penType == NJPenTypePen) {
        
        int maxT = (sizeof(normalPenThicknessScale)/sizeof(float)) - 1;
        if (thickness > maxT) thicknessIdex = maxT;
        return (normalPenThicknessScale[thicknessIdex] * ratio);
        
    } else {
        
        int maxT = (sizeof(highlightPenThicknessScale)/sizeof(float)) - 1;
        if (thickness > maxT) thicknessIdex = maxT;
        return (highlightPenThicknessScale[thicknessIdex] * ratio);
    }
}
/* Initialize stroke from file. */
+ (NJStroke *) strokeFromData:(NSData *)data at:(int *)position version:(NSUInteger)version paperSize:(CGSize)paperSize
{
    NJStroke *stroke = [[NJStroke alloc] init];
    //if (stroke == nil) return nil;
    //stroke.paperSize = paperSize;
    //[stroke initFromData:data at:position version:version];
    if(![stroke readFromData:data at:position version:version]) return nil;
    return stroke;
}
- (BOOL) readFromData:(NSData *)data at:(int *)position version:(NSUInteger)version
{
    UInt32 penColor, nodeCount;
    Float32 x, y, pressure;
    *position += 1; //skip type
    
    if ([self readValueFromData:data to:&penColor at:position length:sizeof(UInt32)] == NO) {
        return NO;
    }
    unsigned char thickness;
    if ([self readValueFromData:data to:&thickness at:position length:sizeof(unsigned char)] == NO) {
        return NO;
    }
    _penThickness = thickness;
    if ([self readValueFromData:data to:&nodeCount at:position length:sizeof(UInt32)] == NO) {
        return NO;
    }
    point_x = (float *)calloc(nodeCount, sizeof(float));
    point_y = (float *)calloc(nodeCount, sizeof(float));
    point_p = (float *)calloc(nodeCount, sizeof(float));
    time_stamp = (UInt64 *)calloc(nodeCount, sizeof(UInt64));
    self.penColor = penColor;
    _dataCount = nodeCount;
    [self readValueFromData:data to:&start_time at:position length:sizeof(UInt64)];
    unsigned char timeDiff;
    UInt64 timeStamp = start_time;
    for (int i=0; i < nodeCount;i++ ) {
        [self readValueFromData:data to:&x at:position length:sizeof(Float32)];
        [self readValueFromData:data to:&y at:position length:sizeof(Float32)];
        [self readValueFromData:data to:&pressure at:position length:sizeof(Float32)];
        [self readValueFromData:data to:&timeDiff at:position length:sizeof(unsigned char)];
        timeStamp += timeDiff;
        //[self setDataX:x y:y pressure:pressure time_stamp:timeStamp at:i];
	point_x[i] = x;
        point_y[i] = y;
        point_p[i] = pressure;
        time_stamp[i] = timeStamp;
    }
    
    // from version 3 we add viariable extra bytes for future references
    if(version < 3) return YES;
    // first byte is always for lenth of extra bytes
    unsigned char length = 0;
    if ([self readValueFromData:data to:&length at:position length:sizeof(unsigned char)] == NO) {
        return NO;
    }
    if(version >= 3) {
        unsigned char penStyle;
        if ([self readValueFromData:data to:&penStyle at:position length:sizeof(unsigned char)] == NO) {
            return NO;
        }
        _penType = penStyle;
        
//         make sure color alpha value is started - temporal code
//        if(_penType == NJPenTypeHighlight) {
//            if(colorAlpah == 1.0f) {
//                colorAlpah = 0.2f;
//                [self resetPenColor];
//            }
//        }
    }
    if(length-- <= 0) return YES;
    
    if(length > 0) {
        char extra[] = {'\0',};
        [self readValueFromData:data to:extra at:position length:length];
    }
    
    return YES;
}
/* Save stroke to a file */
//- (BOOL) writeMediaToData:(NSMutableData *)data withStartX:(float)startX andStartY:(float)startY
- (BOOL) writeMediaToData:(NSMutableData *)data
{
    Float32 x, y, pressure;
    UInt64 time_lapse = start_time;
    unsigned char timeDiff;
    unsigned char kind = (unsigned char)MEDIA_STROKE;
    [data appendBytes:&kind length:sizeof(unsigned char)];
    UInt32 penColor = (UInt32)self.penColor;
    [data appendBytes:&penColor length:sizeof(UInt32)];
    unsigned char thickness = _penThickness;
    [data appendBytes:&thickness length:sizeof(unsigned char)];
    UInt32 nodeCount = (UInt32)self.dataCount;
    [data appendBytes:&nodeCount length:sizeof(UInt32)];
    [data appendBytes:&start_time length:sizeof(UInt64)];
    for (int i = 0; i < nodeCount; i++) {
        //x = point_x[i] + startX;
        //y = point_y[i] + startY;
        // de-normalize
        x = point_x[i] * _normalizer;
        y = point_y[i] * _normalizer;
        x += _offset.x;
        y += _offset.y;
        pressure = point_p[i];
        timeDiff = time_stamp[i] - time_lapse;
        time_lapse = time_stamp[i];
        [data appendBytes:&x length:sizeof(Float32)];
        [data appendBytes:&y length:sizeof(Float32)];
        [data appendBytes:&pressure length:sizeof(Float32)];
        [data appendBytes:&timeDiff length:sizeof(unsigned char)];
    }
    
    
    // from version 3 we add viariable extra bytes for future references
    // first byte is always for lenth of extra bytes
    unsigned char length  = 1;
    [data appendBytes:&length length:sizeof(unsigned char)];
    
    unsigned char penStyle = (unsigned char)_penType;
    [data appendBytes:&penStyle length:sizeof(unsigned char)];
    
    return YES;
}
- (CGFloat)lineWidth
{
    //CGFloat paperNom = MAX(self.paperSize.width, self.paperSize.height);
    //CGFloat scale = (self.penType == NJPenTypeNeoPen)? paperNom : (_tScale/paperNom);
    CGFloat scale = (self.penType == NJPenTypeNeoPen)? _normalizer : (_tScale/_normalizer);
    return [NJStroke lineWidthFromThickness:_penThickness forPenType:self.penType scale:scale];
}
- (NSColor *)penUIColor{
    
    float colorA = (self.penColor>>24)/255.0f;
    float colorR = ((self.penColor>>16)&0x000000FF)/255.0f;
    float colorG = ((self.penColor>>8)&0x000000FF)/255.0f;
    float colorB = (self.penColor&0x000000FF)/255.0f;
    
    return [NSColor colorWithRed:colorR green:colorG blue:colorB alpha:colorA];
}
/*
- (void) normalize:(float)inputScale
{
    if (_inputScale != 1) {
        // already normalized.
        return;
    }
    _inputScale = inputScale;
    for (int i=0; i < _dataCount; i++) {
        point_x[i] = point_x[i] / inputScale;
        point_y[i] = point_y[i] / inputScale;
    }
}*/
- (NJTransformation *)transformation
{
    if (_transformation == nil) {
        _transformation = [[NJTransformation alloc] init];
    }
    return _transformation;
}
- (void)setTransformation:(NJTransformation *)transformation
{
    [self.transformation setValueWithTransformation:transformation];
    _targetScale = transformation.scale;
}
- (void) dealloc
{
    free(point_x);
    free(point_y);
    free(point_p);
    free(time_stamp);
}
- (void) setPenColor:(UInt32)penColor
{
    _penColor = penColor;
    colorAlpah = (penColor>>24)/255.0f;
    colorRed = ((penColor>>16)&0x000000FF)/255.0f;
    colorGreen = ((penColor>>8)&0x000000FF)/255.0f;
    colorBlue = (penColor&0x000000FF)/255.0f;
}
- (void) resetPenColor
{
    UInt32 alpah = (UInt32)(colorAlpah * 255) & 0x000000FF;
    UInt32 red = (UInt32)(colorRed * 255) & 0x000000FF;
    UInt32 green = (UInt32)(colorGreen * 255) & 0x000000FF;
    UInt32 blue = (UInt32)(colorBlue * 255) & 0x000000FF;
    _penColor = (alpah << 24) | (red << 16) | (green << 8) | blue;

}
- (void)initColor
{
    colorRed = 0.2f;
    colorGreen = 0.2f;
    colorBlue = 0.2f;
    colorAlpah = 1.0f;
    UInt32 alpah = (UInt32)(colorAlpah * 255) & 0x000000FF;
    UInt32 red = (UInt32)(colorRed * 255) & 0x000000FF;
    UInt32 green = (UInt32)(colorGreen * 255) & 0x000000FF;
    UInt32 blue = (UInt32)(colorBlue * 255) & 0x000000FF;
    _penColor = (alpah << 24) | (red << 16) | (green << 8) | blue;
}
/*
- (void) setDataX:(float)x y:(float)y pressure:(float)pressure time_stamp:(UInt64)time at:(int)index
{
    if (index >= _dataCount) return;
    point_x[index] = x;
    point_y[index] = y;
    point_p[index] = pressure;
    time_stamp[index] = time;
}*/
- (NSBezierPath *)renderingPath
{
    if (_renderingPath == nil) {
        _renderingPath = [NSBezierPath bezierPath];
        [_renderingPath setLineWidth:1.0];
        //[_renderingPath fill];
    }
    return _renderingPath;
}

- (void)renderAndDrawStrokeInContext:(CGContextRef)ctx scale:(CGFloat)scale penStyle:(NJPenType)penType
{
    [self renderWithScale:scale penType:penType];
    [self _drawStrokeInContext:ctx penType:penType color:self.penUIColor lineWidth:self.penThickness];
}

- (void)drawStrokeInContext:(CGContextRef)ctx
{
    [self drawStrokeInContext:ctx color:self.penUIColor];
}
- (void)drawStrokeInContext:(CGContextRef)ctx color:(NSColor *)color
{
    [self drawStrokeInContext:ctx color:color lineWidth:self.lineWidth];
}
- (void)drawStrokeInContext:(CGContextRef)ctx color:(NSColor *)color lineWidth:(CGFloat)lineWidth
{
    [self _drawStrokeInContext:ctx penType:self.penType color:color lineWidth:lineWidth];
}
- (void)_drawStrokeInContext:(CGContextRef)ctx penType:(NJPenType)penTypee color:(NSColor *)color lineWidth:(CGFloat)lineWidth
{
    if(self.renderingPath == nil) return;
    if(color == nil) color = [NSColor blackColor];
    CGContextSaveGState(ctx);
    
    if(penTypee == NJPenTypeNeoPen) {

        CGContextSetStrokeColorWithColor(ctx, [NSColor clearColor].CGColor);
        CGContextSetFillColorWithColor(ctx, color.CGColor);
        CGContextAddPath(ctx, self.renderingPath.CGPath);
        CGContextFillPath(ctx);
        
    } else if (penTypee == NJPenTypePen) {
    } else if (penTypee == NJPenTypeHighlight) {
    }
    CGContextRestoreGState(ctx);
}

- (void)renderWithScale:(CGFloat)scale penType:(NJPenType)penType
{
    _tScale = scale;
    
    if(penType == NJPenTypeNeoPen) {
        [self renderWithFountainPenStyleWithScale:scale];
        
    } else if ((penType == NJPenTypePen) || (penType == NJPenTypeHighlight)) {
        [self _renderWithPenWithScale:scale];
    }
}
- (void)renderWithScale:(CGFloat)scale
{
    @autoreleasepool {
        [self renderWithScale:scale penType:self.penType];
    }
}




- (BOOL)isEqual:(id)object
{
    return (start_time == ((NJStroke *)object)->start_time);
}
- (void)createTargetPath
{
    if(self.renderingPath == nil) {
        self.targetPath = nil;
        return;
    }
}
- (CGRect)pathBounds
{
    if (self.renderingPath == nil) {
        return CGRectZero;
    }
    
    return self.renderingPath.bounds;
}
- (CGRect)totalBounds
{
    if (self.renderingPath == nil) {
        return CGRectZero;
    }
    
    return CGRectInset(self.renderingPath.bounds, -(self.renderingPath.lineWidth *1.1f), -(self.renderingPath.lineWidth * 1.1f));
}
- (void)moveBy:(CGPoint)delta inputScale:(CGFloat)inputScale
{
}
- (void)scaleBy:(CGFloat)scale inputScale:(CGFloat)inputScale
{
    NSLog(@"scale by ---> %f",scale);
}
- (void)rotateBy:(CGFloat)angle inputScale:(CGFloat)inputScale
{
}




- (void)_renderWithPenWithScale:(CGFloat)scale
{
    CGPoint pts[5]; // we now need to keep track of the four points of a Bezier segment and the first control point of the next segment
    uint ctr = 0;
    [self.renderingPath removeAllPoints];
    
    if(self.dataCount < 5) {
        
        CGPoint p = CGPointMake(point_x[0] * scale, point_y[0] * scale);
        [self.renderingPath moveToPoint:p];
        
        for(int i=1; i < self.dataCount; i++) {
            p = CGPointMake(point_x[i] * scale, point_y[i] * scale);
            [self.renderingPath lineToPoint:p];
        }
        
        return;
    }
    
    for(int i=0; i < self.dataCount; i++) {
        
        CGPoint p = CGPointMake(point_x[i] * scale, point_y[i] * scale);
        if(i == 0) {
            pts[0] = p;
            continue;
        }
        ctr++;
        
        pts[ctr] = p;
        if (ctr == 4)
        {
            pts[3] = CGPointMake((pts[2].x + pts[4].x)/2.0, (pts[2].y + pts[4].y)/2.0);
            // move the endpoint to the middle of the line joining the second control point of
            // the first Bezier segment and the first control point of the second Bezier segment
            
            [self.renderingPath moveToPoint:pts[0]];
            [self.renderingPath curveToPoint:pts[3] controlPoint1:pts[1] controlPoint2:pts[2]];
            // add a cubic Bezier from pt[0] to pt[3], with control points pt[1] and pt[2]
            // replace points and get ready to handle the next segment
            pts[0] = pts[3];
            pts[1] = pts[4];
            ctr = 1;
        }
        
        if((i == (self.dataCount-1)) && (ctr > 0) && (ctr < 4)) {
            
            CGPoint ctr1;
            CGPoint ctr2;
            
            if(ctr == 1)
                [self.renderingPath lineToPoint:pts[ctr]];
            else {
                ctr1 = ctr2 = pts[ctr - 2];
                if(ctr == 3)
                    ctr2 = pts[ctr -1];
                
                [self.renderingPath curveToPoint:pts[ctr] controlPoint1:ctr1 controlPoint2:ctr2];
            }
        }
    }
}
- (void) renderWithFountainPenStyleWithScale:(CGFloat)scale
{
    [self _renderWithNeoPenWithScale:scale offsetX:0.0f offsetY:0.0f strokeColor:nil];
}
- (void)sampleTest:(float)scale
{
    // try smaples

    NSArray * samples =
    
    @[
      @"164", @"421", @"0.082353",
      @"166", @"415", @"0.298039",
      @"178", @"395", @"0.419608",
      @"179", @"392", @"0.431373",
      @"185", @"383", @"0.45098",
      @"186", @"382", @"0.462745",
      @"187", @"381", @"0.466667",
      @"187", @"380", @"0.466667",
      @"188", @"380", @"0.470588",
      @"191", @"380", @"0.470588",
      @"196", @"381", @"0.47451",
      @"204", @"384", @"0.482353",
      @"208", @"386", @"0.486275",
      @"212", @"387", @"0.486275",
      @"218", @"390", @"0.490196",
      @"225", @"394", @"0.490196",
      @"233", @"398", @"0.494118",
      @"250", @"407", @"0.498039",
      @"253", @"408", @"0.498039",
      @"255", @"409", @"0.498039",
      @"256", @"409", @"0.501961",
      @"259", @"409", @"0.498039",
      @"261", @"408", @"0.498039",
      @"263", @"408", @"0.498039",
      @"265", @"407", @"0.498039",
      @"266", @"406", @"0.498039",
      @"268", @"405", @"0.498039",
      @"270", @"402", @"0.505882",
      @"274", @"398", @"0.509804",
      @"278", @"392", @"0.513726",
      @"281", @"389", @"0.521569",
      @"282", @"388", @"0.52549",
      @"282", @"387", @"0.537255"
      ];

    
    _dataCount = ((int)samples.count / 3);
    int count = 0;
    for(int i=0; i < samples.count; i++) {
        
        int idx = (i % 3);
        float value = [[samples objectAtIndex:i] floatValue];
        
        if(idx == 0) {
            
            point_x[count] = value / scale;
            
        } else if(idx == 1) {
            
            point_y[count] = value / scale;
            
        } else if(idx == 2) {
            
            point_p[count++] = value;
            
        }
    }


}
- (void)_renderWithNeoPenWithScale2:(float)scale offsetX:(float)offset_x offsetY:(float)offset_y strokeColor:(NSColor *)color
{
    
//    for (int i=0; i < _dataCount; i++) {
//        NSLog(@"[%03d]   ,%f,%f,%f",i, point_x[i] * scale,point_y[i] * scale,point_p[i]);
//    }
   
    
    float penThicknessScaler = self.lineWidth;
    float lineThicknessScale = (float)1.0f/penThicknessScaler;
    float scaled_pen_thickness = 1.0f * scale * lineThicknessScale; // first 1.0f --> lineScale
    float x0, x1, x2, x3, y0, y1, y2, y3, p0, p1, p2, p3;
    float vx01, vy01, vx21, vy21; // unit tangent vectors 0->1 and 1<-2
    float norm;
    float n_x0, n_y0, n_x2, n_y2; // the normals
    
    CGPoint endPoint;
    
    // the first actual point is treated as a midpoint
    x0 = point_x[0] * scale + offset_x + 0.1f;
    y0 = point_y[0] * scale + offset_y;
    p0 = point_p[0];
    
    x1 = point_x[1] * scale + offset_x + 0.1f;
    y1 = point_y[1] * scale + offset_y;
    p1 = point_p[1];
    
    vx01 = x1 - x0;
    vy01 = y1 - y0;
    // instead of dividing tangent/norm by two, we multiply norm by 2
    norm = (float)sqrt( vx01 * vx01 + vy01 * vy01 + 0.0001f ) * 2.0f;
    vx01 = vx01 / norm * scaled_pen_thickness * p0;
    vy01 = vy01 / norm * scaled_pen_thickness * p0;
    n_x0 = vy01;
    n_y0 = -vx01;
    
    [self.renderingPath removeAllPoints];
    int cnt = _dataCount;
    for ( int i = 2; i < cnt - 1; i++ )
    {
        @autoreleasepool {
        // (x0,y0) and (x2,y2) are midpoints, (x1,y1) and (x3,y3) are actual
        // points
        x3 = point_x[i] * scale + offset_x + 0.1f;
        y3 = point_y[i] * scale + offset_y;
        p3 = point_p[i];
        // p3 = mDP[i] * mFP[i];
        
        x2 = (x1 + x3) / 2.0f;
        y2 = (y1 + y3) / 2.0f;
        p2 = (p1 + p3) / 2.0f;
        vx21 = x1 - x2;
        vy21 = y1 - y2;
        norm = (float) sqrt(vx21 * vx21 + vy21 * vy21 + 0.0001f) * 2.0f;
        vx21 = vx21 / norm * scaled_pen_thickness * p2;
        vy21 = vy21 / norm * scaled_pen_thickness * p2;
        n_x2 = -vy21;
        n_y2 = vx21;
        
        endPoint.x = x0 + n_x0;
        endPoint.y = y0 + n_y0;
        [self.renderingPath moveToPoint:endPoint];
        
        // The + boundary of the stroke
        drawPath(self.renderingPath, x1 + n_x0, y1 + n_y0, x1 + n_x2, y1 + n_y2, x2 + n_x2, y2 + n_y2 );
        // round out the cap
        drawPath(self.renderingPath, x2 + n_x2 - vx21, y2 + n_y2 - vy21, x2 - n_x2 - vx21, y2 - n_y2 - vy21, x2 - n_x2, y2 - n_y2 );
        // THe - boundary of the stroke
        drawPath(self.renderingPath, x1 - n_x2, y1 - n_y2, x1 - n_x0, y1 - n_y0, x0 - n_x0, y0 - n_y0 );
        // round out the other cap
        drawPath(self.renderingPath, x0 - n_x0 - vx01, y0 - n_y0 - vy01, x0 + n_x0 - vx01, y0 + n_y0 - vy01, x0 + n_x0, y0 + n_y0 );
        
        x0 = x2;
        y0 = y2;
        p0 = p2;
        x1 = x3;
        y1 = y3;
        p1 = p3;
        vx01 = -vx21;
        vy01 = -vy21;
        n_x0 = n_x2;
        n_y0 = n_y2;
        }
    }
    
    // the last actual point is treated as a midpoint
    x2 = point_x[cnt - 1] * scale + offset_x + 0.1f;
    y2 = point_y[cnt - 1] * scale + offset_y;
    p2 = point_p[cnt - 1];
    
    vx21 = x1 - x2;
    vy21 = y1 - y2;
    norm = (float)sqrt( vx21 * vx21 + vy21 * vy21 + 0.0001f ) * 2.0f;
    vx21 = vx21 / norm * scaled_pen_thickness * p2;
    vy21 = vy21 / norm * scaled_pen_thickness * p2;
    n_x2 = -vy21;
    n_y2 = vx21;
    
    
    endPoint.x = x0 + n_x0;
    endPoint.y = y0 + n_y0;
    [self.renderingPath moveToPoint:endPoint];
    
    drawPath(self.renderingPath, x1 + n_x0, y1 + n_y0, x1 + n_x2, y1 + n_y2, x2 + n_x2, y2 + n_y2 );
    drawPath(self.renderingPath, x2 + n_x2 - vx21, y2 + n_y2 - vy21, x2 - n_x2 - vx21, y2 - n_y2 - vy21, x2 - n_x2, y2 - n_y2 );
    drawPath(self.renderingPath, x1 - n_x2, y1 - n_y2, x1 - n_x0, y1 - n_y0, x0 - n_x0, y0 - n_y0 );
    drawPath(self.renderingPath, x0 - n_x0 - vx01, y0 - n_y0 - vy01, x0 + n_x0 - vx01, y0 + n_y0 - vy01, x0 + n_x0, y0 + n_y0 );
}

void drawPath(NSBezierPath *path,float c1x,float c1y,float c2x,float c2y,float px,float py)
{
    CGPoint point,c1,c2;
    point.x = px;
    point.y = py;
    c1.x = c1x;
    c1.y = c1y;
    c2.x = c2x;
    c2.y = c2y;
    
    [path curveToPoint:point controlPoint1:c1 controlPoint2:c2];
}

//Structure to save trace back path
typedef struct {
    CGPoint endPoint;
    CGPoint ctlPoint1;
    CGPoint ctlPoint2;
}PathPointsStruct;
- (void)_renderWithNeoPenWithScale:(float)scale offsetX:(float)offset_x offsetY:(float)offset_y strokeColor:(NSColor *)color
{
//    for (int i=0; i < _dataCount; i++) {
//        NSLog(@"[%03d]   ,%f,%f,%f",i, point_x[i] * scale,point_y[i] * scale,point_p[i]);
//    }
    if(_dataCount < 3) return;
    
    float penThicknessScaler = self.lineWidth;
    float lineThicknessScale = (float)1.0f/penThicknessScaler;
    float scaled_pen_thickness = 1.0f * scale * lineThicknessScale; // first 1.0f --> lineScale
    float x0, x1, x2, x3, y0, y1, y2, y3, p0, p1, p2, p3;
    float vx01, vy01, vx21, vy21; // unit tangent vectors 0->1 and 1<-2
    float norm;
    float n_x0, n_y0, n_x2, n_y2; // the normals
    
    CGPoint temp, endPoint, controlPoint1, controlPoint2;
    // the first actual point is treated as a midpoint
    x0 = point_x[ 0 ] * scale + offset_x + 0.1f;
    y0 = point_y[ 0 ] * scale + offset_y;
    p0 = point_p[ 0 ];
    x1 = point_x[ 1 ] * scale + offset_x + 0.1f;
    y1 = point_y[ 1 ] * scale + offset_y;
    p1 = point_p[ 1 ];
    
    vx01 = x1 - x0;
    vy01 = y1 - y0;
    // instead of dividing tangent/norm by two, we multiply norm by 2
    norm = (float)sqrt(vx01 * vx01 + vy01 * vy01 + 0.0001f) * 2.0f ;
    vx01 = vx01 / norm * scaled_pen_thickness * p0;
    vy01 = vy01 / norm * scaled_pen_thickness * p0;
    n_x0 = vy01;
    n_y0 = -vx01;
    
    // Trip back path will be saved.
    PathPointsStruct *pathPointStore = (PathPointsStruct *)malloc(sizeof(PathPointsStruct) * (_dataCount + 2));
    int pathSaveIndex = 0;
    temp.x = x0 + n_x0;
    temp.y = y0 + n_y0;
    if(isinf(temp.x) || isinf(temp.y)) { NSLog(@"FountainPen Rendering Failed.."); return; }
    [self.renderingPath removeAllPoints];
    [self.renderingPath moveToPoint:temp];
    endPoint.x = x0 + n_x0;
    endPoint.y = y0 + n_y0;
    controlPoint1.x = x0 - n_x0 - vx01;
    controlPoint1.y = y0 - n_y0 - vy01;
    controlPoint2.x = x0 + n_x0 - vx01;
    controlPoint2.y = y0 + n_y0 - vy01;
    //Save last path. I'll be back here....
    pathPointStore[pathSaveIndex].endPoint = endPoint;
    pathPointStore[pathSaveIndex].ctlPoint1 = controlPoint1;
    pathPointStore[pathSaveIndex].ctlPoint2 = controlPoint2;
    pathSaveIndex++;
    for ( int i=2; i < _dataCount-1; i++ ) {
        @autoreleasepool {
            // (x0,y0) and (x2,y2) are midpoints, (x1,y1) and (x3,y3) are actual
            // points
            x3 = point_x[i] * scale + offset_x;// + 0.1f;
            y3 = point_y[i] * scale + offset_y;
            p3 = point_p[i];
            
            x2 = (x1 + x3) / 2.0f;
            y2 = (y1 + y3) / 2.0f;
            p2 = (p1 + p3) / 2.0f;
            vx21 = x1 - x2;
            vy21 = y1 - y2;
            norm = (float) sqrt(vx21 * vx21 + vy21 * vy21 + 0.0001f) * 2.0f;
            vx21 = vx21 / norm * scaled_pen_thickness * p2;
            vy21 = vy21 / norm * scaled_pen_thickness * p2;
            n_x2 = -vy21;
            n_y2 = vx21;
            
            if (norm < 0.6) {
                continue;
            }
            // The + boundary of the stroke
            endPoint.x = x2 + n_x2;
            endPoint.y = y2 + n_y2;
            controlPoint1.x = x1 + n_x0;
            controlPoint1.y = y1 + n_y0;
            controlPoint2.x = x1 + n_x2;
            controlPoint2.y = y1 + n_y2;
            [self.renderingPath curveToPoint:endPoint controlPoint1:controlPoint1 controlPoint2:controlPoint2];
            
            // THe - boundary of the stroke
            endPoint.x = x0 - n_x0;
            endPoint.y = y0 - n_y0;
            controlPoint1.x = x1 - n_x2;
            controlPoint1.y = y1 - n_y2;
            controlPoint2.x = x1 - n_x0;
            controlPoint2.y = y1 - n_y0;
            pathPointStore[pathSaveIndex].endPoint = endPoint;
            pathPointStore[pathSaveIndex].ctlPoint1 = controlPoint1;
            pathPointStore[pathSaveIndex].ctlPoint2 = controlPoint2;
            pathSaveIndex++;
            x0 = x2;
            y0 = y2;
            p0 = p2;
            x1 = x3;
            y1 = y3;
            p1 = p3;
            vx01 = -vx21;
            vy01 = -vy21;
            n_x0 = n_x2;
            n_y0 = n_y2;
        }
    }
    
    // the last actual point is treated as a midpoint
    x2 = point_x[ _dataCount-1 ] * scale + offset_x;// + 0.1f;
    y2 = point_y[ _dataCount-1 ] * scale + offset_y;
    p2 = point_p[ _dataCount-1 ];
    
    vx21 = x1 - x2;
    vy21 = y1 - y2;
    norm = (float) sqrt(vx21 * vx21 + vy21 * vy21 + 0.0001f) * 2.0f;
    vx21 = vx21 / norm * scaled_pen_thickness * p2;
    vy21 = vy21 / norm * scaled_pen_thickness * p2;
    n_x2 = -vy21;
    n_y2 = vx21;
    
    endPoint.x = x2 + n_x2;
    endPoint.y = y2 + n_y2;
    controlPoint1.x = x1 + n_x0;
    controlPoint1.y = y1 + n_y0;
    controlPoint2.x = x1 + n_x2;
    controlPoint2.y = y1 + n_y2;
    [self.renderingPath curveToPoint:endPoint controlPoint1:controlPoint1 controlPoint2:controlPoint2];
    endPoint.x = x2 - n_x2;
    endPoint.y = y2 - n_y2;
    controlPoint1.x = x2 + n_x2 - vx21;
    controlPoint1.y = y2 + n_y2 - vy21;
    controlPoint2.x = x2 - n_x2	- vx21;
    controlPoint2.y = y2 - n_y2 - vy21;
    [self.renderingPath curveToPoint:endPoint controlPoint1:controlPoint1 controlPoint2:controlPoint2];
    endPoint.x = x0 - n_x0;
    endPoint.y = y0 - n_y0;
    controlPoint1.x = x1 - n_x2;
    controlPoint1.y = y1 - n_y2;
    controlPoint2.x = x1 - n_x0;
    controlPoint2.y = y1 - n_y0;
    [self.renderingPath curveToPoint:endPoint controlPoint1:controlPoint1 controlPoint2:controlPoint2];
    // Trace back to the starting point
    for (int index = pathSaveIndex - 1; index >= 0; index--) {
        endPoint = pathPointStore[index].endPoint;
        controlPoint1 = pathPointStore[index].ctlPoint1;
        controlPoint2 = pathPointStore[index].ctlPoint2;
        @autoreleasepool {
            [self.renderingPath curveToPoint:endPoint controlPoint1:controlPoint1 controlPoint2:controlPoint2];
        }
    }
    
    free(pathPointStore);
}



@end
