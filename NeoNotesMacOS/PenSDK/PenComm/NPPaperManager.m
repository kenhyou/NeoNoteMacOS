//
//  NJPaperInfoManager
//  NeoPenSDK
//
//  Created by NamSang on 7/01/2016.
//  Copyright © 2016 Neolabconvergence. All rights reserved.
//

#import "NPPaperManager.h"
#import "NPNotebookInfoEntity+CoreDataProperties.h"
#import "NPPaperInfoEntity+CoreDataProperties.h"
#import "NPPUIInfoEntity+CoreDataProperties.h"
#import "NJXMLParser.h"
#import "NJNetworkManager.h"
#import <zipzap/zipzap.h>


#define NEO_SDK_USE_NOTESERVER
#define kNPPaperInfoStore_Current_Max_NotebookId 90000
#define kNPPaperInfoStore_DownloadEntryFileName  @"kNPPaperInfoStore_DownloadEntryFileName"


@interface NJPaperInfoDownloadEntry : NSObject <NSCoding>
@property (strong, nonatomic) NSString *keyName;
@property (strong, nonatomic) NSDate *timeQueued;
@property (nonatomic) NSUInteger numOfTry;
@property (nonatomic) BOOL isInProcess;
@property (nonatomic) BOOL hasCompleted;
@end


@interface NPPaperManager ()

// paperInfo
@property (strong, nonatomic) NSMutableDictionary *paperInfos;
@property (strong, nonatomic) NSArray *notesSupported;
@property (strong, nonatomic) NSTimer *downloadTimer;

@property (readonly, strong, nonatomic) NSManagedObjectContext *privateMoc;
@property (readonly, strong, nonatomic) NSManagedObjectContext *moc;
@property (readonly, strong, nonatomic) NSManagedObjectModel *mom;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *psc;

@property (strong, nonatomic) NSMutableArray *nprojURLArray;
@end


@implementation NPPaperManager
{
    dispatch_queue_t _download_dispatch_queue;
    NSMutableArray *_downloadQueue;
}

@synthesize privateMoc = __privateMoc;
@synthesize moc = __moc;
@synthesize mom = __mom;
@synthesize psc = __psc;




+ (instancetype) sharedInstance
{
    static NPPaperManager *sharedInstance = nil;
    
    @synchronized(self) {
        if(!sharedInstance){
            sharedInstance = [[super allocWithZone:nil] init];
        }
    }
    return sharedInstance;
}
- (instancetype) init
{
    [self clearTmpDirectory];
    self.paperInfos = [NSMutableDictionary dictionary];
    self.nprojURLArray = [NSMutableArray array];
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"note_support_list" ofType:@"plist"];
    _notesSupported = [[NSArray alloc] initWithContentsOfFile:plistPath];
    
    NSManagedObjectContext *moc = self.moc;
    moc = nil;
    
    _download_dispatch_queue = dispatch_queue_create("download_dispatch_queue", DISPATCH_QUEUE_SERIAL);
    [self loadAllDownloadEntries_];
    //jr
    if(!isEmpty(_downloadQueue))
        [self startDownloadTimer_];
    
    return self;
}
+ (NSString *) keyNameForNotebookId:(NSUInteger)notebookId section:(NSUInteger)section owner:(NSUInteger)owner
{
    NSString *keyName = [NSString stringWithFormat:@"%05tu_%05tu_%08tu",section,owner,notebookId];
    return keyName;
}
+ (BOOL) notebookId:(NSUInteger *)notebookId section:(NSUInteger *)section owner:(NSUInteger *)owner fromKeyName:(NSString *)keyName
{
    if(isEmpty(keyName)) return NO;
    NSArray *tokens = [keyName componentsSeparatedByString:@"_"];
    if(tokens.count != 3) return NO;
    
    *section = [[tokens objectAtIndex:0] integerValue];
    *owner = [[tokens objectAtIndex:1] integerValue];
    *notebookId = [[tokens objectAtIndex:2] integerValue];
    return YES;
}
+ (BOOL)section:(NSUInteger *)section owner:(NSUInteger *)owner fromNotebookId:(NSUInteger)notebookId
{
    *section = 3;
    *owner = 27;
    if((notebookId == 605) || (notebookId == 606) || (notebookId == 608) || (notebookId == 621) || (notebookId == 622))
        *section = 0;
    
    return YES;
}





