//
//  NeoNotebookInfo.m
//  NeoNotes
//
//  Created by NamSang on 12/01/2016.
//  Copyright © 2016 Neolabconvergence. All rights reserved.
//

#import "NPNotebookInfo.h"

@implementation NPNotebookInfo

- (instancetype)init
{
    self = [super init];
    
    if(self) {
        self.pages = [NSMutableDictionary dictionary];
    }
    return self;
}
@end


