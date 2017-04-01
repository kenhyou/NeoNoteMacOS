//
//  NJNotebookInfo.m
//  NeoJournal
//
//  Created by NamSSan on 10/08/2014.
//  Copyright (c) 2014 Neolab. All rights reserved.
//

#import "NJNotebookInfo.h"
#import "NJCoverManager.h"

#define kMAX_NOTEBOOK_TITLE_LENGTH      25
#define kNotebookInfoNoteId             @"notoobkinfo_note_id"
#define kNotebookInfoNoteUuid           @"notoobkinfo_note_uuid"
#define kNotebookInfoNoteGuid           @"notoobkinfo_note_guid"
#define kNotebookInfoTotNoPages         @"notoobkinfo_tot_num_pages"
#define kNotebookInfoNoteTitle          @"notoobkinfo_note_title"
#define kNotebookInfoCreatedDate        @"notoobkinfo_created_date"
#define kNotebookInfoLastModifiedDate   @"notoobkinfo_modified_date"
#define kNotebookInfoTimeTitleModified  @"notoobkinfo_time_title_modifed"
#define kNotebookInfoArchivedDate       @"notoobkinfo_archived_date"
#define kNotebookInfoCoverImage         @"notoobkinfo_cover_image"


@implementation NJNotebookInfo


- (id)init
{
    self = [super init];
    
    if(self) {
        
        _createdDate = [NSDate date];
        _lastModifiedDate = [NSDate date];
        _timeTitleModifed = [NSDate date];
    }
    
    return self;
}



- (id)initWithCoder:(NSCoder *)aDecoder
{
    
    self = [super init];
    
    if(self) {
        
        [self setNotebookId:[aDecoder decodeIntegerForKey:kNotebookInfoNoteId]];
        [self setNotebookUuid:[aDecoder decodeObjectForKey:kNotebookInfoNoteUuid]];
        [self setNotebookGuid:[aDecoder decodeObjectForKey:kNotebookInfoNoteGuid]];
        [self setTotNoPages:[aDecoder decodeIntegerForKey:kNotebookInfoTotNoPages]];
        [self setNotebookTitle:[aDecoder decodeObjectForKey:kNotebookInfoNoteTitle]];
        [self setCreatedDate:[aDecoder decodeObjectForKey:kNotebookInfoCreatedDate]];
        [self setLastModifiedDate:[aDecoder decodeObjectForKey:kNotebookInfoLastModifiedDate]];
        _timeTitleModifed = [aDecoder decodeObjectForKey:kNotebookInfoTimeTitleModified];
        [self setArchivedDate:[aDecoder decodeObjectForKey:kNotebookInfoArchivedDate]];
        [self setCoverImage:[aDecoder decodeObjectForKey:kNotebookInfoCoverImage]];

    }
    
    return self;
}




- (void)encodeWithCoder:(NSCoder *)aCoder
{
    
    [aCoder encodeInteger:_notebookId forKey:kNotebookInfoNoteId];
    [aCoder encodeObject:_notebookUuid forKey:kNotebookInfoNoteUuid];
    [aCoder encodeObject:_notebookGuid forKey:kNotebookInfoNoteGuid];
    [aCoder encodeInteger:_totNoPages forKey:kNotebookInfoTotNoPages];
    [aCoder encodeObject:_notebookTitle forKey:kNotebookInfoNoteTitle];
    [aCoder encodeObject:_createdDate forKey:kNotebookInfoCreatedDate];
    [aCoder encodeObject:_lastModifiedDate forKey:kNotebookInfoLastModifiedDate];
    [aCoder encodeObject:_timeTitleModifed forKey:kNotebookInfoTimeTitleModified];
    [aCoder encodeObject:_archivedDate forKey:kNotebookInfoArchivedDate];
    [aCoder encodeObject:_coverImage forKey:kNotebookInfoCoverImage];
    
}

- (void)setNotebookTitle:(NSString *)notebookTitle
{
    if(isEmpty(notebookTitle)) return;
    
    NSString *newTitle = [notebookTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    newTitle = [newTitle stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    
    if(newTitle.length > kMAX_NOTEBOOK_TITLE_LENGTH)
        newTitle = [newTitle substringToIndex:kMAX_NOTEBOOK_TITLE_LENGTH];
    
    _timeTitleModifed = [NSDate date];
    _notebookTitle = newTitle;
}

/*
- (UIImage *)coverImage
{
    UIImage *image = _coverImage;
    
    if(isEmpty(image)) {
        
        image = [NJCoverManager getCoverResourceImage:_notebookId];
        
    } else {
        
        NSLog(@"i have own image");
    }
    
    return image;
}
*/


@end
