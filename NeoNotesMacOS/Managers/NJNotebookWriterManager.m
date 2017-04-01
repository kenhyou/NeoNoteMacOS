//
//  NJNotebookWriterManager.m
//  NeoJournal
//
//  Created by Ken on 14/02/2014.
//  Copyright (c) 2014 Neolab. All rights reserved.
//

#import "NJNotebookWriterManager.h"
#import "NJNotebookReaderManager.h"
#import "NJVoiceManager.h"
#import "NJPageDocument.h"
#import "NJNotebookIdStore.h"
#import "NPPaperManager.h"
#import "NJNotebookInfo.h"
#import "NJNotebookIdStore.h"
#import "NJNotebookInfoStore.h"
#import "NJNotebookReaderManager.h"

extern NSString *NJNoteBookPageExtension;
NSString * NJNotebookClosedNotification = @"NJNotebookClosedNotification";

@implementation NJNotebookWriterManager
{
    NSTimer *_autosavingTimer4Sync;
    dispatch_queue_t document_dispatch_queue;
    NSOperationQueue *_pageImgQueue;
    BOOL _recoverCurrentActivePage;
}

+ (NJNotebookWriterManager *) sharedInstance
{
    static NJNotebookWriterManager *shared = nil;
    
    @synchronized(self) {
        if(!shared){
            shared = [[NJNotebookWriterManager alloc] init];
        }
    }
    
    return shared;
}

- (instancetype) init
{
    self = [super init];
    
    if(self) {
        self.activeNoteBookId = 0;
        self.activePageNumber = 0;
        
        _autosavingTimer4Sync = nil;
        document_dispatch_queue = dispatch_queue_create("document_dispatch_queue", DISPATCH_QUEUE_SERIAL);
//        _pageImgQueue = [[NSOperationQueue alloc] init];
//        _pageImgQueue.name = @"Page Image Creating Queue";
//        _pageImgQueue.maxConcurrentOperationCount = 1;
        
        [[NJPenCommManager sharedInstance] setPenCommParserDocumentHandler:self];
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        //[nc addObserver:self selector:@selector(penConnectionChanged:) name:NPCommManagerPenConnectionStatusChangeNotification object:nil];
        [nc addObserver:self selector:@selector(recoverPages:) name:NPPaperInfoStorePaperBecomeAvailableNotification object:nil];
        
    }
    return self;
}

- (void) saveCurrentPage
{
    [self saveCurrentPageWithEventlog:YES andEvernote:NO andLastStrokeTime:nil];
}
- (void) saveCurrentPageWithEventlog:(BOOL)log andEvernote:(BOOL)evernote andLastStrokeTime:(NSDate *)lastStrokeTime
{
    [self saveCurrentPage:YES completionHandler:nil];
}
- (void) saveEventlog:(BOOL)log andEvernote:(BOOL)evernote andLastStrokeTime:(NSDate *)lastStrokeTime
{
}

