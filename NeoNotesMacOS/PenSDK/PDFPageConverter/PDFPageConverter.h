//
//  PDFPageConverter.h
//
//  Created by Sorin Nistor on 3/23/11.
//  Copyright 2011 iPDFdev.com. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PDFPageConverter : NSObject {

}

+ (NSImage *) convertPDFPageToImage: (CGPDFPageRef) page withResolution: (float) resolution;

@end
