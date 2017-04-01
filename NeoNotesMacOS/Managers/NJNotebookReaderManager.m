//
//  NJNotebookReaderManager.m
//  NeoJournal
//
//  Created by Ken on 14/02/2014.
//  Copyright (c) 2014 Neolab. All rights reserved.
//

#import "NJPage.h"
#import "NJNotebookInfo.h"
#import "NJNotebookInfoStore.h"
#import "NJVoiceManager.h"
#import "NJPageDocument.h"
#import "NJNotebookInfo.h"
#import "NJNotebookIdStore.h"

extern NSString *NJNoteBookPageExtension;
extern NSString * NJNoteBookPageDocumentOpenedNotification;

NSString * NJOneNoteBookCompleteNotification = @"NJOneNoteBookCompleteNotification";

//@interface NJPageImageOperation: NSOperation
//@property (strong, nonatomic) NSString *notebookUuid;
//@property (nonatomic) NSUInteger pageNum;
//- (instancetype)initWithPageNum:(NSUInteger)pageNum notebookUuid:(NSString *)notebookUuid;
//@end

@interface NJNotebookReaderManager()
@property (nonatomic, assign) NSUInteger bookIndex;
@property (nonatomic, assign) NSUInteger bookCount;
@property (nonatomic, assign) NSUInteger pageIndex;
@property (nonatomic, assign) NSUInteger pageCount;
@property (nonatomic, assign) NSUInteger noteType;
//@property (nonatomic) NSUInteger activePageNumber;
//@property (strong, nonatomic) NJPageDocument *activePageDocument;
@end

@implementation NJNotebookReaderManager
{
    NSOperationQueue *_pageImgQueue;
}

+ (NJNotebookReaderManager *) sharedInstance
{
    static NJNotebookReaderManager *shared = nil;
    
    @synchronized(self) {
        if(!shared){
            shared = [[NJNotebookReaderManager alloc] init];
        }
    }
    return shared;
}
- (instancetype)init
{
    self = [super init];
    
    if(self) {
        
        _pageImgQueue = [[NSOperationQueue alloc] init];
        _pageImgQueue.name = @"Page Image Creating Queue";
        _pageImgQueue.maxConcurrentOperationCount = 1;
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    }
    
    return self;
}

//- (void) syncOpenNotebook:(NSUInteger)notebookId withPageNumber:(NSUInteger)pageNumber
//{
//    if (self.activeNoteBookId == notebookId && self.activePageNumber == pageNumber) {
//        return;
//    }
//    [self setActiveNoteBookId:notebookId];
//    [self syncSetActivePageNumber:pageNumber];
//}
- (BOOL) syncOpenNotebook2:(NSString *)notebookUuid withPageNumber:(NSUInteger)pageNumber
{
    if (isEmpty(notebookUuid) || ([self.activeNotebookUuid isEqualToString:notebookUuid] && self.activePageNumber == pageNumber))  {
        return NO;
    }
    NSUInteger notebookId = [NJNotebookIdStore noteIdFromUuid:notebookUuid];
    self.activeNotebookUuid = notebookUuid;
    [self setActiveNoteBookId:notebookId];
    [self syncSetActivePageNumber:pageNumber];
    
    return YES;
}

// --------------------------------------------------------------------
// 05-Oct-2014 by namSSan
// following 2 functions are overriding function of NotebookManager
// they are very important to be here coz reader always needs notebook uuid as it should be able read even in-activated notebooks
// wherase writer only use the notebook which is currently active (at the moment, only penComm access writer -
// we will probably add function like drawing, add / edit storke in the app. then there will be
// another classes to access writer..
- (NJPageDocument *) pageDocumentAtNumber:(NSUInteger)number
{
    NJPageDocument *doc = [self getPageDocument:number forNotebookUuid:self.activeNotebookUuid];
    return doc;
}
- (NSString *) notebookPath
{
    NSString *notebookPath = [self notebookPathForUuid:self.activeNotebookUuid];
    return notebookPath;
}
// --------------------------------------------------------------------