- (void) saveCurrentPage:(BOOL)force completionHandler:(void (^)(BOOL))completionHandler
{
    [self saveCurrentPage:force shouldCreating:NO completionHandler:completionHandler];
}
- (void) saveCurrentPage:(BOOL)force shouldCreating:(BOOL)create completionHandler:(void (^)(BOOL))completionHandler
{
    if(isEmpty(self.activePageDocument)) {
        if(completionHandler)
            completionHandler(NO);
        return;
    }
    if(force)
        [self.activePageDocument forceDocumentSavingShouldCreating:create completionHandler:completionHandler];
    else
        [self.activePageDocument autosaveInBackground];
}
- (void) activeNotebookIdDidChange:(NSUInteger)notebookId withPageNumber:(NSUInteger)pageNumber
{
#ifdef OPEN_NOTEBOOK_SYNC_MODE
    [self syncOpenNotebook:notebookId withPageNumber:pageNumber];
#else
    [super activeNotebookIdDidChange:notebookId withPageNumber:pageNumber];
#endif
}
- (void) syncOpenNotebook:(NSUInteger)notebookId withPageNumber:(NSUInteger)pageNumber
{
    [self syncOpenNotebook:notebookId withPageNumber:pageNumber saveNow:NO];
}
- (void) syncOpenNotebook:(NSUInteger)notebookId withPageNumber:(NSUInteger)pageNumber saveNow:(BOOL)saveNow
{
    if (self.activeNoteBookId == notebookId && self.activePageNumber == pageNumber) {
        return;
    }
    if (saveNow) {
        [self.activePageDocument forceDocumentSavingShouldCreating:NO completionHandler:nil];
    }
    else
        [self saveCurrentPage];
    [self setActiveNoteBookId:notebookId];
    // 06-Oct-2014 by namSSan currently writer only accessed by penCommManager so pen does not need note uuid.
    // just set it as current activie Uuid
    NSString *nUuid = [[[NJNotebookIdStore sharedStore] notebookIdName:notebookId] copy];
    if(!isEmpty(self.activeNotebookUuid) && (![self.activeNotebookUuid isEqualToString:nUuid]) && [NJVoiceManager sharedInstance].isRecording)
       [[NJVoiceManager sharedInstance] stopRecording];
    self.activeNotebookUuid = nUuid;
    [self syncSetActivePageNumber:pageNumber];
}
- (NJPageDocument *) pageDocumentAtNumber:(NSUInteger)number
{
    NSString *pageName = [self pageNameFromNumber:number];
    if (!pageName) return nil;
    /*
     NJPageDocument *doc = (NJPageDocument *)[self.notebookPages objectForKey:[NSNumber numberWithInt:(int)number]];
     if (!doc) {
     if((doc = [self createNewPageForNumber:number]))
     [self.notebookPages setObject:doc forKey:[NSNumber numberWithInt:(int)number]];
     }
     */
    NJPageDocument *doc = [self pageWithName:pageName];
    return doc;
}



- (NSString *) pagePath:(NSUInteger)pageNum forNotebookUuid:(NSString *)notebookUuid
{
    NSString *notebookPath = [self notebookPathForUuid:notebookUuid];
    NSString *pageName = [self pageNameFromNumber:pageNum];
    NSString *pagePath = [[notebookPath stringByAppendingPathComponent:pageName] stringByAppendingPathExtension:NJNoteBookPageExtension];
    
    return pagePath;
}

