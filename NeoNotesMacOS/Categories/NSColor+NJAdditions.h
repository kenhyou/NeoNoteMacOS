//
//  NSColor+NJAdditions.h
//  NeoNotesMacOS
//

#import <Foundation/Foundation.h>

@interface NSColor (NJAdditions)
+ (NSColor*)rgbWhite;
+ (NSColor*)rgbBlack;
+ (NSColor*)rgbGrey:(CGFloat)grayscale;
+ (NSColor*)rgbGrey:(CGFloat)grayscale withAlpha:(CGFloat)alpha;
+ (NSColor*)veryLightGrey;
@end