// following functions.. try to read image / page.data from specified path
// directly / synchronously read from the file
- (NJPage *)getPageData:(NSUInteger)pageNum notebookUuid:(NSString *)notebookUuid
{
    return [self getPageData:pageNum notebookUuid:notebookUuid loadStrokes:YES];
}
- (NJPage *)getPageData:(NSUInteger)pageNum notebookUuid:(NSString *)notebookUuid loadStrokes:(BOOL)loadStrokes
{
    NSString *pagePath = [self getPagePath:pageNum forNotebookUuid:notebookUuid];
    NSURL *pageUrl = [NSURL URLWithString:pagePath];
    NSString *dataPath = [pagePath stringByAppendingPathComponent:@"page.data"];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:dataPath]) return nil;
    
    NSUInteger notebookId = [NJNotebookIdStore noteIdFromUuid:notebookUuid];
    NJPage *aPage = [[NJPage alloc] initWithNotebookId:(int)notebookId andPageNumber:(int)pageNum];
    //jr
//    aPage.pageHasChanged = YES;
//    [aPage saveToURL:pageUrl];
    //[aPage readFromURL:pageUrl error:NULL loadStrokes:loadStrokes];
    BOOL metaOnly = !loadStrokes;
    [aPage readFromURL:pageUrl readMetaFile:YES metaOnly:metaOnly];
    
    return aPage;
}
- (long)sizeForNotebook:(NSString *)notebookUuid
{
    long totSize = 0;
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *pages = [self getPagesForNotebookUuid:notebookUuid];
    NSDictionary *attributes = nil;
    
    for (NSString *page in pages) {
        NSString *pagePath = [self getPagePath:[page integerValue] forNotebookUuid:notebookUuid];
        
        if ([fm fileExistsAtPath:pagePath]) {
            attributes = [fm attributesOfItemAtPath:pagePath error:nil];
            long pageSize = [[attributes objectForKey:NSFileSize] longValue];
            totSize += pageSize;
        }
    }
    
    for (NSString *page in pages) {
        NSString *pagePath = [self getPagePath:[page integerValue] forNotebookUuid:notebookUuid];
        
        if ([fm fileExistsAtPath:pagePath]) {
            attributes = [fm attributesOfItemAtPath:pagePath error:nil];
            long pageSize = [[attributes objectForKey:NSFileSize] longValue];
            totSize += pageSize;
        }
    }
    
    NSArray *vms = [NJVoiceManager getVoiceMemosForNotebookUuid:notebookUuid];
    NSString *vmDirectory = [NJVoiceManager voiceMemoDirectory];
    
    for(NSString *fileName in vms) {
        //NSLog(@"file name ---> %@",fileName);
        NSString *vmPath = [vmDirectory stringByAppendingPathComponent:fileName];
        
        if ([fm fileExistsAtPath:vmPath]) {
            attributes = [fm attributesOfItemAtPath:vmPath error:nil];
            long vmSize = [[attributes objectForKey:NSFileSize] longValue];
            totSize += vmSize;
        }
    }
    
    if([NJNotebookIdStore isDigitalNote:notebookUuid]) {
        NJNotebookInfo *notebookInfo = [[NJNotebookInfoStore sharedStore] getNotebookInfo:notebookUuid];
        if(notebookInfo.coverImage != nil) {
        }
    }
    return totSize;
}
- (NSImage *)getPageImage:(NSUInteger)pageNum notebookUuid:(NSString *)notebookUuid scaledWidth:(CGFloat)width
{
    NSImage *image = nil;
    NJPage *page = [self getPageData:pageNum notebookUuid:notebookUuid];
    image = [page renderPageWithSize:[page imageSize:width] bgOption:0];

    return image;
}
- (NSImage *)getSmallSizePageImage:(NSUInteger)pageNum notebookUuid:(NSString *)notebookUuid
{
    NSString *pagePath = [self getPagePath:pageNum forNotebookUuid:notebookUuid];
    NSString *thumbPath = [pagePath stringByAppendingPathComponent:@"thumb.jpg"];
    NSImage *image = nil;
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:thumbPath]) {
        image = [[NSImage alloc] initWithContentsOfFile:thumbPath];
    } else {
        // either of small or large image is missing we create one
        NJPage *page = [self getPageData:pageNum notebookUuid:notebookUuid];
        image = [page createPageImageSmall:[NSURL URLWithString:pagePath]];
    }
    return image;
}
// return NSArray*
// 0 - UIImage *image
// 1 - NSDictionary *fileAttributes
- (NSDictionary *)getPageImageAttr:(NSUInteger)pageNum forNotebookUuid:(NSString *)notebookUuid
{
    NSString *pagePath = [self getPagePath:pageNum forNotebookUuid:notebookUuid];
    NSString *thumbPath = [pagePath stringByAppendingPathComponent:@"thumb.jpg"];
    //UIImage *image = nil;
    NSDictionary *attributes = nil;

    
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:thumbPath]) {
        //image = [UIImage imageWithContentsOfFile:thumbPath];
        attributes = [fm attributesOfItemAtPath:thumbPath error:nil];
    }
    
    //if(isEmpty(image) || isEmpty(attributes)) return nil;
    //NSArray *retArray = @[image,attributes];
    return attributes;
}
- (NSArray *)getFirstAndLastImagesForNotebookUuid:(NSString *)notebookUuid
{
    NSArray *pages = [self getPagesForNotebookUuid:notebookUuid];
    NSMutableArray *pageImages = [NSMutableArray array];
    
    NSInteger page1 = -1;
    NSInteger page2 = -1;
    
    if(isEmpty(pages)) return nil;
    
    NSDate *tDate1 = nil;
    NSDate *tDate2 = nil;
    
    //get lastest two pages
    if(pages.count == 1)
        page1 = [[pages objectAtIndex:0] integerValue];
    else {
        for(int i =0; i < pages.count; i++) {
            
            NSInteger curPage = [[pages objectAtIndex:i] integerValue];
            //NSArray *imgData = [self getSmallSizePageImage:curPage forNotebookUuid:notebookUuid];
            NJPage *pageData = [self getPageData:curPage notebookUuid:notebookUuid loadStrokes:NO];
            
            if(isEmpty(pageData)) continue;
        
            
            NSDate *date = pageData.mTime;
            
            if(tDate1 == nil) {
                tDate1 = date;
                page1 = curPage;
            }
            if(tDate2 == nil) {
                tDate2 = date;
                page2 = curPage;
                continue;
                
            }
            // tDate1 --> first page
            // tDate2 --> last page (most recent)
            if(([date compare:tDate1] == NSOrderedAscending)) {
                tDate1 = date;
                page1 = curPage;
                continue;
            }
            if(([date compare:tDate2] == NSOrderedDescending)) {
                tDate2 = date;
                page2 = curPage;
                continue;
            }

        }
    }
    if(page1 >= 0) {
        NSImage *orgImg = [self getSmallSizePageImage:page1 notebookUuid:notebookUuid];
        [pageImages addObject:orgImg];
    }
    
    if((page1 != page2) && (page2 >= 0)) {
        NSImage *orgImg = [self getSmallSizePageImage:page2 notebookUuid:notebookUuid];
        [pageImages addObject:orgImg];
    }
        
    //NSData *imageData = [NSKeyedArchiver archivedDataWithRootObject:pageImages];
    
    return pageImages;
}
- (void)createAsyncPageThumbnail:(NSUInteger)pageNum notebookUuid:(NSString *)notebookUuid
{
    NJPageImageOperation *op = [[NJPageImageOperation alloc] initWithPageNum:pageNum notebookUuid:notebookUuid];
    
    if([[_pageImgQueue operations] containsObject:op]) {
        NSLog(@"[Notebook Reader Manager] Page Image Creating Operation is ALREADY in the queue");
        return;
    }
    [op setCompletionBlock:^{
        
    }];
    [_pageImgQueue addOperation:op];
}


@end



@implementation NJPageImageOperation

- (instancetype)initWithPageNum:(NSUInteger)pageNum notebookUuid:(NSString *)notebookUuid
{
    self = [super init];
    
    if(self) {
        self.notebookUuid = notebookUuid;
        self.pageNum = pageNum;
    }
    
    return self;
}
- (BOOL)isEqual:(id)object
{
    NJPageImageOperation *rhs = (NJPageImageOperation *)object;
    
    if([self.notebookUuid isEqualToString:rhs.notebookUuid] && (self.pageNum == rhs.pageNum)) return YES;
    
    return NO;
}

- (void)main
{
    NJPage *page = [[NJNotebookReaderManager sharedInstance] getPageData:self.pageNum notebookUuid:self.notebookUuid];
    [page createPageImageSmall:page.fileUrl];
}

@end