- (NSArray *) copyPages:(NSArray *)pageArray fromNotebook:(NSString *)fNotebookUuid toNotebook:(NSString *)tNotebookUuid
{
    
    if(isEmpty(pageArray) &&([fNotebookUuid isEqualToString:tNotebookUuid])) return nil;
    
    // check toNotebookId is digital notebook
    // currently digital notebook id is numbered over 900
    
    if(![NJNotebookIdStore isDigitalNote:tNotebookUuid]) return nil;
    
    NSMutableArray *copyPageArray = [NSMutableArray array];
    
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *notebookPath = [self notebookPathForUuid:fNotebookUuid];
    NSString *destNotbookPath = [self notebookPathForUuid:tNotebookUuid];
    
    NSArray *pages = [self getPagesForNotebookUuid:tNotebookUuid];
    
    // get last page number

    NSInteger index = pages.count -1;
    NSUInteger lastPageNum = 0;
    
    if(index >= 0)
        lastPageNum = [[pages objectAtIndex:index] integerValue];
    
    for(int i=0; i < pageArray.count; i++) {
        
        NSString *pageName = [pageArray objectAtIndex:i];
        NSString *dPageName = [self pageNameFromNumber:(++lastPageNum)];
        NSString *path = [[notebookPath stringByAppendingPathComponent:pageName] stringByAppendingPathExtension:NJNoteBookPageExtension];
        NSString *destPath = [[destNotbookPath stringByAppendingPathComponent:dPageName] stringByAppendingPathExtension:NJNoteBookPageExtension];
        
        NSString *dataPath = [path stringByAppendingPathComponent:@"page.data"];
       // NSString *imgPath = [path stringByAppendingPathComponent:@"thumb.jpg"];
        
        if ([fm fileExistsAtPath:dataPath]/* && [fm fileExistsAtPath:imgPath]*/) {

            if([fm copyItemAtPath:path toPath:destPath error:nil]) {
                
                [copyPageArray addObject:pageName];
            }
            
        } else {
            
            continue;
        }
    }
    
    // nothing was copied
    if(copyPageArray.count == 0)
        return nil;
    else {
        //[NJEventLogStore sharedStore] c
        return copyPageArray;
    }
}
- (void)closeCurrentNotebook
{
    [super closeCurrentNotebook];
    [[NSNotificationCenter defaultCenter] postNotificationName:NJNotebookClosedNotification object:nil userInfo:nil];
}
- (BOOL) deleteNotebook:(NSString *)notebookUuid
{
    if(isEmpty(notebookUuid)) return NO;
    
    NSArray *pages = [self getPagesForNotebookUuid:notebookUuid];

    if(!isEmpty(pages)) {
    
        NSUInteger pageCount = pages.count;
        NSArray *deletedPages = [self deletePages:pages fromNotebook:notebookUuid];
        
        if(pageCount != deletedPages.count) return NO;
    }
    // now try to delete forder
    [[NJNotebookIdStore sharedStore] removeNotebook:notebookUuid];
    NSString *fullPath = [self notebookPathForUuid:notebookUuid];
    [[NSFileManager defaultManager] removeItemAtPath:fullPath error:nil];
    
    
    return YES;
}
- (NSArray *) deletePages:(NSArray *)pageArray fromNotebook:(NSString *)notebookUuid
{
    
    if(isEmpty(pageArray)) return nil;
    
    NSMutableArray *deletePageArray = [NSMutableArray array];
    
    for(int i=0; i < pageArray.count; i++) {
        
        //** UIDocument automatically care about file interested parties (file coordinators)
        // deal with shared file accessed by multiple threads.
        /*
         [document closeWithCompletionHandler:^(BOOL success){
         if([[NSFileManager defaultManager] fileExistsAtPath:[document.fileURL path]]){
         [[NSFileManager defaultManager] removeItemAtURL:document.fileURL error:nil];
         }
         */
        NSString *pageName = [pageArray objectAtIndex:i];
        
        BOOL isActive = [self isActivePageNum:[pageName integerValue] andNotebookUuid:notebookUuid];
        __block BOOL success = NO;
        
        if(isActive) {
            /*
            [self closeCurrentNotebookWithCompBlock:^(BOOL closed) {
                
                if(closed)
                    success = [self _deletePageName:pageName forNotebookUuid:notebookUuid];
                
            }];
             */
            [self closeCurrentNotebook];
            [[NJNotebookReaderManager sharedInstance] closeCurrentNotebook];
            
        } else {
            //success = [self _deletePageName:pageName forNotebookUuid:notebookUuid];
        }
        success = [self _deletePageName:pageName forNotebookUuid:notebookUuid];
        
        if(success)
            [deletePageArray addObject:pageName];
        
        
    }
    
    // nothing was deleted
    if(deletePageArray.count == 0)
        return nil;
    else {
        
        //NSString *pageStr = [MyFunctions generatePageStr:deletePageArray];
        //[[NJEventLogStore sharedStore] createLogDeletionWithNoteUuid:notebookUuid andPages:pageStr];
        return deletePageArray;
        
    }
}
- (BOOL)_deletePageName:(NSString *)pageName forNotebookUuid:(NSString *)notebookUuid
{
    //NSString *pageName = [pageArray objectAtIndex:i];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *notebookPath = [self notebookPathForUuid:notebookUuid];
    
    NSString *path = [[notebookPath stringByAppendingPathComponent:pageName] stringByAppendingPathExtension:NJNoteBookPageExtension];
    
    NSString *dataPath = [path stringByAppendingPathComponent:@"page.data"];
    NSString *imgPath = [path stringByAppendingPathComponent:@"image.jpg"];
    
    if ([fm fileExistsAtPath:dataPath] /*&& [fm fileExistsAtPath:imgPath]*/) {
        
        if(![fm removeItemAtPath:path error:nil])
            return NO;
        
        [NJVoiceManager deleteAllVoiceMemoForNoteUUid:notebookUuid andPageNum:[pageName integerValue]];
        
    }
    
    return YES;
}

