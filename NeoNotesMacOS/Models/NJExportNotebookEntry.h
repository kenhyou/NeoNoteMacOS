//
//  NJExportNotebookEntry.h
//  NeoNotes
//
//  Created by NamSang on 13/04/2015.
//  Copyright (c) 2015 Neolabconvergence. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSInteger, NJExportTargetStorage) {
    NJExportTargetStorageNotebooks,
    NJExportTargetStorageNoteBox
};

@interface NJExportNotebookEntry : NSObject

@property (nonatomic) BOOL isServerItem;
@property (nonatomic, strong) NSString *notebookUuid;
@property (nonatomic, strong) NSString *notebookGuid;
@property (nonatomic) NSInteger noteType;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *notebookTitle;
@property (nonatomic, strong) NSImage *notebookCover;
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

- (id)initWithEntry:(NJExportNotebookEntry *)entry;

@end