- (NSManagedObjectContext *)privateMoc
{
    if (__privateMoc != nil) {
        return __privateMoc;
    }
    NSPersistentStoreCoordinator *coordinator = [self psc];
    if (coordinator != nil) {
        NSUInteger type = NSPrivateQueueConcurrencyType;
        __privateMoc = [[NSManagedObjectContext alloc] initWithConcurrencyType:type];
        [__privateMoc setPersistentStoreCoordinator:coordinator];
    }
    return __privateMoc;
}
- (NSManagedObjectContext *)moc
{
    if (__moc != nil) {
        return __moc;
    }
    NSPersistentStoreCoordinator *coordinator = [self psc];
    if (coordinator != nil) {
        NSUInteger type = NSMainQueueConcurrencyType;
        __moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:type];
        [__moc setParentContext:self.privateMoc];
    }
    return __moc;
}
- (NSManagedObjectModel *)mom
{
    if (__mom != nil) {
        return __mom;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"NeoSDK" withExtension:@"momd"];
    __mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __mom;
}
- (NSPersistentStoreCoordinator *)psc
{
    if (__psc != nil) {
        return __psc;
    }
    
    NSError *error = nil;
    NSDictionary *options = @{
                    NSInferMappingModelAutomaticallyOption: @YES,
                    NSSQLitePragmasOption: @{@"journal_mode": @"WAL"}
                    };

    __psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self mom]];
    if (![__psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[self dbStoreURL_] options:options error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return __psc;
}
- (NSString *)sourceStoreType
{
    return NSSQLiteStoreType;
}
- (NSDictionary *)sourceMetadata:(NSError **)error
{
    return [NSPersistentStoreCoordinator metadataForPersistentStoreOfType: NSSQLiteStoreType
                                                                      URL: [self dbStoreURL_]
                                                                    error:error];
}
- (void)saveContext:(BOOL)wait
{
    NSManagedObjectContext *moc = self.moc;
    NSManagedObjectContext *private = self.privateMoc;
    
    if(!moc) return;
    if([moc hasChanges]) {
        [moc performBlockAndWait:^{
            NSError *error = nil;
            [moc save:&error];
        }];
    }
    
    void (^savePrivate)(void) = ^{
        NSError *error = nil;
        [private save:&error];
    };
    
    if([private hasChanges]) {
        if(wait)
            [private performBlockAndWait:savePrivate];
        else
            [private performBlock:savePrivate];
    }
}




- (void)removeNotebookInfoForKeyName:(NSString *)keyName
{
    
}

- (NPNotebookInfo *) getNotebookInfoForNotebookId:(NSUInteger)notebookId section:(NSUInteger)section owner:(NSUInteger)owner
{
    NSString *keyName = [[self class] keyNameForNotebookId:notebookId section:section owner:owner];
    return [self getNotebookInfoForKeyName_:keyName];
}
- (NPNotebookInfo *) getNotebookInfoForKeyName:(NSString *)keyName
{
    if(isEmpty(keyName)) return nil;
    if([keyName integerValue] >= kNPPaperInfoStore_Current_Max_NotebookId) return nil;
    return [self getNotebookInfoForKeyName_:keyName];
}
- (NPNotebookInfo *) getNotebookInfoForKeyName_:(NSString *)keyName
{
    NPNotebookInfo *notebookInfo = [self.paperInfos objectForKey:keyName];
    
    if(notebookInfo == nil) {
        // 1. try to fetch from DB
        notebookInfo = (NPNotebookInfo *)[self fetchForKeyName_:keyName pageNum:0 fetchPaperInfo:NO];
        
        if(notebookInfo == nil) {
            // 2. try to download from Note Server
            // assume we already downloaded from the server
            // starting from parsing process in background
            [self addDownloadEntryForKeyName_:keyName];
            
            // create default notebook Info
            notebookInfo = [NPNotebookInfo new];
            notebookInfo.title = @"Unknown Note";
            notebookInfo.pdfPageReferType = PDFPageReferTypeOne;
            notebookInfo.notebookType = NeoNoteTypeNormal;
            notebookInfo.maxPage = 1000;
            notebookInfo.isTemporal = YES;
        }

        @synchronized(self) {
            [self.paperInfos setObject:notebookInfo forKey:keyName];
        }
    } else {
//         NSLog(@"has in memory for notebookInfo (%@)",keyName);
    }
    
    return notebookInfo;
}
- (NPPaperInfo *) getPaperInfoForNotebookId:(NSUInteger)notebookId pageNum:(NSUInteger)pageNum section:(NSUInteger)section owner:(NSUInteger)owner
{
    NSString *keyName = [[self class] keyNameForNotebookId:notebookId section:section owner:owner];
    return [self getPaperInfoForKeyName_:keyName pageNum:pageNum];
}


- (NPPaperInfo *) getPaperInfoForKeyName_:(NSString *)keyName pageNum:(NSUInteger)pageNum
{
    __block NPNotebookInfo *notebookInfo = nil;
    __block NPPaperInfo *paperInfo = nil;

//    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        notebookInfo = [self.paperInfos objectForKey:keyName];
        
        if(notebookInfo == nil)
            notebookInfo = [self getNotebookInfoForKeyName_:keyName];
        
        if(pageNum <= notebookInfo.maxPage) {
            
            paperInfo = [notebookInfo.pages objectForKey:[NSNumber numberWithInteger:pageNum]];
            if(paperInfo == nil) {
                
                // 1. try to fetch from DB
                paperInfo = [self fetchForKeyName_:keyName pageNum:pageNum fetchPaperInfo:YES];
                if(paperInfo) {
                    
                    if(notebookInfo.pdfPageReferType == PDFPageReferTypeOne)
                        paperInfo.pdfPageNum = 1;
                    else if(notebookInfo.pdfPageReferType == PDFPageReferTypeEvenOdd)
                        paperInfo.pdfPageNum = ((pageNum % 2) == 0)? 2 : 1;
                    else
                        paperInfo.pdfPageNum = pageNum;
                    @synchronized(self) {
                        [notebookInfo.pages setObject:paperInfo forKey:[NSNumber numberWithInteger:pageNum]];
                    }
                } else {
                    // create default paper Info
                    paperInfo = [NPPaperInfo new];
                    paperInfo.pdfPageNum = 1;
                    paperInfo.startX = 0.0f;
                    paperInfo.startY = 0.0f;
                    paperInfo.width = 88.82f;
                    paperInfo.height = 125.7f;
                    paperInfo.isTemporal = YES;
                }

            }
        }
//        dispatch_semaphore_signal(sem);
//    });
//    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
//    NSLog(@"pageNum %tu --> %tu",pageNum,paperInfo.pdfPageNum);
    return paperInfo;
}
- (BOOL)insertDBFromXML_:(NSDictionary *)xml shouldReset:(BOOL)shouldReset shouldWait:(BOOL)shouldWait
{
    __block BOOL success = NO;
    
    NSUInteger type = NSPrivateQueueConcurrencyType;
    NSManagedObjectContext *localMoc = [[NSManagedObjectContext alloc] initWithConcurrencyType:type];
    localMoc.parentContext = self.moc;
    
    void (^insertBlock)(void) = ^{
        NSString *nprojVersion = [xml objectForKey:@"_version"];
        if ([nprojVersion isEqualToString:@"2.2"]) {
            NSDictionary *book = [xml objectForKey:@"book"];
            if(isEmpty(book)) return;
            NSUInteger section = [[book objectForKey:@"section"] integerValue];
            NSUInteger owner = [[book objectForKey:@"owner"] integerValue];
            NSUInteger notebookId = [[book objectForKey:@"code"] integerValue];
            //        CGFloat dpi = [[book objectForKey:@"target_dpi"] floatValue];
            NSString *title = ([book objectForKey:@"title"] == nil)? @"NO TITLE" : [book objectForKey:@"title"];
            NSString *keyName = [[self class] keyNameForNotebookId:notebookId section:section owner:owner];
            
            NeoNoteType noteType = NeoNoteTypeNormal;
            if([book objectForKey:@"kind"])
                noteType = [[book objectForKey:@"kind"] integerValue];
            
            PDFPageReferType pdfPageReferType = PDFPageReferTypeEvery;
            NSString *extra = nil;
            if((extra = [book objectForKey:@"extra_info"])) {
                if([extra hasPrefix:@"pdf_page_count"]) {
                    NSArray *tokens = [extra componentsSeparatedByString:@"="];
                    if(tokens.count == 2) {
                        NSUInteger num = [[tokens lastObject] integerValue];
                        if(num == 1)
                            pdfPageReferType = PDFPageReferTypeOne;
                        else if(num == 2)
                            pdfPageReferType = PDFPageReferTypeEvenOdd;
                    }
                }
            }
            
            NSDictionary *pages = [xml objectForKey:@"pages"];
            NSUInteger maxPage = [[pages objectForKey:@"_count"] integerValue];
            
            NSError *error;
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"NPNotebookInfoEntity" inManagedObjectContext:localMoc];
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            [fetchRequest setEntity:entity];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"keyName LIKE  %@",keyName];
            [fetchRequest setPredicate:predicate];
            
            NSArray *results = [localMoc executeFetchRequest:fetchRequest error:&error];
            if(!isEmpty(results)){
                if(shouldReset) {
                    //for(NJNotebookEntity *notebookE in results)
                    for(NPNotebookInfoEntity *notebookE in results)
                        [localMoc deleteObject:notebookE];
                } else {
                    return; // alreay exist --> ignore
                }
            }
            
            
            NPNotebookInfoEntity *notebookInfoE = [NSEntityDescription insertNewObjectForEntityForName:@"NPNotebookInfoEntity" inManagedObjectContext:localMoc];
            notebookInfoE.keyName = keyName;
            notebookInfoE.type = [NSNumber numberWithInteger:noteType];
            notebookInfoE.title = title;
            notebookInfoE.noPages = [NSNumber numberWithInteger:maxPage];
            notebookInfoE.pdfPageReferType = [NSNumber numberWithInteger:pdfPageReferType];
            
            CGFloat scale = 600.0f / 72.0f / 56.0f; // 600/72/56 ~ 0.149
            NSMutableArray *paperInfoEnityArray = [NSMutableArray array];
            for(int i=1; i <= maxPage; i++) {
                NPPaperInfoEntity *paperInfoE = [NSEntityDescription insertNewObjectForEntityForName:@"NPPaperInfoEntity" inManagedObjectContext:localMoc];
                paperInfoE.pageNum = [NSNumber numberWithInteger:i];
                [paperInfoEnityArray addObject:paperInfoE];
            }
            
            
            CGFloat cStartX,cStartY,cWidth,cHeight;
            cStartX = cStartY = cWidth = cHeight = 0.0f;
            // use default A4 note
            cStartX = 36.0f;
            cStartY = 36.0f;
            cWidth = 596.099f;
            cHeight = 842.395f;
            
            id pageItems = [pages objectForKey:@"page_item"];
            if(pageItems != nil) {
                BOOL isArray = ([pageItems isKindOfClass:[NSArray class]]);
                NSArray *pageArray = (isArray)? pageItems : [NSArray arrayWithObject:pageItems];
                NSDictionary *dic = [pageArray objectAtIndex:0];
                if(dic) {
                    cStartX = [[dic objectForKey:@"_x1"] floatValue];
                    cStartY = [[dic objectForKey:@"_y1"] floatValue];
                    cWidth = [[dic objectForKey:@"_x2"] floatValue];
                    cHeight = [[dic objectForKey:@"_y2"] floatValue];
                }
            }
            
            id symbols = [[xml objectForKey:@"symbols"] objectForKey:@"symbol"];
            if(symbols != nil) {
                BOOL isArray = ([symbols isKindOfClass:[NSArray class]]);
                NSArray *symbolArray = (isArray)? symbols : [NSArray arrayWithObject:symbols];
                
                for(NSDictionary *symbol in symbolArray) {
                    
                    NSUInteger pageNum = [[symbol objectForKey:@"_page"] integerValue];
                    NPPaperInfoEntity *paperE = [paperInfoEnityArray objectAtIndex:pageNum];
                    
                    CGFloat x = [[symbol objectForKey:@"_x"] floatValue];
                    CGFloat y = [[symbol objectForKey:@"_y"] floatValue];
                    CGFloat width = [[symbol objectForKey:@"_width"] floatValue];
                    CGFloat height = [[symbol objectForKey:@"_height"] floatValue];
                    NSDictionary *cmdDic = [symbol objectForKey:@"command"];
                    NSString *cmd = [cmdDic objectForKey:@"_param"];
                    if(cmd == nil) continue;
                    
                    if((pageNum == 0) && [cmd isEqualToString:@"crop_area_common"]) {
                        cStartX = x;
                        cStartY = y;
                        cWidth = width;
                        cHeight = height;
                    } else if ([cmd isEqualToString:@"crop_area"]) {
                        paperE.startX = [NSNumber numberWithFloat:(x * scale)];
                        paperE.startY = [NSNumber numberWithFloat:(y * scale)];
                        paperE.width = [NSNumber numberWithFloat:(width * scale)];
                        paperE.height = [NSNumber numberWithFloat:(height * scale)];
                    } else {
                        NPPUIInfoEntity *puiE = [NSEntityDescription insertNewObjectForEntityForName:@"NPPUIInfoEntity" inManagedObjectContext:localMoc];
                        PUICmdType cmdType = PUICmdTypeEmail;
                        
                        if([cmd hasPrefix:@"franklin_"]) {
                            NSArray *tokens = [cmd componentsSeparatedByString:@"_"];
                            NSString *type = [tokens objectAtIndex:1];
                            
                            if([type isEqualToString:@"m"])
                                cmdType = PUICmdTypeActivity;
                            else if([type isEqualToString:
                                     @"d"])
                                cmdType = PUICmdTypeAlarm;
                            
                            puiE.extraInfo = [tokens lastObject];
                        }
                        
                        puiE.cmd = [NSNumber numberWithInt:cmdType];
                        puiE.shape = [NSNumber numberWithInt:PUIShapeRectangle];
                        puiE.startX = [NSNumber numberWithFloat:(x * scale)];
                        puiE.startY = [NSNumber numberWithFloat:(y * scale)];
                        puiE.width = [NSNumber numberWithFloat:(width * scale)];
                        puiE.height = [NSNumber numberWithFloat:(height * scale)];
                        
                        [paperE addPuiInfoObject:puiE];
                    }
                }
            }
            
            for(NPPaperInfoEntity *paperE in paperInfoEnityArray) {
                CGFloat w = [paperE.width floatValue];
                if((w <= 0.0)) {
                    paperE.startX = [NSNumber numberWithFloat:(cStartX * scale)];
                    paperE.startY = [NSNumber numberWithFloat:(cStartY * scale)];
                    paperE.width = [NSNumber numberWithFloat:(cWidth * scale)];
                    paperE.height = [NSNumber numberWithFloat:(cHeight * scale)];
                }
                [notebookInfoE addPaperInfoObject:paperE];
            }
            
            [localMoc save:&error];
            [self saveContext:NO];
            [self completeDownloadEntry_:keyName];
            // remove temporal entry
            [self.paperInfos removeObjectForKey:keyName];
            
            success = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary *userInfo = @{@"keyName":keyName,
                                           @"title":title,
                                           };
                [[NSNotificationCenter defaultCenter] postNotificationName:NPPaperInfoStorePaperBecomeAvailableNotification object:self userInfo:userInfo];
            });

        } else {
            NSDictionary *book = [xml objectForKey:@"book"];
            if(isEmpty(book)) return;
            NSUInteger section = [[book objectForKey:@"section"] integerValue];
            NSUInteger owner = [[book objectForKey:@"owner"] integerValue];
            NSUInteger notebookId = [[book objectForKey:@"code"] integerValue];
            //        CGFloat dpi = [[book objectForKey:@"target_dpi"] floatValue];
            NSString *title = ([book objectForKey:@"title"] == nil)? @"NO TITLE" : [book objectForKey:@"title"];
            NSString *keyName = [[self class] keyNameForNotebookId:notebookId section:section owner:owner];
            
            NeoNoteType noteType = NeoNoteTypeNormal;
            if([book objectForKey:@"kind"])
                noteType = [[book objectForKey:@"kind"] integerValue];
            
            PDFPageReferType pdfPageReferType = PDFPageReferTypeEvery;
            NSString *extra = nil;
            if((extra = [book objectForKey:@"extra_info"])) {
                if([extra hasPrefix:@"pdf_page_count"]) {
                    NSArray *tokens = [extra componentsSeparatedByString:@"="];
                    if(tokens.count == 2) {
                        NSUInteger num = [[tokens lastObject] integerValue];
                        if(num == 1)
                            pdfPageReferType = PDFPageReferTypeOne;
                        else if(num == 2)
                            pdfPageReferType = PDFPageReferTypeEvenOdd;
                    }
                }
            }
            
            NSDictionary *pages = [xml objectForKey:@"pages"];
            NSUInteger maxPage = [[pages objectForKey:@"_count"] integerValue];
            
            NSUInteger segCurrentSeq = [[[book objectForKey:@"segment_info"] objectForKey:@"_current_sequence"] integerValue];
            NSUInteger segStartPage = [[[book objectForKey:@"segment_info"] objectForKey:@"_ncode_start_page"] integerValue];
            NSUInteger segEndPage = [[[book objectForKey:@"segment_info"] objectForKey:@"_ncode_end_page"] integerValue];
            NSUInteger segPageNum = [[[book objectForKey:@"segment_info"] objectForKey:@"_size"] integerValue];
            NSUInteger segSubCode = [[[book objectForKey:@"segment_info"] objectForKey:@"_sub_code"] integerValue];
            NSUInteger segTotalSize = [[[book objectForKey:@"segment_info"] objectForKey:@"_total_size"] integerValue];
            
            NSError *error;
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"NPNotebookInfoEntity" inManagedObjectContext:localMoc];
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            [fetchRequest setEntity:entity];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"keyName LIKE  %@",keyName];
            [fetchRequest setPredicate:predicate];
            
            NSArray *results = [localMoc executeFetchRequest:fetchRequest error:&error];
            if(!isEmpty(results)){
                if(shouldReset) {
                    //for(NJNotebookEntity *notebookE in results)
                    for(NPNotebookInfoEntity *notebookE in results)
                        [localMoc deleteObject:notebookE];
                } else {
                    return; // alreay exist --> ignore
                }
            }
            
            
            NPNotebookInfoEntity *notebookInfoE = [NSEntityDescription insertNewObjectForEntityForName:@"NPNotebookInfoEntity" inManagedObjectContext:localMoc];
            notebookInfoE.keyName = keyName;
            notebookInfoE.type = [NSNumber numberWithInteger:noteType];
            notebookInfoE.title = title;
            if ([book objectForKey:@"segment_info"])
                notebookInfoE.noPages = [NSNumber numberWithInteger:segTotalSize];
            else
                notebookInfoE.noPages = [NSNumber numberWithInteger:maxPage];;
            notebookInfoE.pdfPageReferType = [NSNumber numberWithInteger:pdfPageReferType];
            
            CGFloat scale = 600.0f / 72.0f / 56.0f; // 600/72/56 ~ 0.149
            NSMutableArray *paperInfoEnityArray = [NSMutableArray array];
            
            if ([book objectForKey:@"segment_info"]) {
                for(int i = segStartPage; i <= segEndPage; i++) {
//                    NPPaperInfo *paperInfo = [NPPaperInfo new];
//                    paperInfo.puiArray = [NSMutableArray array];
//                    [notebookInfo.pages setObject:paperInfo forKey:[NSNumber numberWithInteger:i]];
                    
                    NPPaperInfoEntity *paperInfoE = [NSEntityDescription insertNewObjectForEntityForName:@"NPPaperInfoEntity" inManagedObjectContext:localMoc];
                    paperInfoE.pageNum = [NSNumber numberWithInteger:i];
                    [paperInfoEnityArray addObject:paperInfoE];
                }
            }else{
                for(int i=1; i <= maxPage; i++) {
                    NPPaperInfoEntity *paperInfoE = [NSEntityDescription insertNewObjectForEntityForName:@"NPPaperInfoEntity" inManagedObjectContext:localMoc];
                    paperInfoE.pageNum = [NSNumber numberWithInteger:i];
                    [paperInfoEnityArray addObject:paperInfoE];
                }
            }
            
            CGFloat cStartX,cStartY,cWidth,cHeight;
            cStartX = cStartY = cWidth = cHeight = 0.0f;
            // use default A4 note
            cStartX = 36.0f;
            cStartY = 36.0f;
            cWidth = 596.099f;
            cHeight = 842.395f;
            
            id pageItems = [pages objectForKey:@"page_item"];
