//
//  NJNotebookManager.m
//  NeoJournal
//
//  Copyright (c) 2014 Neolab. All rights reserved.
//

#import "NJNotebookManager.h"
#import "NJPageDocument.h"
#import "NJNotebookInfoStore.h"
#import "NJNotebookIdStore.h"
#import "NPPaperManager.h"
#import "NJNotebookInfo.h"


#import <Foundation/NSSortDescriptor.h>

#define PAGE_NUMBER_MAX 9999

#define NOTEBOOK_DATA_FILE

NSString *NJNoteBookExtension = @"notebook_store";
NSString *NJNoteBookPageExtension = @"page_store";
//NSString * NJPageChangeNotification = @"NJPageChangeNotification";
NSString * NJNoteBookPageDocumentOpenedNotification = @"NJNoteBookPageDocumentOpenedNotification";
NSString * NJPageStrokeAddedNotification = @"NJPageStrokeAddedNotification";

@interface NJNotebookManager (Private)
- (void) createDefaultDirectories_;
@end

@interface NJNotebookManager()

@end
@implementation NJNotebookManager
@synthesize activePageDocument = _activePageDocument;

- (id) init
{
    self = [super init];
    if(!self) {
        return nil;
    }
    [self createDefaultDirectories_];
    self.documentOpend=NO;    

    _activeNoteBookId = 0;
    _activePageNumber = 0;

    return self;
}
- (void) setActiveNoteBookId:(NSUInteger)activeNoteBookId
{
    if (_activeNoteBookId == activeNoteBookId) return;

    //[self closeActiveDocument];
    _activePageNumber = -1;
    _activeNoteBookId = activeNoteBookId;
    //_activeNotebookUuid = [[[NJNotebookIdStore sharedStore] notebookIdName:activeNoteBookId] copy];
    //_curNotebookInfo = [[NJNotebookInfoStore sharedStore] getNotebookInfo:_activeNotebookUuid]; // load notebook info
    
}
- (void) setActivePageNumber:(NSUInteger)activePageNumber
{
    NJPageDocument *pageDocument = [self pageDocumentAtNumber:activePageNumber];
    self.activePageDocument = pageDocument;
    _activePageNumber=activePageNumber;
}
- (NSArray *) realNotebookList
{
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSArray * list = [fm contentsOfDirectoryAtPath:[self bookshelfPath] error:NULL];
    list = [self filterNotebooks:list];
    
    return list;
}
- (NSArray *) digitalNotebookList
{
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSArray * list = [fm contentsOfDirectoryAtPath:[self digitalBookshelfPath] error:NULL];
    list = [self filterNotebooks:list];
    
    return list;
}
- (NSArray *) totalNotebookList
{
    NSArray *list = [self realNotebookList];
    NSArray *dList = [self digitalNotebookList];
    NSArray *mergedNotebookList = [list arrayByAddingObjectsFromArray:dList];
    
    return mergedNotebookList;
}
- (NSArray *)activeNotebookList
{
    return [self _notebookListInActiveState:YES];
}
- (NSArray *)archiveNotebookList
{
    return [self _notebookListInActiveState:NO];
}
- (NSArray *)_notebookListInActiveState:(BOOL)active
{
    
    NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:[self totalNotebookList]];
    NSMutableArray *discardedItems = [NSMutableArray array];
    
    for(NSString *notebookUuid in mutableArray) {
        
        if([[NJNotebookIdStore sharedStore] isActiveNotebook:notebookUuid] != active)
            [discardedItems addObject:notebookUuid];
    }
    
    [mutableArray removeObjectsInArray:discardedItems];
    return mutableArray;
}
- (NSUInteger) totalNotebookCount
{
    NSUInteger notebookCount = [[self realNotebookList] count];
    NSUInteger digitalNotebookCount = [[self digitalNotebookList] count];
    
    return notebookCount + digitalNotebookCount;
}
- (NSMutableDictionary *) notebookPages
{
    if (_notebookPages == nil) {
        _notebookPages = [[NSMutableDictionary alloc] init];
    }
    return _notebookPages;
}
- (void) activeNotebookIdDidChange:(NSUInteger)notebookId withPageNumber:(NSUInteger)pageNumber
{
    if (self.activeNoteBookId == notebookId && self.activePageNumber == pageNumber) {
        return;
    }
    [self setActiveNoteBookId:notebookId];
    [self setActivePageNumber:pageNumber];
}

#pragma mark - Page Document
- (NJPageDocument *) activePageDocument
{
    if (_activePageDocument == nil) {
        //self.activePageDocument = doc;
        return nil;
    }
    return _activePageDocument;
}

