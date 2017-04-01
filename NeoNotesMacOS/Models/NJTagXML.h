//
//  NJTagXML.h
//  NeoNotes
//
//  Created by NamSang on 6/04/2015.
//  Copyright (c) 2015 Neolabconvergence. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NJTagXML : NSObject <NSCoding>

@property (strong, nonatomic) NSString *tagName;
@property (nonatomic) NSUInteger pageNum;
@property (strong, nonatomic) NSDate *dateCreated;

@end