//            if(pageItems != nil) {
//                BOOL isArray = ([pageItems isKindOfClass:[NSArray class]]);
//                NSArray *pageArray = (isArray)? pageItems : [NSArray arrayWithObject:pageItems];
//                NSDictionary *dic = [pageArray objectAtIndex:0];
//                if(dic) {
//                    cStartX = [[dic objectForKey:@"_x1"] floatValue];
//                    cStartY = [[dic objectForKey:@"_y1"] floatValue];
//                    cWidth = [[dic objectForKey:@"_x2"] floatValue];
//                    cHeight = [[dic objectForKey:@"_y2"] floatValue];
//                }
//            }
            if(pageItems != nil) {
                BOOL isArray = ([pageItems isKindOfClass:[NSArray class]]);
                NSArray *pageArray = (isArray)? pageItems : [NSArray arrayWithObject:pageItems];
                
                for (NSDictionary *dic in pageArray) {
                    NSUInteger pageNum = [[dic objectForKey:@"_number"] integerValue];
                    //NPPaperInfo *paperInfo = [notebookInfo.pages objectForKey:[NSNumber numberWithInteger:(pageNum + 1)]];
                    NPPaperInfoEntity *paperE = [paperInfoEnityArray objectAtIndex:(pageNum + 1)];
                    
                    CGFloat x1 = [[dic objectForKey:@"_x1"] floatValue];
                    CGFloat y1 = [[dic objectForKey:@"_y1"] floatValue];
                    CGFloat x2 = [[dic objectForKey:@"_x2"] floatValue];
                    CGFloat y2 = [[dic objectForKey:@"_y2"] floatValue];
                    
                    NSString *cropMargin = [dic objectForKey:@"_crop_margin"];
                    NSArray* marginArray = [cropMargin componentsSeparatedByString: @","];
                    CGFloat marginLeft = [[marginArray objectAtIndex:0] floatValue];
                    CGFloat marginRight = [[marginArray objectAtIndex:1] floatValue];
                    CGFloat marginTop = [[marginArray objectAtIndex:2] floatValue];
                    CGFloat marginBtm = [[marginArray objectAtIndex:3] floatValue];
                    
                    cStartX = marginLeft;
                    cStartY = marginTop;
                    cWidth = x2 - x1 - marginLeft - marginRight;
                    cHeight = y2 -y1 - marginTop - marginBtm;
                    
                    paperE.startX = [NSNumber numberWithFloat:(cStartX * scale)];
                    paperE.startY = [NSNumber numberWithFloat:(cStartY * scale)];
                    paperE.width = [NSNumber numberWithFloat:(cWidth * scale)];
                    paperE.height = [NSNumber numberWithFloat:(cHeight * scale)];
                    
//                    @synchronized(self) {
//                        [notebookInfo.pages setObject:paperInfo forKey:[NSNumber numberWithInteger:(pageNum + 1)]];
//                    }
                }
                
            }
            
            id symbols = [[xml objectForKey:@"symbols"] objectForKey:@"symbol"];
