//
//  NJRDPFilter.h
//  NeoNotes
//
//  Created by Sang Nam on 6/13/15.
//  Copyright (c) 2015 Neolabconvergence. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DataPoint : NSObject

@property (assign, nonatomic) float x;
@property (assign, nonatomic) float y;
@property (assign, nonatomic) float p;

- (id)initWithX:(float)xValue andY:(float)yValue andP:(float)pValue;
- (BOOL)equalsTo:(DataPoint *)point;

@end


@interface NJRDPFilter : NSObject


+ (NSMutableArray *)douglasPeuckerReduction:(NSMutableArray *)points withTolerance:(float)tolerance;

@end
