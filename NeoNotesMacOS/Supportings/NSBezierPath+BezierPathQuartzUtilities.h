//
//  NSBezierPath.h
//  NeoNotesMacOS
//
//  Created by Ken You on 19/10/2016.
//  Copyright © 2016 Neolabconvergence. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSBezierPath(BezierPathQuartzUtilities)
- (CGPathRef)quartzPath;
- (CGPathRef)CGPath;
@end