//            if(symbols != nil) {
//                BOOL isArray = ([symbols isKindOfClass:[NSArray class]]);
//                NSArray *symbolArray = (isArray)? symbols : [NSArray arrayWithObject:symbols];
//                
//                for(NSDictionary *symbol in symbolArray) {
//                    
//                    NSUInteger pageNum = [[symbol objectForKey:@"_page"] integerValue];
//                    NPPaperInfoEntity *paperE = [paperInfoEnityArray objectAtIndex:pageNum];
//                    
//                    CGFloat x = [[symbol objectForKey:@"_x"] floatValue];
//                    CGFloat y = [[symbol objectForKey:@"_y"] floatValue];
//                    CGFloat width = [[symbol objectForKey:@"_width"] floatValue];
//                    CGFloat height = [[symbol objectForKey:@"_height"] floatValue];
//                    NSDictionary *cmdDic = [symbol objectForKey:@"command"];
//                    NSString *cmd = [cmdDic objectForKey:@"_param"];
//                    if(cmd == nil) continue;
//                    
//                    if((pageNum == 0) && [cmd isEqualToString:@"crop_area_common"]) {
//                        cStartX = x;
//                        cStartY = y;
//                        cWidth = width;
//                        cHeight = height;
//                    } else if ([cmd isEqualToString:@"crop_area"]) {
//                        paperE.startX = [NSNumber numberWithFloat:(x * scale)];
//                        paperE.startY = [NSNumber numberWithFloat:(y * scale)];
//                        paperE.width = [NSNumber numberWithFloat:(width * scale)];
//                        paperE.height = [NSNumber numberWithFloat:(height * scale)];
//                    } else {
//                        NPPUIInfoEntity *puiE = [NSEntityDescription insertNewObjectForEntityForName:@"NPPUIInfoEntity" inManagedObjectContext:localMoc];
//                        PUICmdType cmdType = PUICmdTypeEmail;
//                        
//                        if([cmd hasPrefix:@"franklin_"]) {
//                            NSArray *tokens = [cmd componentsSeparatedByString:@"_"];
//                            NSString *type = [tokens objectAtIndex:1];
//                            
//                            if([type isEqualToString:@"m"])
//                                cmdType = PUICmdTypeActivity;
//                            else if([type isEqualToString:
//                                     @"d"])
//                                cmdType = PUICmdTypeAlarm;
//                            
//                            puiE.extraInfo = [tokens lastObject];
//                        }
//                        
//                        puiE.cmd = [NSNumber numberWithInt:cmdType];
//                        puiE.shape = [NSNumber numberWithInt:PUIShapeRectangle];
//                        puiE.startX = [NSNumber numberWithFloat:(x * scale)];
//                        puiE.startY = [NSNumber numberWithFloat:(y * scale)];
//                        puiE.width = [NSNumber numberWithFloat:(width * scale)];
//                        puiE.height = [NSNumber numberWithFloat:(height * scale)];
//                        
//                        [paperE addPuiInfoObject:puiE];
//                    }
//                }
//            }
            if(symbols != nil) {
                BOOL isArray = ([symbols isKindOfClass:[NSArray class]]);
                NSArray *symbolArray = (isArray)? symbols : [NSArray arrayWithObject:symbols];
                
                for(NSDictionary *symbol in symbolArray) {
                    
                    NSUInteger pageNum = [[symbol objectForKey:@"_page"] integerValue];
                    //NPPaperInfo *paperInfo = [notebookInfo.pages objectForKey:[NSNumber numberWithInteger:(pageNum + 1)]];
                    NPPaperInfoEntity *paperE = [paperInfoEnityArray objectAtIndex:(pageNum + 1)];
                    
                    CGFloat x = [[symbol objectForKey:@"_x"] floatValue];
                    CGFloat y = [[symbol objectForKey:@"_y"] floatValue];
                    CGFloat width = [[symbol objectForKey:@"_width"] floatValue];
                    CGFloat height = [[symbol objectForKey:@"_height"] floatValue];
                    NSDictionary *cmdDic = [symbol objectForKey:@"command"];
                    NSString *cmd = [cmdDic objectForKey:@"_param"];
                    if(cmd == nil) continue;
                    
                    //NPPUIInfo * puiInfo = [NPPUIInfo new];
                    NPPUIInfoEntity *puiE = [NSEntityDescription insertNewObjectForEntityForName:@"NPPUIInfoEntity" inManagedObjectContext:localMoc];
                    PUICmdType cmdType = PUICmdTypeEmail;
                    
                    if([cmd hasPrefix:@"franklin_"]) {
                        NSArray *tokens = [cmd componentsSeparatedByString:@"_"];
                        NSString *type = [tokens objectAtIndex:1];
                        
                        if([type isEqualToString:@"m"])
                            cmdType = PUICmdTypeActivity;
                        else if([type isEqualToString:
                                 @"d"])
                            cmdType = PUICmdTypeAlarm;
                        
                        puiE.extraInfo = [tokens lastObject];
                    }
                    
                    puiE.cmd = [NSNumber numberWithInt:cmdType];
                    puiE.shape = [NSNumber numberWithInt:PUIShapeRectangle];
                    puiE.startX = [NSNumber numberWithFloat:(x * scale)];
                    puiE.startY = [NSNumber numberWithFloat:(y * scale)];
                    puiE.width = [NSNumber numberWithFloat:(width * scale)];
                    puiE.height = [NSNumber numberWithFloat:(height * scale)];
                    
                    [paperE addPuiInfoObject:puiE];
                }
            }
            
