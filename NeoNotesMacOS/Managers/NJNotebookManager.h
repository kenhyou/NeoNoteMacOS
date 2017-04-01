//
//  NJNotebookManager.h
//  NeoJournal
//
//  Copyright (c) 2014 Neolab. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * NJNoteBookPageDocumentOpenedNotification;
static NSString * NJNoteobokManagerDidNotebookRecoverNotification = @"NJNoteobokManagerDidNotebookRecoverNotification";
static NSString * NJNoteobokManagerDidActivePageRecoverNotification = @"NJNoteobokManagerDidActivePageRecoverNotification";

@interface NJPageImageOperation: NSOperation
@property (strong, nonatomic) NSString *notebookUuid;
@property (nonatomic) NSUInteger pageNum;
- (instancetype)initWithPageNum:(NSUInteger)pageNum notebookUuid:(NSString *)notebookUuid;
@end

@class NJPageDocument;

typedef enum {
    kNotebookPageSortByName=0,
    kNotebookPageSortByDate,
} NotebookPageSortRule;

@interface NJNotebookManager : NSObject
@property (strong, nonatomic) NSMutableDictionary *notebookPages;
@property (copy, nonatomic) NSString *activeNotebookUuid;
@property (strong, nonatomic) NJPageDocument *activePageDocument;
@property (nonatomic) NSUInteger activeNoteBookId;
@property (nonatomic) NSUInteger activePageNumber;
@property (strong, nonatomic, readonly) NSArray *realNotebookList;
@property (strong, nonatomic, readonly) NSArray *digitalNotebookList;
@property (strong, nonatomic, readonly) NSArray *totalNotebookList;
@property (strong, nonatomic, readonly) NSArray *activeNotebookList;
@property (strong, nonatomic, readonly) NSArray *archiveNotebookList;
@property (nonatomic) BOOL documentOpend;

- (NSString *) documentDirectory;

//Page related
- (NSString *) notebookPathForUuid:(NSString *) uuid;
- (NSString *) pageNameFromNumber:(NSUInteger)number;
- (NSURL *) urlForName:(NSString *)name;
- (NSArray *) notebookPagesSortedBy:(NotebookPageSortRule)rule;
- (NSDictionary *) pageInfoForPageNumber:(NSUInteger) number;
- (void) activeNotebookIdDidChange:(NSUInteger)notebookId withPageNumber:(NSUInteger)pageNumber;

//- (NSArray *) filterPages:(NSArray *)pages;
- (void) syncSetActivePageNumber:(NSUInteger)activePageNumber;
- (void) syncReload;

- (BOOL)isActiveNotebook:(NSString *)notebookUuid;
- (BOOL)isActivePageNum:(NSUInteger)pageNum andNotebookUuid:(NSString *)notebookUuid;
- (NSArray *)getPagesForNotebookUuid:(NSString *)notebookUuid;
- (NJPageDocument *)pageWithName:(NSString *)name;
- (NJPageDocument *)getPageDocument:(NSUInteger)pageNum forNotebookUuid:(NSString *)notebookUuid;
- (NSString *)getPagePath:(NSUInteger)pageNum forNotebookUuid:(NSString *)notebookUuid;
- (BOOL)checkIfNoteExists:(NSUInteger)pageNum forNotebookUuid:(NSString *)notebookUuid;

- (void) closeCurrentNotebook;
//- (void) closeCurrentNotebookWithCompBlock:(void (^)(BOOL))sblock;
@end