- (void)recoverCurrentActivePage_
{
    NSUInteger curNotebookId = self.activeNoteBookId;
    NSUInteger curPageNum = self.activePageNumber;
    //NSUInteger curSection = self.activeSectionId;
    //NSUInteger curOwner = self.activeOwnerId;
    [self saveActivePageWithCompletionHandler:^(BOOL success) {
        [self closeCurrentNotebook];
        //[self syncOpenNotebook_:curNotebookId pageNum:curPageNum section:curSection owner:curOwner shouldNotify:NO];
        [self syncOpenNotebook:curNotebookId withPageNumber:curPageNum saveNow:NO];
        [[NSNotificationCenter defaultCenter] postNotificationName:NJNoteobokManagerDidActivePageRecoverNotification object:nil userInfo:nil];
    }];
}
- (void)addStroke:(NJStroke *)stroke
{
    //if(!self.activePage) return;
    if(!self.activePageDocument.page) return;
    
#define AUTOSAVE_TIMER_INTERVAL 10.0f
    if (_autosavingTimer4Sync == nil) {
        _autosavingTimer4Sync = [NSTimer timerWithTimeInterval:AUTOSAVE_TIMER_INTERVAL target:self
                                                      selector:@selector(saveActivePage_) userInfo:nil repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:_autosavingTimer4Sync forMode:NSDefaultRunLoopMode];
    }
    
    //NJStroke *aStroke = [[NJStroke alloc] initWithStroke:stroke];
    //[self.activePage addStroke:aStroke];
    [self.activePageDocument.page addStroke:stroke];
    
    if(_recoverCurrentActivePage) {
        _recoverCurrentActivePage = NO;
        [self recoverCurrentActivePage_];
    }
}

- (void)checkRecoverCurrentActivePage {
    
    if(_recoverCurrentActivePage) {
        NSString *curNotebookUuid = self.activeNotebookUuid;
        NSUInteger curPageNum = self.activePageNumber;
        NJNotebookReaderManager *reader = [NJNotebookReaderManager sharedInstance];
        NSString *pagePath = [reader getPagePath:curPageNum forNotebookUuid:curNotebookUuid];
        NJPage *page = [reader getPageData:curPageNum notebookUuid:curNotebookUuid];
        NSImage *image = [page createPageImageSmall:[NSURL URLWithString:pagePath]];
        
        
        _recoverCurrentActivePage = NO;
        [self recoverCurrentActivePage_];

    }
}

- (void)stopAutoSavingTimer
{
    [_autosavingTimer4Sync invalidate];
    _autosavingTimer4Sync = nil;
}
- (void)saveActivePage_
{
    [self saveActivePageWithCompletionHandler:nil];
}
- (void) saveActivePageWithCompletionHandler:(void (^)(BOOL success))completionHandler
{
    [self stopAutoSavingTimer];
    
    dispatch_async(document_dispatch_queue, ^{
        
        BOOL success = NO;
        if(!isEmpty(self.activePageDocument.page))
            success = [self.activePageDocument.page saveToURL:nil];
        
        if(success) {
           
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(completionHandler)
                completionHandler(success);
        });
        
    });
}

static BOOL recoveryLock = NO;
static NSDate *lastRecoveryTime = nil;
- (void)findRecoverTemporalNotebooks
{
    //if(!self.appInitialized) return;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self findRecoverTemporalNotebooksForKeyName_:nil];
    });
}
- (void) recoverPages:(NSNotification *)notification
{
    //if(!self.appInitialized) return;
    NSString *keyName = [[notification userInfo] objectForKey:@"keyName"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self findRecoverTemporalNotebooksForKeyName_:keyName];
    });
}

