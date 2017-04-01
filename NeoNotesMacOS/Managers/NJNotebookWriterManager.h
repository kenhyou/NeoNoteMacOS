//
//  NJNotebookWriterManager.h
//  NeoJournal
//
//  Created by Ken on 14/02/2014.
//  Copyright (c) 2014 Neolab. All rights reserved.
//

#import "NJNotebookManager.h"
#import "NJPageDocument.h"

@interface NJNotebookWriterManager : NJNotebookManager <NJCommParserDocumentHandler>
//@property (nonatomic) NSUInteger activePageNumber;
//@property (strong, nonatomic) NJPageDocument *activePageDocument;

+ (NJNotebookWriterManager *) sharedInstance;
- (void) saveCurrentPage; // crate logs.. creating = NO
- (void) saveCurrentPage:(BOOL)force completionHandler:(void (^)(BOOL success))completionHandler; // creating = NO
- (void) saveCurrentPage:(BOOL)force shouldCreating:(BOOL)create completionHandler:(void (^)(BOOL))completionHandler;
- (void) saveCurrentPageWithEventlog:(BOOL)log andEvernote:(BOOL)evernote andLastStrokeTime:(NSDate *)lastStrokeTime;
- (void) saveEventlog:(BOOL)log andEvernote:(BOOL)evernote andLastStrokeTime:(NSDate *)lastStrokeTime;
- (void) syncOpenNotebook:(NSUInteger)notebookId withPageNumber:(NSUInteger)pageNumber;
- (void) syncOpenNotebook:(NSUInteger)notebookId withPageNumber:(NSUInteger)pageNumber saveNow:(BOOL)saveNow;
- (NSArray *) copyPages:(NSArray *)pageArray fromNotebook:(NSString *)fNotebookUuid toNotebook:(NSString *)tNotebookUuid;
- (NSArray *) deletePages:(NSArray *)pageArray fromNotebook:(NSString *)notebookUuid;
- (BOOL) deleteNotebook:(NSString *)notebookUuid;
- (void) findRecoverTemporalNotebooks;
- (NJPage *)createNewPageForNotebookId:(NSUInteger)notebookId pageNum:(NSUInteger)pageNum lastStrokeTime:(NSDate *)lastStrokeTime resetActivePage:(BOOL)resetActivePage;
//jr
- (void) checkRecoverCurrentActivePage;
@end