//            if ([book objectForKey:@"segment_info"]) {
//                for(int i=segStartPage; i <= segEndPage; i++) {
//                    NPPaperInfo *paperInfo = [notebookInfo.pages objectForKey:[NSNumber numberWithInteger:i]];
//                    if(isEmpty(paperInfo)){
//                        NSLog(@"notebookId %ld pageNum %d title %@",notebookId, i, title);
//                        continue;
//                    }
//                    CGFloat w = paperInfo.width;
//                    if((w <= 0.0)) {
//                        paperInfo.startX = cStartX * scale;
//                        paperInfo.startY = cStartY * scale;
//                        paperInfo.width = cWidth * scale;
//                        paperInfo.height = cHeight * scale;
//                    }
//                    [notebookInfo.pages setObject:paperInfo forKey:[NSNumber numberWithInteger:i]];
//                }
//            }else{
//                for(int i=1; i <= maxPage; i++) {
//                    NPPaperInfo *paperInfo = [notebookInfo.pages objectForKey:[NSNumber numberWithInteger:i]];
//                    if(isEmpty(paperInfo)){
//                        NSLog(@"notebookId %ld pageNum %d title %@",notebookId, i, title);
//                        continue;
//                    }
//                    CGFloat w = paperInfo.width;
//                    if((w <= 0.0)) {
//                        paperInfo.startX = cStartX * scale;
//                        paperInfo.startY = cStartY * scale;
//                        paperInfo.width = cWidth * scale;
//                        paperInfo.height = cHeight * scale;
//                    }
//                    [notebookInfo.pages setObject:paperInfo forKey:[NSNumber numberWithInteger:i]];
//                }
//            }
            for(NPPaperInfoEntity *paperE in paperInfoEnityArray) {
                CGFloat w = [paperE.width floatValue];
                if((w <= 0.0)) {
                    paperE.startX = [NSNumber numberWithFloat:(cStartX * scale)];
                    paperE.startY = [NSNumber numberWithFloat:(cStartY * scale)];
                    paperE.width = [NSNumber numberWithFloat:(cWidth * scale)];
                    paperE.height = [NSNumber numberWithFloat:(cHeight * scale)];
                }
                [notebookInfoE addPaperInfoObject:paperE];
            }
            
            [localMoc save:&error];
            [self saveContext:NO];
            [self completeDownloadEntry_:keyName];
            // remove temporal entry
            [self.paperInfos removeObjectForKey:keyName];
            
            success = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary *userInfo = @{@"keyName":keyName,
                                           @"title":title,
                                           };
                [[NSNotificationCenter defaultCenter] postNotificationName:NPPaperInfoStorePaperBecomeAvailableNotification object:self userInfo:userInfo];
            });

        }
    };
    
    if(shouldWait)
        [localMoc performBlockAndWait:insertBlock];
    else
        [localMoc performBlock:insertBlock];
    
    return success;
}

