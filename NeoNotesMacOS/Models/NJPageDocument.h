//
//  NJDocument.h
//  NeoJournal
//
//  Copyright (c) 2014 Neolab. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "NJPage.h"

#define OPEN_NOTEBOOK_SYNC_MODE

@class NJNotebookPaperInfo;
@interface NJPageDocument : NSDocument
@property (strong, nonatomic) NJPage *page;
@property (strong, nonatomic) NJNotebookPaperInfo *paperInfo;

- (void) strokeAdded:(NSNotification *)notification;
- (id) initWithFileURL:(NSURL *)url withBookId:(NSUInteger)bookId andPageNumber:(NSUInteger)pageNumber andNotebookUuid:(NSString *)notebookUuid;
- (void) autosaveInBackground;
- (void) pageSaveToURL:(NSURL *)url completionHandler:(void (^)(BOOL))completionHandler;
- (void)forceDocumentSavingShouldCreating:(BOOL)create completionHandler:(void (^)(BOOL success))completionHandler;
- (BOOL) readFromURL:(NSURL *)url error:(NSError *__autoreleasing *)outError;
@end
