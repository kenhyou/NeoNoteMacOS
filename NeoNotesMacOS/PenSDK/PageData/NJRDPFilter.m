//
//  NJRDPFilter.m
//  NeoNotes
//
//  Created by Sang Nam on 6/13/15.
//  Copyright (c) 2015 Neolabconvergence. All rights reserved.
//

#import "NJRDPFilter.h"


@implementation NJRDPFilter

+ (NSMutableArray *)douglasPeuckerReduction:(NSMutableArray *)points withTolerance:(float)tolerance
{
    if (points == nil || [points count] < 3)
        return points;
    
    NSUInteger firstPoint = 0;
    NSUInteger lastPoint = [points count] - 1;
    
    NSMutableArray * pointIndicesToKeep = [[NSMutableArray alloc] init];
    
    //Add the first and last index to the keepers
    [pointIndicesToKeep addObject:[NSNumber numberWithUnsignedInteger:firstPoint]];
    [pointIndicesToKeep addObject:[NSNumber numberWithUnsignedInteger:lastPoint]];
    
    //The first and the last point cannot be the same
    while ([[points objectAtIndex:firstPoint] equalsTo:[points objectAtIndex:lastPoint]])
    {
        lastPoint--;
        if(lastPoint <= 0) return nil;
    }
    
    NSMutableArray * pointsToKeep = [self douglasPeuckerReduction:points withFirstPoint:firstPoint lastPoint:lastPoint andTolerance:tolerance];
    [pointIndicesToKeep addObjectsFromArray:pointsToKeep];
    
    // Sort the points.
    NSSortDescriptor * sortOptions = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES selector:@selector(compare:)];
    [pointIndicesToKeep sortUsingDescriptors:[NSArray arrayWithObject:sortOptions]];
    
    return pointIndicesToKeep;
}

+ (NSMutableArray *)douglasPeuckerReduction:(NSMutableArray *)points withFirstPoint:(NSUInteger)firstPoint lastPoint:(NSUInteger)lastPoint andTolerance:(float)tolerance
{
    NSMutableArray * pointIndicesToKeep = [[NSMutableArray alloc] init];
    
    float maxDistance = 0.0;
    NSUInteger indexFarthest = 0.0;
    
    for (NSUInteger index = firstPoint; index < lastPoint; index++)
    {
        float distance = [self perpendicularDistanceOf:[points objectAtIndex:index] from:[points objectAtIndex:firstPoint] to:[points objectAtIndex:lastPoint]];
        
        
        if (distance > maxDistance)
        {
            maxDistance = distance;
            indexFarthest = index;
        }
    }
    
    if (maxDistance > tolerance && indexFarthest != 0)
    {
        //Add the largest point that exceeds the tolerance
        [pointIndicesToKeep addObject:[NSNumber numberWithUnsignedInteger:indexFarthest]];
        
        NSMutableArray * leftSide = [self douglasPeuckerReduction:points withFirstPoint:firstPoint lastPoint:indexFarthest andTolerance:tolerance];
        NSMutableArray * rightSide = [self douglasPeuckerReduction:points withFirstPoint:indexFarthest lastPoint:lastPoint andTolerance:tolerance];
        
        [pointIndicesToKeep addObjectsFromArray:leftSide];
        [pointIndicesToKeep addObjectsFromArray:rightSide];
    }
    
    return pointIndicesToKeep;
}

+ (float)perpendicularDistanceOf:(DataPoint *)point from:(DataPoint *)pointA to:(DataPoint *)pointB
{
    //Area = |(1/2)(x1y2 + x2y3 + x3y1 - x2y1 - x3y2 - x1y3)|   *Area of triangle
    //Base = v((x1-x2)²+(x1-x2)²)                               *Base of Triangle*
    //Area = .5*Base*H                                          *Solve for height
    //Height = Area/.5/Base
    
//    float area = fabs(.5 * (pointA.x * pointB.y + pointB.x *
//                             point.y + point.x * pointA.y - pointB.x * pointA.y - point.x *
//                             pointB.y - pointA.x * point.y));
//    float bottom = sqrt(pow(pointA.x - pointB.x, 2) +
//                         pow(pointA.y - pointB.y, 2));
//    float height = area / bottom * 2;
//    
//    return height;
    
    // it is same question that vector distance from one point to line A-B
    float x0,y0,z0;
    float x1,y1,z1;
    float px,py,pz;
    
    
//    pointA = [[DataPoint alloc] initWithX:-1 andY:0 andP:7];
//    pointB = [[DataPoint alloc] initWithX:3 andY:1 andP:5];
//    point = [[DataPoint alloc] initWithX:2 andY:-1 andP:2];
    
    x0 = pointA.x;
    y0 = pointA.y;
    z0 = pointA.p;
    
    x1 = pointB.x;
    y1 = pointB.y;
    z1 = pointB.p;
    
    px = point.x;
    py = point.y;
    pz = point.p;
    
    float vx,vy,vz; // direction vector
    vx = x1 - x0;
    vy = y1 - y0;
    vz = z1 - z0;
    
    float ax,ay,az;
    ax = x0 - px;
    ay = y0 - py;
    az = z0 - pz;
    
    float t = -(ax * vx + ay * vy + az * vz) / (vx * vx + vy * vy + vz * vz);
    
    float hx,hy,hz;
    hx = x0 + vx * t;
    hy = y0 + vy * t;
    hz = z0 + vz * t;
    
    float d = sqrtf(powf((hx-px),2) + powf((hy-py),2) + powf((hz-pz), 2));

    return d;
    // vector line A-B that is passing point A is ...
    // point H is lying above line
    // the vector H to P(x,y,z) is...
    
}

@end



@implementation DataPoint
@synthesize x;
@synthesize y;

- (id)initWithX:(float)xValue andY:(float)yValue andP:(float)pValue
{
    self.x = xValue;
    self.y = yValue;
    self.p = pValue;
    
    return self;
}

- (BOOL)equalsTo:(DataPoint *)point
{
    if (point == nil)
        return NO;
    
    return (point.x == self.x && point.y == self.y);
}

@end
