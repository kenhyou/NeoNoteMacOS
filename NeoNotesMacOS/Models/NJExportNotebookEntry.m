//
//  NJExportNotebookEntry.m
//  NeoNotes
//
//  Created by NamSang on 13/04/2015.
//  Copyright (c) 2015 Neolabconvergence. All rights reserved.
//

#import "NJExportNotebookEntry.h"

@implementation NJExportNotebookEntry

- (BOOL)isEqual:(id)object
{
    NJExportNotebookEntry *entry = (NJExportNotebookEntry *)object;
    
    if([self.identifier isEqualToString:entry.identifier]) return YES;
    
    return NO;
}

- (id)initWithEntry:(NJExportNotebookEntry *)entry
{
    
    /*
     @property (nonatomic) BOOL isServerItem;
     @property (nonatomic, strong) NSString *notebookUuid;
     @property (nonatomic, strong) NSString *notebookGuid;
     @property (nonatomic) NSInteger noteType;
     @property (nonatomic, strong) NSString *identifier;
     @property (nonatomic, strong) NSString *notebookTitle;
     @property (nonatomic, strong) UIImage *notebookCover;
     @property (nonatomic, strong) NSDate *dateCreated;
     @property (nonatomic, strong) NSDate *dateModified;
     @property (nonatomic, strong) NSDate *dateUploaded;
     @property (nonatomic, strong) NSString *downloadURL;
     @property (nonatomic) long long fileSize;
     @property (nonatomic) NSUInteger numberOfTags;
     @property (nonatomic) NSUInteger numberOfVMs;
     @property (nonatomic) NSUInteger numberOfPages;
     @property (nonatomic) BOOL enabled;
     @property (nonatomic) BOOL editable;
     @property (nonatomic) NJExportTargetStorage targetStorage;
     */
    
    
    self.isServerItem = entry.isServerItem;
    self.notebookUuid = (entry.notebookUuid != nil)? [entry.notebookUuid copy] : nil;
    self.notebookGuid = (entry.notebookGuid != nil)? [entry.notebookGuid copy]: nil;;
    self.noteType = entry.noteType;
    self.identifier = (entry.identifier != nil)? [entry.identifier copy] : nil;;
    self.notebookTitle = (entry.notebookTitle != nil)? [entry.notebookTitle copy] : nil;;
    self.notebookCover = (entry.notebookCover != nil)? entry.notebookCover : nil;;
    self.dateCreated = (entry.dateCreated != nil)? entry.dateCreated : nil;;
    self.dateModified = (entry.dateModified != nil)? entry.dateModified : nil;;
    self.dateUploaded = (entry.dateUploaded != nil)? entry.dateUploaded : nil;;
    self.downloadURL = (entry.notebookUuid != nil)? entry.notebookUuid : nil;;
    self.fileSize = entry.fileSize;
    self.numberOfTags = entry.numberOfTags;
    self.numberOfVMs = entry.numberOfVMs;
    self.numberOfPages = entry.numberOfPages;
    self.enabled = entry.enabled;
    self.editable = entry.editable;
    self.targetStorage = entry.targetStorage;
    
    return self;
}

@end