- (void) setActivePageDocument:(NJPageDocument *)activePageDocument
{
    if (_activePageDocument != activePageDocument) {
        [self closeActiveDocument];
        _activePageDocument.page = nil;  // To remove notification
        _activePageDocument = activePageDocument;
        self.documentOpend=NO;

    }
}
- (void) syncSetActivePageNumber:(NSUInteger)activePageNumber
{
    NJPageDocument *pageDocument = [self pageDocumentAtNumber:activePageNumber];
    _activePageNumber=activePageNumber;
    [self syncSetActivePageDocument :pageDocument];
}
- (void) syncSetActivePageDocument:(NJPageDocument *)activePageDocument
{
    if (_activePageDocument != activePageDocument) {
        [self closeActiveDocument];
        _activePageDocument.page = nil;  // To remove notification
        _activePageDocument = activePageDocument;
        NSString *name = [self pageNameFromNumber:self.activePageNumber];
        if (!name) return;
        NSURL *url = [self urlForName:name];
        [_activePageDocument readFromURL:url error:NULL];
        if (_activePageDocument.page != nil) {
            self.documentOpend=YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:NJNoteBookPageDocumentOpenedNotification object:self userInfo:nil];
            NSLog(@"open document success synchronously");
        }
    }
    
}
-(void) syncReload
{
    NSUInteger pageNumber = _activePageNumber;
    _activePageNumber = 0;
    _activePageDocument = nil;
    [self syncSetActivePageNumber:pageNumber];
}

- (void) closeActiveDocument
{
    if(_activePageDocument) {
        _activePageDocument = nil;
        self.documentOpend=NO;
    }
}
-(void)closeCurrentNotebook
{
    [self closeActiveDocument];
    _activeNoteBookId = -1;
    _activePageNumber = -1;
    _activeNotebookUuid = nil;
}
/*
-(void)closeCurrentNotebookWithCompBlock:(void (^)(BOOL))sblock
{
    if(_activePageDocument) {
        [_activePageDocument closeWithCompletionHandler:^(BOOL success) {
            
            if(!isEmpty(sblock))
                sblock(success);
            _activePageDocument = nil;
            self.documentOpend=NO;
            _activeNoteBookId = -1;
            _activePageNumber = -1;
            _activeNotebookUuid = nil;
            //[[NSNotificationCenter defaultCenter] postNotificationName:NJNotebookClosedNotification object:nil userInfo:nil];
        }];
        
        //_activePageDocument = nil;
        
    }
}*/
- (BOOL)isActiveNotebook:(NSString *)notebookUuid
{
    if(isEmpty(_activeNotebookUuid) || ![_activeNotebookUuid isEqualToString:notebookUuid]) return NO;
    return YES;
}
- (BOOL)isActivePageNum:(NSUInteger)pageNum andNotebookUuid:(NSString *)notebookUuid
{
    if(isEmpty(_activePageDocument)) return NO;
    if(_activePageNumber != pageNum) return NO;
    if(isEmpty(_activeNotebookUuid) || ![_activeNotebookUuid isEqualToString:notebookUuid]) return NO;

    return YES;
}
#pragma mark - File path related
- (NSString *) documentDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = paths[0];
//    return documentDirectory;
    return [documentDirectory stringByAppendingPathComponent:@"NeoNotebooksTemp"];
}
- (NSString *) bookshelfPath
{
    NSString *bookshelfPath = [[self documentDirectory] stringByAppendingPathComponent:@"NeoNoteBooks"];
    return bookshelfPath;
}

- (NSString *) digitalBookshelfPath
{
    NSString *bookshelfPath = [[self documentDirectory] stringByAppendingPathComponent:@"NeoDigitalNoteBooks"];
    return bookshelfPath;
}

// ---> have to change notebookPathForNoteType // physical notes only
// ---> this method must be accessed by penComm only
// other classes must access folder via uuid *notebookPathForUuid()
- (NSString *) _notebookPathForId:(NSUInteger) notebookId
{
    if (notebookId >= kNOTEBOOK_ID_START_DIGITAL) return nil;
    
    NSString *notebookPath;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *notebookUuid = [[[NJNotebookIdStore sharedStore] notebookIdName:notebookId]  stringByAppendingPathExtension:NJNoteBookExtension];
    notebookPath=[[self bookshelfPath] stringByAppendingPathComponent:notebookUuid];
    
    if(![fm fileExistsAtPath:notebookPath]) {
        [fm createDirectoryAtPath:notebookPath withIntermediateDirectories:NO attributes:nil error:NULL];
        [[NJNotebookInfoStore sharedStore] createNewNotebookInfo:notebookId];
    }
    return notebookPath;
}