- (id)fetchForKeyName_:(NSString *)keyName pageNum:(NSUInteger)pageNum fetchPaperInfo:(BOOL)paperInfoFetch
{
//    NSLog(@"Fetching From DB for %@ - %tu",(paperInfoFetch)?@"PaperInfo" : [NSString stringWithFormat:@"Notebook --> %@",keyName], pageNum);
    __block id fetchedInfo;
    
    NSUInteger type = NSPrivateQueueConcurrencyType;
    NSManagedObjectContext *localMoc = [[NSManagedObjectContext alloc] initWithConcurrencyType:type];
    localMoc.parentContext = self.moc;
    
    void (^fetchBlock)(void) = ^(void) {
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"NPNotebookInfoEntity" inManagedObjectContext:localMoc];
        NSError *error;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"keyName LIKE %@",keyName];
        [fetchRequest setPredicate:predicate];
        NSArray *results = [localMoc executeFetchRequest:fetchRequest error:&error];
        
        if(!isEmpty(results)) {
            NPNotebookInfoEntity *notebookInfoE = [results objectAtIndex:0];
            
            if(!paperInfoFetch) {
                NPNotebookInfo *notebookInfo = [NPNotebookInfo new];
                notebookInfo.title = notebookInfoE.title;
                notebookInfo.pdfPageReferType = [notebookInfoE.pdfPageReferType integerValue];
                notebookInfo.notebookType = [notebookInfoE.type integerValue];
                notebookInfo.maxPage = [notebookInfoE.noPages integerValue];
                //jr
                notebookInfo.isTemporal = NO;
                fetchedInfo = notebookInfo;
            } else {
                NPPaperInfoEntity *paperE = nil;
                
                for(NPPaperInfoEntity *pE in notebookInfoE.paperInfo.allObjects) {
                    if([pE.pageNum integerValue] == pageNum) {
                        paperE = pE;
                        break;
                    }
                }
                
                if(paperE) {
                    NPPaperInfo *paperInfo = [NPPaperInfo new];
                    paperInfo.width = [paperE.width floatValue];
                    paperInfo.height = [paperE.height floatValue];
                    paperInfo.startX = [paperE.startX floatValue];
                    paperInfo.startY = [paperE.startY floatValue];
                    
                    if(paperE.puiInfo) {
                        paperInfo.puiArray = [NSMutableArray array];
                        for(NPPUIInfoEntity *puiE in paperE.puiInfo.allObjects) {
                            NPPUIInfo *puiInfo = [NPPUIInfo new];
                            puiInfo.cmdType = [puiE.cmd intValue];
                            puiInfo.shape = PUIShapeRectangle;
                            puiInfo.startX = [puiE.startX floatValue];
                            puiInfo.startY = [puiE.startY floatValue];
                            puiInfo.width = [puiE.width floatValue];
                            puiInfo.height = [puiE.height floatValue];
                            puiInfo.extraInfo = puiE.extraInfo;
                            
                            [paperInfo.puiArray addObject:puiInfo];
                        }
                    }
                    fetchedInfo = paperInfo;
                }
            }
        }
    };
    [localMoc performBlockAndWait:fetchBlock];
    return fetchedInfo;
}
- (BOOL)hasPaperInfoForKeyName:(NSString *)keyName
{
    if(isEmpty(keyName)) return NO;
    
    __block NSUInteger count = 0;
    
    NSUInteger type = NSPrivateQueueConcurrencyType;
    NSManagedObjectContext *localMoc = [[NSManagedObjectContext alloc] initWithConcurrencyType:type];
    localMoc.parentContext = self.moc;
    [localMoc performBlockAndWait:^{
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"NPNotebookInfoEntity" inManagedObjectContext:localMoc];
        NSError *error;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"keyName LIKE %@",keyName];
        [fetchRequest setPredicate:predicate];
        count = [localMoc countForFetchRequest:fetchRequest error:&error];
    }];
    
    return (count > 0);
}
- (NSURL *)getPdfURLForNotebookId:(NSUInteger)notebookId section:(NSUInteger)section owner:(NSUInteger)owner
{
    NSString *keyName = [[self class] keyNameForNotebookId:notebookId section:section owner:owner];
    NSURL *pdfURL = [[self bookPDFURL] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.pdf",keyName]];
    if(![[NSFileManager defaultManager] fileExistsAtPath:pdfURL.path]) return [[NSBundle mainBundle] URLForResource:@"00000_00000_00000000" withExtension:@"pdf" subdirectory:@"NeoPenSdkResources"];
    return pdfURL;
}
- (NSImage *) getDefaultCoverImageForNotebookId:(NSUInteger)notebookId section:(NSUInteger)section owner:(NSUInteger)owner
{
    NSString *coverImgName = nil;
    
    if(notebookId >= kNPPaperInfoStore_Current_Max_NotebookId) return nil;
    NSString *keyName = [[self class] keyNameForNotebookId:notebookId section:section owner:owner];
    coverImgName = [[self bookCoverURL] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",keyName]].path;
    //NSImage *coverImg = [NSImage imageNamed:coverImgName];
    NSImage *coverImg = [[NSImage alloc] initWithContentsOfFile:coverImgName];

    return coverImg;
}
- (NSString *) getDefaultCoverNameForNotebookId:(NSUInteger)notebookId section:(NSUInteger)section owner:(NSUInteger)owner
{
    NSString *coverTitle = nil;
    
    if(notebookId >= kNPPaperInfoStore_Current_Max_NotebookId) return @"Unknown Note";
    else {
        NSString *keyName = [[self class] keyNameForNotebookId:notebookId section:section owner:owner];
        NPNotebookInfo *notebookInfo = [self getNotebookInfoForKeyName_:keyName];
        coverTitle = notebookInfo.title;
    }
    
    return coverTitle;
}





- (void)startDownloadTimer_
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if(_downloadTimer != nil)
            [self stopDownloadTimer_];
        
        _downloadTimer = [NSTimer scheduledTimerWithTimeInterval:30.0f
                                                          target:self
                                                        selector:@selector(processDownloadEntry_)
                                                        userInfo:nil
                                                         repeats:YES];
    });
}
- (void)stopDownloadTimer_
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
//        NSLog(@"download timer stopped");
        [_downloadTimer invalidate];
        _downloadTimer = nil;
    });
}
- (BOOL)loadAllDownloadEntries_
{
    NSString* path = [[self sdkDirectory_] URLByAppendingPathComponent:kNPPaperInfoStore_DownloadEntryFileName].path;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        NSData* data = [[NSData alloc] initWithContentsOfFile:path];
        NSKeyedUnarchiver* unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        
        if(isEmpty(unarchiver)) return NO;
        _downloadQueue = [unarchiver decodeObjectForKey:kNPPaperInfoStore_DownloadEntryFileName];
        [unarchiver finishDecoding];
        return YES;
        
    } else {
        _downloadQueue = [[NSMutableArray alloc] init];
        return NO;
    }
}
- (void)saveAllDownloadEntries_
{
    NSMutableData* data = [[NSMutableData alloc] init];
    NSKeyedArchiver* archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:_downloadQueue forKey:kNPPaperInfoStore_DownloadEntryFileName];
    [archiver finishEncoding];
    NSString* path = [[self sdkDirectory_] URLByAppendingPathComponent:kNPPaperInfoStore_DownloadEntryFileName].path;
    [data writeToFile:path atomically:YES];
}
- (void)addDownloadEntryForKeyName_:(NSString *)keyName
{
    dispatch_async(_download_dispatch_queue, ^{
        
        NJPaperInfoDownloadEntry *entry = [NJPaperInfoDownloadEntry new];
        entry.keyName = keyName;
        
        if([_downloadQueue containsObject:entry]) return;

        entry.isInProcess = NO;
        entry.numOfTry = 0;
        entry.timeQueued = [NSDate date];
        
        [_downloadQueue addObject:entry];
        //jr
        [self startDownloadTimer_];
        [self processDownloadEntry_];
        NSLog(@"ADD: Download Queue --> %tu",_downloadQueue.count);
        [self saveAllDownloadEntries_];
    });
}
#define MAX_DOWNLOAD_TRY    10
- (void)processDownloadEntry_
{
//    NSLog(@"initiate prcoessing download entry...");
    dispatch_async(_download_dispatch_queue, ^{
        if(isEmpty(_downloadQueue)) return;
        NSUInteger maxTry = MAX_DOWNLOAD_TRY;
        
        NJPaperInfoDownloadEntry *entryToProcess;
        NSMutableArray *entryToDiscard = [NSMutableArray array];
        
        for(NJPaperInfoDownloadEntry *entry in _downloadQueue) {
            if(!entry.isInProcess) {
                if(entry.numOfTry >= MAX_DOWNLOAD_TRY) {
                    [entryToDiscard addObject:entry];
                    continue;
                }
                if(entry.numOfTry < maxTry) {
                    maxTry = entry.numOfTry;
                    entryToProcess = entry;
                }
            }
        }
        if(!isEmpty(entryToDiscard)) {
            for(NJPaperInfoDownloadEntry *entry in entryToDiscard) {
//                NSLog(@"EXCEED MAX TRY --> remove this entry: %@",entry.keyName);
                [_downloadQueue removeObject:entry];
            }
            [self saveAllDownloadEntries_];
        }
        
        if(entryToProcess == nil) return;
        entryToProcess.isInProcess = YES;
        entryToProcess.numOfTry++;
        
//        NSLog(@"PROCESS: keyName -> %@ , Try: %02tu",entryToProcess.keyName,entryToProcess.numOfTry);
        [self requestNoteInfoForkeyName:entryToProcess.keyName];
        
    });
}
- (void)completeDownloadEntry_:(NSString *)keyName
{
    dispatch_async(_download_dispatch_queue, ^{
        
        NJPaperInfoDownloadEntry *entry = [NJPaperInfoDownloadEntry new];
        entry.keyName = keyName;
        [_downloadQueue removeObject:entry];
        
//        NSLog(@"COMPLETED --> Remove: Download Queue --> %tu",_downloadQueue.count);
        if(isEmpty(_downloadQueue))
            [self stopDownloadTimer_];
        
        [self saveAllDownloadEntries_];
    });
}
- (void)failDownloadEntry_:(NSString *)keyName
{
    dispatch_async(_download_dispatch_queue, ^{
        
        NJPaperInfoDownloadEntry *entryToProcess;
        for(NJPaperInfoDownloadEntry *entry in _downloadQueue) {
            if([entry.keyName isEqualToString:keyName]) {
                entryToProcess = entry;
                break;
            }
        }
        if(entryToProcess == nil) return;
        entryToProcess.isInProcess = NO;
    });
}




NSString *kURL_NOTE_SERVER =        @"http://nbs.neolab.net/v1/notebooks/attributes?"; // +device=ios&development=%@&owner_id=%tu&section_id=%tu&note_id=%tu

