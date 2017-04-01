//
//  NSColor+NJAdditions.m
//  NeoNotesMacOS
//

#import "NSColor+NJAdditions.h"

@implementation NSColor (NJAdditions)
#pragma mark As an NSColor

+ (NSColor*)rgbWhite
{
    return [self rgbGrey:1.0];
}

+ (NSColor*)rgbBlack
{
    return [self rgbGrey:0.0];
}

+ (NSColor*)rgbGrey:(CGFloat)grayscale
{
    return [self rgbGrey:grayscale
               withAlpha:1.0];
}

+ (NSColor*)rgbGrey:(CGFloat)grayscale withAlpha:(CGFloat)alpha
{
    return [self colorWithCalibratedRed:grayscale
                                  green:grayscale
                                   blue:grayscale
                                  alpha:alpha];
}

+ (NSColor*)veryLightGrey
{
    return [self rgbGrey:0.9];
}
@end