// ---> have to change notebookPathForNoteID
- (NSString *) notebookPathForUuid:(NSString *) uuid
{
    NSString *notebookPath;
    //NSFileManager *fm = [NSFileManager defaultManager];
    
    NSString *notebookIdName = [[NSString stringWithFormat:@"%@",uuid] stringByAppendingPathExtension:NJNoteBookExtension];
    
    if ([NJNotebookIdStore isDigitalNote:uuid])
        notebookPath=[[self digitalBookshelfPath] stringByAppendingPathComponent:notebookIdName];
    else
        notebookPath=[[self bookshelfPath] stringByAppendingPathComponent:notebookIdName];
    
    /*
    if(![fm fileExistsAtPath:notebookPath])
        [fm createDirectoryAtPath:notebookPath withIntermediateDirectories:NO attributes:nil error:NULL];
    */
    return notebookPath;
}


- (NSString *) notebookPath
{
    NSString *notebookPath = [self _notebookPathForId:self.activeNoteBookId];
    return notebookPath;
}

- (NSArray *) filterPages:(NSArray *)pages forNotebookUuid:(NSString *)notebookUuid
{
    NSMutableArray *filtered = [[NSMutableArray alloc] init];
    
    for(NSString *page in pages) {
        if([[page pathExtension] compare:NJNoteBookPageExtension
                                 options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            
            if([self checkIfNoteExists:[page integerValue] forNotebookUuid:notebookUuid])
                [filtered addObject:[page stringByDeletingPathExtension]];
        }
    }
    return filtered;
}

- (NSArray *) filterNotebooks:(NSArray *)notebookList
{
    NSMutableArray *filtered = [[NSMutableArray alloc] init];
    
    for(NSString *notebook in notebookList) {
        if([[notebook pathExtension] compare:NJNoteBookExtension
                                 options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            
            NSString *notebookId = [notebook stringByDeletingPathExtension];
            //NSCharacterSet* nonNumbers = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
            //NSRange r = [notebookId rangeOfCharacterFromSet: nonNumbers];
            
            //if(r.location == NSNotFound)
                [filtered addObject:notebookId];
        }
    }
    return filtered;
}


- (NSString *) pathForName:(NSString *)name;
{
    NSString *path = [[[self notebookPath] stringByAppendingPathComponent:name] stringByAppendingPathExtension:NJNoteBookPageExtension];
    
    return path;
}
- (NSURL *) urlForName:(NSString *)name
{
    NSURL *url = [NSURL fileURLWithPath:[self pathForName:name]];
    
    return url;
}
#pragma mark - Page information
- (NSString *) pageNameFromNumber:(NSUInteger)number
{
    if (number > PAGE_NUMBER_MAX) {
        return nil;
    }
    return [NSString stringWithFormat:@"%04d", (int)number];
}

- (NSArray *)getPagesForNotebookUuid:(NSString *)notebookUuid
{
    
    NSArray * pages;
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *notebookPath = [self notebookPathForUuid:notebookUuid];
    
    pages = [fm contentsOfDirectoryAtPath:notebookPath error:NULL];
    NSArray *fiteredPages = [self filterPages:pages forNotebookUuid:notebookUuid];
    
    NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
    NSArray *sortedPages = [fiteredPages sortedArrayUsingDescriptors:@[sd]];
    
    return sortedPages;
}
- (NSString *)getPagePath:(NSUInteger)pageNum forNotebookUuid:(NSString *)notebookUuid
{
    
    NSString *notebookPath = [self notebookPathForUuid:notebookUuid];
    
    NSString *pageName = [self pageNameFromNumber:pageNum];
    NSString *pagePath = [[notebookPath stringByAppendingPathComponent:pageName] stringByAppendingPathExtension:NJNoteBookPageExtension];
    
    return pagePath;
}
- (NJPageDocument *)getPageDocument:(NSUInteger)pageNum forNotebookUuid:(NSString *)notebookUuid
{
    NSUInteger notebookId = [NJNotebookIdStore noteIdFromUuid:notebookUuid];
    NSString *pagePath = [self getPagePath:pageNum forNotebookUuid:notebookUuid];
    NSURL *pageUrl = [NSURL fileURLWithPath:pagePath];
    
    NJPageDocument *doc = [[NJPageDocument alloc] initWithFileURL:pageUrl withBookId:notebookId andPageNumber:pageNum andNotebookUuid:notebookUuid];
    
    return doc;
    
}
- (BOOL)checkIfNoteExists:(NSUInteger)pageNum forNotebookUuid:(NSString *)notebookUuid
{
    
    NSString *pagePath = [self getPagePath:pageNum forNotebookUuid:notebookUuid];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSString *dataPath = [pagePath stringByAppendingPathComponent:@"page.data"];
    NSString *thumbPath = [pagePath stringByAppendingPathComponent:@"thumb.jpg"];
    
    if ((![fm fileExistsAtPath:dataPath])
        || (![fm fileExistsAtPath:thumbPath])) return NO;
    
    return YES;
}
- (NJPageDocument *) pageDocumentAtNumber:(NSUInteger)number
{
    NSAssert(NO, @"Subclasses need to overwrite this method");
    return nil;
}
- (NJPageDocument *) pageWithName:(NSString *)name
{
    NSURL *url = [self urlForName:name];
    NJPageDocument *doc = [[NJPageDocument alloc] initWithFileURL:url withBookId:self.activeNoteBookId andPageNumber:[name intValue] andNotebookUuid:self.activeNotebookUuid];
    return doc;
}
- (NJPageDocument *) createNewPageForNumber:(NSUInteger)number
{
    NSString *name = [self pageNameFromNumber:number];
    if (!name) return nil;
    
    NSURL *url = [self urlForName:name];
    
    NJPageDocument * pageDocument = [[NJPageDocument alloc] initWithFileURL:url withBookId:self.activeNoteBookId andPageNumber:[name intValue] andNotebookUuid:self.activeNotebookUuid];
#ifdef OPEN_NOTEBOOK_SYNC_MODE
    [pageDocument pageSaveToURL:url completionHandler:nil];
#else
    [pageDocument openWithCompletionHandler:^(BOOL success) {
        if (success) {
            [pageDocument pageSaveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:nil];
        } else {
            NSLog(@"saving failure");
        }
        
    }];
#endif
    
    return pageDocument;
    
}
- (NSArray *) notebookPagesSortedBy:(NotebookPageSortRule)rule
{
    NSArray *sortedArray = [self.notebookPages allKeys];
    NSSortDescriptor *sd;
    switch (rule) {
        case kNotebookPageSortByName:
            sd = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
            sortedArray = [sortedArray sortedArrayUsingDescriptors:@[sd]];
            break;
            
        default:
            break;
    }
    
    return sortedArray;
}
- (NSDictionary *) pageInfoForPageNumber:(NSUInteger) number
{
    NSDictionary * pageInfo = [self.notebookPages objectForKey:[NSNumber numberWithInteger:number]];
    
    return pageInfo;
}

@end

#define kFORCE_DATA_INITIALIZATION
#pragma mark - NJNotebookManager Private
@implementation NJNotebookManager (Private)

- (void) createDefaultDirectories_
{
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL firstRun = NO;
    
    if((![fm fileExistsAtPath:[self bookshelfPath]]) && (![fm fileExistsAtPath:[self digitalBookshelfPath]])) {
        firstRun = YES;
    }
    
    [fm createDirectoryAtPath:[self bookshelfPath] withIntermediateDirectories:YES attributes:nil error:NULL];
    [fm createDirectoryAtPath:[self digitalBookshelfPath] withIntermediateDirectories:YES attributes:nil error:NULL];
    //[fm createDirectoryAtPath:[self archivesBookshelfPath] withIntermediateDirectories:YES attributes:nil error:NULL];
    
    if (firstRun) {
        
        // save app first install time
        
        return; // block below as requested remove sample diary from next version - requested at 21 Nov 2014
        NSString *samplesDirectory = @"preloadNotes";
        NSArray *sampleNotePaths = [[NSBundle mainBundle] pathsForResourcesOfType:@"notebook_store" inDirectory:samplesDirectory];
        
        for (NSString *pathNote in sampleNotePaths) {
            
            NSUInteger noteId = [[pathNote lastPathComponent] integerValue];
            NSString *documentPath = [self _notebookPathForId:noteId];
            NSArray *samplePagePaths = [[NSBundle mainBundle] pathsForResourcesOfType:@"page_store" inDirectory:[samplesDirectory stringByAppendingPathComponent:[pathNote lastPathComponent]]];
            
            NSError * error = nil;
            for (NSString *pathPage in samplePagePaths)
                [fm copyItemAtPath:pathPage toPath:[documentPath stringByAppendingPathComponent:[pathPage lastPathComponent]] error:&error];
            if(error)
            NSLog(@"ERROR: %@",[error localizedDescription]);
        }
    }
    
}

@end