- (void)requestNoteInfoForkeyName:(NSString *)keyName
{
    
//    dispatch_semaphore_t sem = dispatch_semaphore_create(0);

    NSArray *tokens = [keyName componentsSeparatedByString:@"_"];
    if(tokens.count != 3) return;
    
    NSUInteger section = [[tokens objectAtIndex:0] integerValue];
    NSUInteger owner = [[tokens objectAtIndex:1] integerValue];
    NSUInteger notebookId = [[tokens objectAtIndex:2] integerValue];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"ios",@"device",
                            (self.isDeveloperMode)? @"true" : @"false" ,@"development",
                            [NSNumber numberWithInteger:notebookId],@"note_id",
                            [NSNumber numberWithInteger:owner],@"owner_id",
                            [NSNumber numberWithInteger:section],@"section_id",
                            nil];
    
    [[NJNetworkManager sharedManager] GET:kURL_NOTE_SERVER parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        if(httpResponse.statusCode != 200) return;
        
        NSDictionary *json = responseObject;
        NSArray *attArray = [json objectForKey:@"attributes"];
        if(isEmpty(attArray)) {
//            NSLog(@"This notebook has no infomation. -- should REMOVED FROM THE LIST");
            return;
        }
        NSDictionary *att = [attArray objectAtIndex:0];
        NSDictionary *res = [att objectForKey:@"resource"];
        if(isEmpty(res)) return;
        NSString *zipPath = [res objectForKey:@"zipfile"];
        if(isEmpty(zipPath)) return;
        
        NSString *newZipPath = [zipPath stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        NSURL *URL = [NSURL URLWithString:newZipPath];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        NSURL *targetURL = [self bookTmpURL_];
        targetURL = [targetURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.zip",keyName]];
        
        NSURLSessionDownloadTask *downloadTask = [[NJNetworkManager sharedManager] downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            return targetURL;
            
        } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
         
//            dispatch_semaphore_signal(sem);
            if(error) return;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                
                [self unzipFile:targetURL keyName:keyName];
                if(self.nprojURLArray.count > 1){
                    for(NSURL *url in self.nprojURLArray){
                        NSString *filePath = url.path;
                        if(filePath == nil) return;
                        NSDictionary *xmlDoc = [NSDictionary dictionaryWithXMLFile:filePath];
                        if(isEmpty(xmlDoc))
                            [self failDownloadEntry_:keyName];
                        else
                            [self insertDBFromXML_:xmlDoc shouldReset:NO shouldWait:NO];
                    }
                }else{
                    NSString *filePath = [[self bookTmpURL_] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.nproj",keyName]].path;
                    if(filePath == nil) return;
                    NSDictionary *xmlDoc = [NSDictionary dictionaryWithXMLFile:filePath];
                    if(isEmpty(xmlDoc))
                        [self failDownloadEntry_:keyName];
                    else
                        [self insertDBFromXML_:xmlDoc shouldReset:NO shouldWait:NO];
                }
                
            });
        }];
        [downloadTask resume];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {

//        dispatch_semaphore_signal(sem);
        [self failDownloadEntry_:keyName];
    }];
    
//    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
}

