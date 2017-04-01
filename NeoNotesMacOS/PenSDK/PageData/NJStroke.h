//
//  NJStroke.h
//  NeoJournal
//
//  Copyright (c) 2014 Neolab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NJMedia.h"

typedef NS_ENUM (NSInteger, NJPenType) {
    NJPenTypeNeoPen,
    NJPenTypePen,
    NJPenTypeHighlight
};


@class NJNode;
@interface NJStroke : NJMedia {
    @public
    float *point_x, *point_y, *point_p;
    UInt64 *time_stamp;
}

@property (strong, nonatomic) NSArray *nodes;
@property (nonatomic) int dataCount;
//@property (nonatomic) float inputScale;
@property (nonatomic) float targetScale;
@property (nonatomic) float normalizer;
@property (strong, nonatomic) NJTransformation *transformation;
@property (nonatomic) UInt32 penColor;
@property (nonatomic, readonly) NSColor *penUIColor;
@property (nonatomic) NSUInteger penThickness;
@property (nonatomic) NJPenType penType;

@property (strong, nonatomic) NSBezierPath *renderingPath;

@property (nonatomic,strong) NSBezierPath *targetPath;
@property (nonatomic, assign, readonly) CGRect totalBounds;
@property (nonatomic, assign, readonly) CGRect pathBounds;
@property (nonatomic, readonly) CGFloat lineWidth;
@property (nonatomic) CGSize paperSize;




+ (CGFloat)lineWidthFromThickness:(NSUInteger)thickness forPenType:(NJPenType)penType scale:(CGFloat)scale;
+ (NJStroke *) strokeFromData:(NSData *)data at:(int *)position version:(NSUInteger)version paperSize:(CGSize)paperSize;
- (instancetype) initWithSize:(int)size;
- (instancetype) initWithStroke:(NJStroke *)stroke;
- (instancetype) initWithRawDataX:(float *)x Y:(float*)y pressure:(float *)p time_diff:(int *)time
                         penColor:(UInt32)penColor penThickness:(NSUInteger)thickness startTime:(UInt64)start_at size:(int)size normalizer:(float)inputScale paperSize:(CGSize)paperSize shouldFilter:(BOOL)shouldFilter;
- (instancetype) initWithStroke:(NJStroke *)stroke normalizer:(float)inputScale;
//- (void) normalize:(float)inputScale;
- (void) normalize:(float)normalizer offset:(CGPoint)offset;
- (void) simplify;

- (void) moveBy:(CGPoint)delta inputScale:(CGFloat)inputScale;
- (void) scaleBy:(CGFloat)scale inputScale:(CGFloat)inputScale;
- (void) rotateBy:(CGFloat)angle inputScale:(CGFloat)inputScale;
- (void) renderWithScale:(CGFloat)scale;
- (void) renderWithScale:(CGFloat)scale penType:(NJPenType)penType;
- (void) renderAndDrawStrokeInContext:(CGContextRef)ctx scale:(CGFloat)scale penStyle:(NJPenType)penType;
- (void) drawStrokeInContext:(CGContextRef)ctx;
- (void) drawStrokeInContext:(CGContextRef)ctx color:(NSColor *)color;
- (void) drawStrokeInContext:(CGContextRef)ctx color:(NSColor *)color lineWidth:(CGFloat)lineWidth;




//@property (nonatomic) UInt64 startTime;
//- (id) initWithNodes:(NSArray *) nodes;
//- (void) renderWithPenStyle:(NJPenStyle)penStyle scale:(CGFloat)scale;
//- (void) renderNodesWithFountainPenWithSize:(CGRect)bounds scale:(float)scale screenRatio:(float)screenRatio
//                                    offsetX:(float)offset_x offsetY:(float)offset_y withVoice:(BOOL)withVoice forMode:(NeoMediaRenderingMode)mode;
//- (void) renderNodesWithFountainPenWithSize:(CGRect)bounds scale:(float)scale screenRatio:(float)screenRatio
//                                    offsetX:(float)offset_x offsetY:(float)offset_y;
//- (void) renderNodesWithFountainPenWithSize:(CGRect)bounds scale:(float)scale screenRatio:(float)screenRatio
//                                    offsetX:(float)offset_x offsetY:(float)offset_y strokeColor:(NSColor *)color;
//- (void) setDataX:(float)x y:(float)y pressure:(float)pressure time_stamp:(UInt64)time at:(int)index;

@end
