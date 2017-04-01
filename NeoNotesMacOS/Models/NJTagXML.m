//
//  NJTagXML.m
//  NeoNotes
//
//  Created by NamSang on 6/04/2015.
//  Copyright (c) 2015 Neolabconvergence. All rights reserved.
//

#import "NJTagXML.h"


#define kTagXMLName             @"tag_xml_name"
#define kTagXMLPageNum          @"tag_xml_pagenum"
#define kTagXMLDateCreated      @"tag_xml_date_created"

@implementation NJTagXML


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if(self) {
        
        [self setTagName:[aDecoder decodeObjectForKey:kTagXMLName]];
        [self setPageNum:[aDecoder decodeIntegerForKey:kTagXMLPageNum]];
        [self setDateCreated:[aDecoder decodeObjectForKey:kTagXMLDateCreated]];
    }
    
    return self;
}


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    
    [aCoder encodeObject:_tagName forKey:kTagXMLName];
    [aCoder encodeInteger:_pageNum forKey:kTagXMLPageNum];
    [aCoder encodeObject:_dateCreated forKey:kTagXMLDateCreated];
}
@end