- (void)findRecoverTemporalNotebooksForKeyName_:(NSString *)keyName
{
    if(recoveryLock) return;
    BOOL searchAllTemporal = (keyName == nil);
    if(searchAllTemporal && lastRecoveryTime && ([[NSDate date] timeIntervalSinceDate:lastRecoveryTime] < 30)) return;
    
    recoveryLock = YES;
    if(searchAllTemporal) lastRecoveryTime = [NSDate date];
    //NJNotebookReaderManager *reader = [NJNotebookReaderManager sharedInstance];
    //NSArray *notebookList = [reader activeNotebookList];
    NSArray *notebookList = [self activeNotebookList];
    BOOL anyNotebookRecovered = NO;
    
    for(NSString *notebookUuid in notebookList) {
        NSUInteger section, owner;
        NSUInteger notebookId = [NJNotebookIdStore noteIdFromUuid:notebookUuid];
        [NPPaperManager section:&section owner:&owner fromNotebookId:notebookId];
        NSString *keyNameDB = [NPPaperManager keyNameForNotebookId:notebookId section:section owner:owner];
        NJNotebookInfo *notebookInfo = [[NJNotebookInfoStore sharedStore] getNotebookInfo:notebookUuid];
        
        if(![[NPPaperManager sharedInstance] hasPaperInfoForKeyName:keyNameDB] || ![notebookInfo.notebookTitle containsString:@"Unknown"]) continue;
        if(![NJNotebookIdStore isDigitalNote:notebookUuid]) {
            //NSArray *pages = [reader getPagesForNotebookUuid:notebookUuid];
            NSArray *pages = [self getPagesForNotebookUuid:notebookUuid];
            for(NSString *pageStr in pages) {
                NSUInteger pageNum = [pageStr integerValue];
                if([self isActivePageNum:pageNum andNotebookUuid:notebookUuid])
                    _recoverCurrentActivePage = YES;
                else
                    [self recoverPageImageAsync_:pageNum notebookUuid:notebookUuid];
                //[[NJNotebookReaderManager sharedInstance] createAsyncPageThumbnail:pageNum notebookUuid:notebookUuid];
            }
        }
    }
    
    if(!searchAllTemporal){
        BOOL anyNotebookRecovered = NO;
        for(NSString *notebookUuid in notebookList) {
            if(![NJNotebookIdStore isDigitalNote:notebookUuid]) {
                NJNotebookInfo *notebookInfo = [[NJNotebookInfoStore sharedStore] getNotebookInfo:notebookUuid];
                
                NSUInteger section, owner;
                NSUInteger notebookId = [NJNotebookIdStore noteIdFromUuid:notebookUuid];
                [NPPaperManager section:&section owner:&owner fromNotebookId:notebookId];
                NSString *keyNameDB = [NPPaperManager keyNameForNotebookId:notebookId section:section owner:owner];
                if ([keyName isEqualToString:keyNameDB] && [[NPPaperManager sharedInstance] hasPaperInfoForKeyName:keyNameDB]) {
                    if (notebookInfo.notebookTitle && [notebookInfo.notebookTitle containsString:@"Unknown"]) {
                        anyNotebookRecovered = YES;
                        NPNotebookInfo *neoNotebookInfo = [[NPPaperManager sharedInstance] getNotebookInfoForKeyName:keyNameDB];
                        NSString *notebookTitle = neoNotebookInfo.title;
                        if(!isEmpty(notebookTitle))
                            notebookInfo.notebookTitle = [[self class] createUniqueNotebookTitle:notebookTitle];
                        
                        //notebookInfo.notebookType = [NSNumber numberWithInteger:neoNotebookInfo.notebookType];
                        [[NJNotebookInfoStore sharedStore] updateNotebookInfo:notebookInfo];
                    }
                    NSLog(@"[RECOVERY-NOTEBOOK] notebookId %tu recovered %@",notebookId, notebookInfo.notebookTitle);
                    break;
                }
                
            }
        }
    } else {
        for(NSString *notebookUuid in notebookList) {
            if(![NJNotebookIdStore isDigitalNote:notebookUuid]) {
                NJNotebookInfo *notebookInfo = [[NJNotebookInfoStore sharedStore] getNotebookInfo:notebookUuid];
                
                NSUInteger section, owner;
                NSUInteger notebookId = [NJNotebookIdStore noteIdFromUuid:notebookUuid];
                [NPPaperManager section:&section owner:&owner fromNotebookId:notebookId];
                NSString *keyNameDB = [NPPaperManager keyNameForNotebookId:notebookId section:section owner:owner];
                if(![[NPPaperManager sharedInstance] hasPaperInfoForKeyName:keyNameDB]) continue;
                if (notebookInfo.notebookTitle && [notebookInfo.notebookTitle containsString:@"Unknown"]) {
                    anyNotebookRecovered = YES;
                    NPNotebookInfo *neoNotebookInfo = [[NPPaperManager sharedInstance] getNotebookInfoForKeyName:keyNameDB];
                    NSString *notebookTitle = neoNotebookInfo.title;
                    if(!isEmpty(notebookTitle))
                        notebookInfo.notebookTitle = [[self class] createUniqueNotebookTitle:notebookTitle];
                    
                    //notebookInfo.notebookType = [NSNumber numberWithInteger:neoNotebookInfo.notebookType];
                    [[NJNotebookInfoStore sharedStore] updateNotebookInfo:notebookInfo];
                }
                NSLog(@"[RECOVERY-NOTEBOOK] notebookId %tu recovered %@",notebookId, notebookInfo.notebookTitle);
            }
        }
    }
    
    if(anyNotebookRecovered) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:NJNoteobokManagerDidNotebookRecoverNotification object:nil userInfo:nil];
        });
    }
    