- (BOOL)unzipFile:(NSURL *)zipFile keyName:(NSString *)keyName
{
    NSUInteger count = 0;
    NSUInteger jpgCount = 0;
    [self.nprojURLArray removeAllObjects];
    ZZArchive* archive = [ZZArchive archiveWithURL:zipFile error:nil];
    
    for (ZZArchiveEntry* entry in archive.entries)
    {
        NSString *ext = entry.fileName.pathExtension;
        if(isEmpty(ext)) continue;
        NSString *lastComp = [entry.fileName lastPathComponent];
        if([lastComp hasPrefix:@"."]) continue;

        if([ext isEqualToString:@"nproj"])
            count++;
        else if([ext isEqualToString:@"jpg"])
            jpgCount++;
        else
            continue;
    }
    
    for (ZZArchiveEntry* entry in archive.entries)
    {
        if (entry.fileMode & S_IFDIR) {
//            this is directory
//            [fm createDirectoryAtURL:targetPath withIntermediateDirectories:YES attributes:nil error:nil];
        } else {
            
            NSString *ext = entry.fileName.pathExtension;
            if(isEmpty(ext)) continue;
            NSString *lastComp = [entry.fileName lastPathComponent];
            if([lastComp hasPrefix:@"."]) continue;
            
//            NSLog(@"file name ---> %@",entry.fileName);
            
            NSURL* targetPath = nil;
            if([ext isEqualToString:@"nproj"])
                targetPath = [self bookTmpURL_];
            else if([ext isEqualToString:@"png"])
                targetPath = [self bookCoverURL];
            else if([ext isEqualToString:@"pdf"])
                targetPath = [self bookPDFURL];
            else if([ext isEqualToString:@"jpg"])
                targetPath = [self bookBgImgURL];
            else
                continue;
            
            NSArray *tokens = [entry.fileName componentsSeparatedByString:@"_"];
            
            if ((count > 1) && [ext isEqualToString:@"nproj"]) {
                NSString *segmentOrderStr;
                for(NSString *string in tokens){
                    if ([string containsString:@"nproj"]) {
                        segmentOrderStr = string;
                        break;
                    }
                }
                NSInteger segmentOrder = [segmentOrderStr integerValue];
                NSString *keyName1 = [NSString stringWithFormat:@"%@_%05tu",keyName, segmentOrder];
                targetPath = [targetPath URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",keyName1,ext] isDirectory:NO];
                [self.nprojURLArray addObject:targetPath];
            }else if((jpgCount > 1) && [ext isEqualToString:@"jpg"]) {
                NSString *segmentOrderStr;
                for(NSString *string in tokens){
                    if ([string containsString:@"jpg"]) {
                        segmentOrderStr = string;
                        break;
                    }
                }
                NSInteger segmentOrder = [segmentOrderStr integerValue];
                NSString *keyName1 = [NSString stringWithFormat:@"%@_%05tu",keyName, segmentOrder];
                targetPath = [targetPath URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",keyName1,ext] isDirectory:NO];
            }else{
                targetPath = [targetPath URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",keyName,ext] isDirectory:NO];
            }
            [[entry newDataWithError:nil] writeToURL:targetPath atomically:NO];
        }
    }
    return YES;
}

- (BOOL)installNotebookInfoForKeyName:(NSString *)keyName zipFilePath:(NSURL *)zipFilePath deleteExisting:(BOOL)deleteExisting
{
    BOOL success = NO;
    // simple error check
    if(isEmpty(keyName)) return NO;
    if([keyName componentsSeparatedByString:@"_"].count != 3) return NO;
    
    [self unzipFile:zipFilePath keyName:keyName];
    
    if(self.nprojURLArray.count > 1){
        for(NSURL *url in self.nprojURLArray){
            NSString *filePath = url.path;
            if(filePath == nil) return NO;
            NSDictionary *xmlDoc = [NSDictionary dictionaryWithXMLFile:filePath];
            if(isEmpty(xmlDoc))
                return NO;
            else
                success = [self insertDBFromXML_:xmlDoc shouldReset:deleteExisting shouldWait:YES];
        }
    }else{
        NSString *filePath = [[self bookTmpURL_] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.nproj",keyName]].path;
        if(filePath == nil) return NO;
        NSDictionary *xmlDoc = [NSDictionary dictionaryWithXMLFile:filePath];
        if(isEmpty(xmlDoc))
            return NO;
        else
            success = [self insertDBFromXML_:xmlDoc shouldReset:deleteExisting shouldWait:YES];
    }
    
    return success;
}

- (NSInteger)getEstimateNoteTypeFromDB:(CGSize)paperSize
{
    //    NSLog(@"Fetching From DB for %@ - %tu",(paperInfoFetch)?@"PaperInfo" : [NSString stringWithFormat:@"Notebook --> %@",keyName], pageNum);
    NSUInteger estimatedNoteType = INT_MAX;
    __block id noteType;
    CGFloat epsilon = 0.01f;
    
    NSUInteger type = NSPrivateQueueConcurrencyType;
    NSManagedObjectContext *localMoc = [[NSManagedObjectContext alloc] initWithConcurrencyType:type];
    localMoc.parentContext = self.moc;
    
    void (^fetchBlock)(void) = ^(void) {
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"NPNotebookInfoEntity" inManagedObjectContext:localMoc];
        NSError *error;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        
        NSArray *results = [localMoc executeFetchRequest:fetchRequest error:&error];
        
        if(!isEmpty(results)) {
            
            NPPaperInfoEntity *paperE = nil;
            NSUInteger pageNum = 1;
            
            for(NPNotebookInfoEntity *notebookInfoE in results){
                for(NPPaperInfoEntity *pE in notebookInfoE.paperInfo.allObjects) {
                    if([pE.pageNum integerValue] == pageNum) {
                        paperE = pE;
                        break;
                    }
                }
                CGFloat w = [paperE.width floatValue];
                CGFloat h = [paperE.height floatValue];
                
                if((fabs(w - paperSize.width) <= epsilon) && (fabs(h - paperSize.height) <= epsilon)) {
                    noteType = notebookInfoE.type;
                    break;
                }
            }
            
        }
    };
    [localMoc performBlockAndWait:fetchBlock];
    
    estimatedNoteType = [noteType integerValue];
    return estimatedNoteType;
}

- (NSMutableArray *) notesSupportedFromDB
{
    //    NSLog(@"Fetching From DB for %@ - %tu",(paperInfoFetch)?@"PaperInfo" : [NSString stringWithFormat:@"Notebook --> %@",keyName], pageNum);
    __block id noteIdArray;
    
    NSUInteger type = NSPrivateQueueConcurrencyType;
    NSManagedObjectContext *localMoc = [[NSManagedObjectContext alloc] initWithConcurrencyType:type];
    localMoc.parentContext = self.moc;
    
    void (^fetchBlock)(void) = ^(void) {
        
        NSMutableArray *noteIds = [NSMutableArray array];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"NPNotebookInfoEntity" inManagedObjectContext:localMoc];
        NSError *error;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        
        NSArray *results = [localMoc executeFetchRequest:fetchRequest error:&error];
        
        if(!isEmpty(results)) {
            NSUInteger section, owner, noteId;
            for(NPNotebookInfoEntity *notebookInfoE in results){
                [NPPaperManager notebookId:&noteId section:&section owner:&owner fromKeyName:notebookInfoE.keyName];
                NSMutableArray *tempNoteIds = [NSMutableArray array];
                [tempNoteIds addObject:[NSNumber numberWithInteger:noteId]];
                NSArray *noteIdArr = [NSArray arrayWithArray:tempNoteIds];
                
                NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                        noteIdArr, @"noteIds",
                                        [NSNumber numberWithInteger:section], @"section",
                                        [NSNumber numberWithInteger:owner], @"owner",
                                        nil];
                [noteIds addObject:params];
            }
            noteIdArray = noteIds;
        }
    };
    [localMoc performBlockAndWait:fetchBlock];

    return noteIdArray;
}

- (NSURL *) sdkDirectory_
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libDicrectory = paths[0];
    NSURL *URL = [NSURL fileURLWithPath:[libDicrectory stringByAppendingPathComponent:@"NeoSDK"]];
    [URL setResourceValue:[NSNumber numberWithBool:YES] forKey:@"NSURLIsExcludedFromBackupKey" error:nil];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if(![fm fileExistsAtPath:URL.path])
        [fm createDirectoryAtURL:URL withIntermediateDirectories:NO attributes:nil error:NULL];
    
    return URL;
}
- (NSURL *)dbStoreURL_
{
    NSURL *URL = [[self sdkDirectory_] URLByAppendingPathComponent:@"NeoSDK_v2.sqlite"];
    [URL setResourceValue:[NSNumber numberWithBool:YES] forKey:@"NSURLIsExcludedFromBackupKey" error:nil];
    return URL;
}
- (NSURL *) bookTmpURL_
{
    NSURL *URL = [[self sdkDirectory_] URLByAppendingPathComponent:@"tmp"];
    [URL setResourceValue:[NSNumber numberWithBool:YES] forKey:@"NSURLIsExcludedFromBackupKey" error:nil];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if(![fm fileExistsAtPath:URL.path])
        [fm createDirectoryAtURL:URL withIntermediateDirectories:NO attributes:nil error:NULL];
    
    return URL;
}
- (NSURL *) bookCoverURL
{
    NSURL *URL = [[self sdkDirectory_] URLByAppendingPathComponent:@"book_cover"];
    [URL setResourceValue:[NSNumber numberWithBool:YES] forKey:@"NSURLIsExcludedFromBackupKey" error:nil];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if(![fm fileExistsAtPath:URL.path])
        [fm createDirectoryAtURL:URL withIntermediateDirectories:NO attributes:nil error:NULL];
    
    return URL;
}
- (NSURL *) bookPDFURL
{
    NSURL *URL = [[self sdkDirectory_] URLByAppendingPathComponent:@"book_pdf"];
    [URL setResourceValue:[NSNumber numberWithBool:YES] forKey:@"NSURLIsExcludedFromBackupKey" error:nil];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if(![fm fileExistsAtPath:URL.path])
        [fm createDirectoryAtURL:URL withIntermediateDirectories:NO attributes:nil error:NULL];
    
    return URL;
}
- (NSURL *) bookBgImgURL
{
    NSURL *URL = [[self sdkDirectory_] URLByAppendingPathComponent:@"book_bgimg"];
    [URL setResourceValue:[NSNumber numberWithBool:YES] forKey:@"NSURLIsExcludedFromBackupKey" error:nil];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if(![fm fileExistsAtPath:URL.path])
        [fm createDirectoryAtURL:URL withIntermediateDirectories:NO attributes:nil error:NULL];
    
    return URL;
}
- (void)clearTmpDirectory
{
    NSString *tmpPath = [self bookTmpURL_].path;
    NSArray* tmpDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:tmpPath error:NULL];
    for (NSString *file in tmpDirectory) {
        [[NSFileManager defaultManager] removeItemAtPath:[tmpPath stringByAppendingPathComponent:file] error:NULL];
    }
}
@end









#define kNJPaperInfoDownloadEntryKeyName                @"kNJPaperInfoDownloadEntryKeyName"
#define kNJPaperInfoDownloadEntryTimeQueued             @"kNJPaperInfoDownloadEntryTimeQueued"
#define kNJPaperInfoDownloadEntryNumOfTry               @"kNJPaperInfoDownloadEntryNumOfTry"
#define kNJPaperInfoDownloadEntryIsInProcess            @"kNJPaperInfoDownloadEntryIsInProcess"
#define kNJPaperInfoDownloadEntryHasCompleted           @"kNJPaperInfoDownloadEntryHasCompleted"

@implementation NJPaperInfoDownloadEntry

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self) {
        [self setKeyName:[aDecoder decodeObjectForKey:@"kNJPaperInfoDownloadEntryKeyName"]];
        [self setTimeQueued:[aDecoder decodeObjectForKey:@"kNJPaperInfoDownloadEntryTimeQueued"]];
        [self setNumOfTry:[aDecoder decodeIntegerForKey:@"kNJPaperInfoDownloadEntryNumOfTry"]];
//        [self setIsInProcess:[aDecoder decodeBoolForKey:@"kNJPaperInfoDownloadEntryIsInProcess"]];
//        [self setHasCompleted:[aDecoder decodeBoolForKey:@"kNJPaperInfoDownloadEntryHasCompleted"]];
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_keyName forKey:@"kNJPaperInfoDownloadEntryKeyName"];
    [aCoder encodeObject:_timeQueued forKey:@"kNJPaperInfoDownloadEntryTimeQueued"];
    [aCoder encodeInteger:_numOfTry forKey:@"kNJPaperInfoDownloadEntryNumOfTry"];
//    [aCoder encodeBool:_isInProcess forKey:@"kNJPaperInfoDownloadEntryIsInProcess"];
//    [aCoder encodeBool:_hasCompleted forKey:@"kNJPaperInfoDownloadEntryHasCompleted"];
}
- (BOOL)isEqual:(id)object
{
    NJPaperInfoDownloadEntry *rhs = (NJPaperInfoDownloadEntry *)object;
    return [self.keyName isEqualToString:rhs.keyName];
}

@end



