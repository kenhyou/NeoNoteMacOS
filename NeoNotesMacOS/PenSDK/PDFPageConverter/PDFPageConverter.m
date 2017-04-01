//
//  PDFPageConverter.m
//
//  Created by Sorin Nistor on 3/23/11.
//  Copyright 2011 iPDFdev.com. All rights reserved.
//

#import "PDFPageConverter.h"
#import "PDFPageRenderer.h"

@implementation PDFPageConverter

+ (NSImage *) convertPDFPageToImage: (CGPDFPageRef)PDFPageRef withResolution: (float) resolution {
	
    
    if (PDFPageRef == NULL) // Check for non-NULL CGPDFPageRef
        return nil;

    //CGPDFPageRetain(PDFPageRef); // Retain the PDF page
    
    CGRect viewRect = CGRectZero; // View rect
    NSInteger pageAngle;
    CGFloat pageWidth;
    CGFloat pageHeight;
    CGFloat pageOffsetX;
    CGFloat pageOffsetY;
    
    CGRect cropBoxRect = CGPDFPageGetBoxRect(PDFPageRef, kCGPDFCropBox);
    CGRect mediaBoxRect = CGPDFPageGetBoxRect(PDFPageRef, kCGPDFMediaBox);
    CGRect effectiveRect = CGRectIntersection(cropBoxRect, mediaBoxRect);
    
    pageAngle = CGPDFPageGetRotationAngle(PDFPageRef); // Angle

    switch (pageAngle) // Page rotation angle (in degrees)
    {
        default: // Default case
        case 0: case 180: // 0 and 180 degrees
        {
            pageWidth = effectiveRect.size.width;
            pageHeight = effectiveRect.size.height;
            pageOffsetX = effectiveRect.origin.x;
            pageOffsetY = effectiveRect.origin.y;
            break;
        }
            
        case 90: case 270: // 90 and 270 degrees
        {
            pageWidth = effectiveRect.size.height;
            pageHeight = effectiveRect.size.width;
            pageOffsetX = effectiveRect.origin.y;
            pageOffsetY = effectiveRect.origin.x;
            break;
        }
    }
    
    //NSInteger page_w = pageWidth; // Integer width
    //NSInteger page_h = pageHeight; // Integer height
    
    //if (page_w % 2) page_w--; if (page_h % 2) page_h--; // Even
    
    viewRect.size = CGSizeMake(pageWidth, pageHeight); // View size
    /*
	CGRect cropBox = CGPDFPageGetBoxRect(page, kCGPDFCropBox);
	int pageRotation = CGPDFPageGetRotationAngle(page);
	*/

    //UIGraphicsBeginImageContextWithOptions(viewRect.size, NO, resolution / 72);
    NSImage *pageImage = [[NSImage alloc] initWithSize:viewRect.size];
    [pageImage lockFocusFlipped:YES];
	//CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    //[PDFPageRenderer renderPage:PDFPageRef inContext:imageContext];
    CGContextSetRGBFillColor(context, 1.0,1.0,1.0,1.0);
    CGContextFillRect(context,viewRect);
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 0.0, viewRect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextConcatCTM(context, CGPDFPageGetDrawingTransform(PDFPageRef, kCGPDFMediaBox, viewRect, 0, true));
    CGContextDrawPDFPage(context, PDFPageRef);
    CGContextRestoreGState(context);
	
    //NSImage *pageImage = UIGraphicsGetImageFromCurrentImageContext();
    //CGSize size = [pageImage size];
    NSLog(@"PDF Width %.3f, height %.3f", viewRect.size.width, viewRect.size.height);
	
    //UIGraphicsEndImageContext();
    [pageImage unlockFocus];
	
	return pageImage;
}

@end