//    for(NSString *notebookUuid in notebookList) {
//        NSUInteger section, owner;
//        NSUInteger notebookId = [NJNotebookIdStore noteIdFromUuid:notebookUuid];
//        [NPPaperManager section:&section owner:&owner fromNotebookId:notebookId];
//        NSString *keyNameDB = [NPPaperManager keyNameForNotebookId:notebookId section:section owner:owner];
//        
//        if(![[NPPaperManager sharedInstance] hasPaperInfoForKeyName:keyNameDB]) continue;
//        if(![NJNotebookIdStore isDigitalNote:notebookUuid]) {
//            //NSArray *pages = [reader getPagesForNotebookUuid:notebookUuid];
//            NSArray *pages = [self getPagesForNotebookUuid:notebookUuid];
//            for(NSString *pageStr in pages) {
//                NSUInteger pageNum = [pageStr integerValue];
//                if([self isActivePageNum:pageNum andNotebookUuid:notebookUuid])
//                    _recoverCurrentActivePage = YES;
//                else
//                    [self recoverPageImageAsync_:pageNum notebookUuid:notebookUuid];
//                    //[[NJNotebookReaderManager sharedInstance] createAsyncPageThumbnail:pageNum notebookUuid:notebookUuid];
//            }
//        }
//    }
    
    recoveryLock = NO;
}

+ (BOOL) checkIfSameNotebookTitleAlreadyExist:(NSString *)notebookTitle
{
    NJNotebookReaderManager *reader = [NJNotebookReaderManager sharedInstance];
    NSArray *notebookList = [reader activeNotebookList];
    
    for(NSString *notebookUuid in notebookList) {
        if(![NJNotebookIdStore isDigitalNote:notebookUuid]) {
            NJNotebookInfo *notebookInfo = [[NJNotebookInfoStore sharedStore] getNotebookInfo:notebookUuid];
            
            if (notebookInfo.notebookTitle && [notebookInfo.notebookTitle isEqualToString:notebookTitle]) {
                return YES;
            }
        }
    }
    
    return NO;
}

+ (NSString *) createUniqueNotebookTitle:(NSString *)originalNotebookTitle
{
    NSString *uniqueTitle = originalNotebookTitle;
    
    NSUInteger counter = 1;
    while ([self checkIfSameNotebookTitleAlreadyExist:uniqueTitle]) {
        uniqueTitle = [NSString stringWithFormat:@"%@_%02tu",originalNotebookTitle,counter++];
    }
    return uniqueTitle;
}

- (void)recoverPageImageAsync_:(NSUInteger)pageNum notebookUuid:(NSString *)notebookUuid
{
    NJPageImageOperation *op = [[NJPageImageOperation alloc] initWithPageNum:pageNum notebookUuid:notebookUuid];

    if([[_pageImgQueue operations] containsObject:op]) return;

    [op setCompletionBlock:^{

//        NSUInteger type = NSPrivateQueueConcurrencyType;
//        NSManagedObjectContext *localMoc = [[NSManagedObjectContext alloc] initWithConcurrencyType:type];
//        localMoc.parentContext = [NJDBManager sharedInstance].moc;
//        [localMoc performBlock:^{
//            NJPageEntity *pageE = [localMoc objectWithID:objecId];
//            if(!isEmpty(pageE)) {
//                NSLog(@"[RECOVERY-PAGE] pageNum %tu",pageNum);
//                pageE.isTemporal = [NSNumber numberWithBool:NO];
//                [localMoc save:nil];
//                [[NJDBManager sharedInstance] saveContext:NO];
//            }
//        }];
    }];
    [_pageImgQueue addOperation:op];
}

@end

//@implementation NJPageImageOperation
//
//- (instancetype)initWithPageNum:(NSUInteger)pageNum notebookUuid:(NSString *)notebookUuid
//{
//    self = [super init];
//    if(self) {
//        self.notebookUuid = notebookUuid;
//        self.pageNum = pageNum;
//    }
//    return self;
//}
//- (BOOL)isEqual:(id)object
//{
//    NJPageImageOperation *rhs = (NJPageImageOperation *)object;
//    if([self.notebookUuid isEqualToString:rhs.notebookUuid] && (self.pageNum == rhs.pageNum)) return YES;
//    
//    return NO;
//}
//- (void)main
//{
//    NJPage *page = [[NJNotebookReaderManager sharedInstance] getPageData:self.pageNum notebookUuid:self.notebookUuid];
//    [page createPageImageSmall:page.fileUrl];
//}
//
//@end
