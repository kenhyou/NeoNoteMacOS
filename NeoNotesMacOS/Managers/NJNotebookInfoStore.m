//
//  NJNotebookInfoStore.m
//  NeoJournal
//
//  Created by NamSSan on 10/08/2014.
//  Copyright (c) 2014 Neolab. All rights reserved.
//

#import "NJNotebookInfoStore.h"
#import "NJNotebookInfo.h"
#import "NJCoverManager.h"
#import "NJNotebookIdStore.h"

//#import "NJNotebook.h"
//#import "NJNotebookDocument.h"
#import "NJNotebookReaderManager.h"

#define kNOTEBOOK_INFO_FILE_NAME    @"notebook.info"
#define kNOTEBOOK_INFO_KEY          @"notebook_info"
//#define kMAX_NOTE_ID   1000

@implementation NJNotebookInfoStore



+ (NJNotebookInfoStore *)sharedStore
{
    static NJNotebookInfoStore *sharedStore = nil;
    
    @synchronized(self) {
        
        if(!sharedStore) {
            sharedStore = [[super allocWithZone:nil] init];
            
        }
    }
    
    return sharedStore;
}




- (id)init
{
    self = [super init];
    
    if(self) {
        
        [self _findMaxDigitalNoteNumber];
    }
    
    return self;
}



- (void)dealloc
{
    

    
}



- (void)_findMaxDigitalNoteNumber
{
    NJNotebookReaderManager *reader = [NJNotebookReaderManager sharedInstance];
    NSArray *allNotebookList = [reader digitalNotebookList];
    
    _curDigitalNoteId = kNOTEBOOK_ID_START_DIGITAL;
    
    for(int i=0; i < allNotebookList.count; i++) {
        
        NSUInteger noteId = [NJNotebookIdStore noteIdFromUuid:[allNotebookList objectAtIndex:i]];
        
        if(noteId < kNOTEBOOK_ID_START_DIGITAL) continue;
        
        if(noteId > _curDigitalNoteId)
            _curDigitalNoteId = noteId;
    }
    
    NSLog(@"[NJNotebookInfoStore] current max digital notebook Id is %d",(int)_curDigitalNoteId++);
}



- (NSString *)_getNotebookInfoPath:(NSString *)notebookUuid shouldCreatePath:(BOOL)create
{
    NJNotebookReaderManager *reader = [NJNotebookReaderManager sharedInstance];
    NSString *notebookPath = [reader notebookPathForUuid:notebookUuid];
    
    if(create) {
        NSFileManager *fm = [NSFileManager defaultManager];
        if(![fm fileExistsAtPath:notebookPath])
            [fm createDirectoryAtPath:notebookPath withIntermediateDirectories:NO attributes:nil error:NULL];
    }
    notebookPath = [notebookPath stringByAppendingPathComponent:kNOTEBOOK_INFO_FILE_NAME];
    return notebookPath;
}




- (NJNotebookInfo *)_readNotebookInfo:(NSString *)notebookUuid
{
    
    NSString* path = [self _getNotebookInfoPath:notebookUuid shouldCreatePath:NO];
    
    NJNotebookInfo *noteInfo = nil;
    
	if ([[NSFileManager defaultManager] fileExistsAtPath:path])
	{
		NSData* data = [[NSData alloc] initWithContentsOfFile:path];
		NSKeyedUnarchiver* unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        
        noteInfo = [unarchiver decodeObjectForKey:kNOTEBOOK_INFO_KEY];
		[unarchiver finishDecoding];
        
    } else {

        
	}
    
    path = nil;
    return noteInfo;
}



- (BOOL)_writeNotebookInfo:(NJNotebookInfo *)notebookInfo
{
    NSLog(@"Writing Notebook Info...");

    NSMutableData* data = [[NSMutableData alloc] init];
    
	NSKeyedArchiver* archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    
    [archiver encodeObject:notebookInfo forKey:kNOTEBOOK_INFO_KEY];
    [archiver finishEncoding];
    
    BOOL success = [data writeToFile:[self _getNotebookInfoPath:notebookInfo.notebookUuid shouldCreatePath:YES] atomically:YES];

    // temporarily added
    
    //NJNotebookReaderManager *reader = [NJNotebookReaderManager sharedInstance];
    
    //BOOL result = [reader openNotebookInfoData:notebookInfo.notebookId];
    
    //if (!result) {
    //    NSLog(@"notebook info reading fail");
    //}
    
    //reader.notebookDocument.notebook.title = notebookInfo.notebookTitle;
    //reader.notebookDocument.notebook.cTime = notebookInfo.createdDate;
    //reader.notebookDocument.notebook.mTime = notebookInfo.lastModifiedDate;
    
    //[reader saveNotebook:notebookInfo.notebookId];
    
    return success;
}


/*
- (BOOL)createdNewNotebook:(NJNotebookInfo *)notebookInfo
{
    if(notebookInfo.notebookId <= 0 || notebookInfo.notebookId > 10000) return NO;
    
    return [self _writeNotebookInfo:notebookInfo];
   
}
*/

- (NJNotebookInfo *)_createDigitalNotebookDefaultInfo
{
    NJNotebookInfo *noteInfo = [[NJNotebookInfo alloc] init];
    NSUInteger notebookId = ++_curDigitalNoteId;
        
    noteInfo.notebookId = notebookId;
    noteInfo.notebookUuid = [[NJNotebookIdStore sharedStore] notebookIdNameForDigitalNotebook:notebookId];
    noteInfo.notebookTitle = [NJCoverManager getCoverName:notebookId shouldCreateUniqTitle:YES];
    noteInfo.createdDate = [NSDate date];
    noteInfo.lastModifiedDate = [NSDate date];
    
    // only digital notebook can have custom cover image.
    //if(notebookId >= kNOTEBOOK_ID_START_DIGITAL)
        //noteInfo.coverImage = [NJCoverManager getCoverResourceImage:notebookId];
    
    if ([self _writeNotebookInfo:noteInfo] == NO)
        return nil;
    
    
    return noteInfo;
}




- (NJNotebookInfo *)createNewDigitalNotebookInfo
{
    
    return [self _createDigitalNotebookDefaultInfo];
}


- (NJNotebookInfo *)createNewNotebookInfo:(NSUInteger)notebookId
{
    
    NJNotebookInfo *noteInfo = [[NJNotebookInfo alloc] init];
    
    noteInfo.notebookId = notebookId;
    noteInfo.notebookUuid = [[NJNotebookIdStore sharedStore] notebookIdName:notebookId];
    noteInfo.notebookTitle = [NJCoverManager getCoverName:notebookId shouldCreateUniqTitle:YES];
    noteInfo.createdDate = [NSDate date];
    noteInfo.lastModifiedDate = [NSDate date];

    // only digital notebook can have custom cover image.
    //if(notebookId >= kNOTEBOOK_ID_START_DIGITAL)
    //noteInfo.coverImage = [NJCoverManager getCoverResourceImage:notebookId];
    
    if ([self _writeNotebookInfo:noteInfo] == NO)
        return nil;
    
    
    return noteInfo;
}


- (NJNotebookInfo *)getNotebookInfoForGuid:(NSString *)notebookGuid
{
    if(isEmpty(notebookGuid)) return nil;
    
    NJNotebookReaderManager *reader = [NJNotebookReaderManager sharedInstance];
    NSArray *noteList = [reader totalNotebookList];
    
    for(NSString *notebookUuid in noteList) {
        
        NJNotebookInfo *notebookInfo = [self _readNotebookInfo:notebookUuid];
        if(isEmpty(notebookInfo) || isEmpty(notebookInfo.notebookGuid)) continue;
        if([notebookInfo.notebookGuid isEqualToString:notebookGuid])
            return notebookInfo;
    }

    return nil;
}
- (NJNotebookInfo *)getNotebookInfo:(NSString *)notebookUuid
{
    //if(notebookId <= 0 || notebookId > kMAX_NOTE_ID) return nil;
   
    
    return [self _getNotebookInfo:notebookUuid shouldCreateDefault:NO autoSave:NO];
}

- (NJNotebookInfo *)getNotebookInfoWithDefaultInfo:(NSString *)notebookUuid
{
    //if(notebookId <= 0 || notebookId > kMAX_NOTE_ID) return nil;
    
    
    return [self _getNotebookInfo:notebookUuid shouldCreateDefault:YES autoSave:NO];
}

- (NJNotebookInfo *)getNotebookInfoWithDefaultInfo:(NSString *)notebookUuid autoSave:(BOOL)save
{
    return [self _getNotebookInfo:notebookUuid shouldCreateDefault:YES autoSave:YES];
}
- (NJNotebookInfo *)_getNotebookInfo:(NSString *)notebookUuid shouldCreateDefault:(BOOL)createDefault autoSave:(BOOL)save
{
    NJNotebookInfo *noteInfo = [self _readNotebookInfo:notebookUuid];
    NSUInteger notebookId = [NJNotebookIdStore noteIdFromUuid:notebookUuid];
    
    if(isEmpty(noteInfo) && createDefault) {
        noteInfo = [[NJNotebookInfo alloc] init];
        noteInfo.notebookId = notebookId;
        noteInfo.notebookUuid = notebookUuid;
        noteInfo.notebookTitle = [NJCoverManager getCoverName:notebookId shouldCreateUniqTitle:save];
        noteInfo.createdDate = [NSDate date];
        noteInfo.lastModifiedDate = [NSDate date];
        
        if(save) {
            [self _writeNotebookInfo:noteInfo];
        }
    }
    
    return noteInfo;
}

//- (NJNotebookInfo *)getNotebookInfo:(NSString *)notebookUuid shouldCreateDefault:(BOOL)createDefault isTemporal:(BOOL)isTemporal autoSave:(BOOL)save
//{
//    NJNotebookInfo *noteInfo = [self _readNotebookInfo:notebookUuid];
//    NSUInteger notebookId = [NJNotebookIdStore noteIdFromUuid:notebookUuid];
//    
//    if(isEmpty(noteInfo) && createDefault) {
//        noteInfo = [[NJNotebookInfo alloc] init];
//        noteInfo.notebookId = notebookId;
//        noteInfo.notebookUuid = notebookUuid;
//        noteInfo.notebookTitle = [NJCoverManager getCoverName:notebookId shouldCreateUniqTitle:save];
//        noteInfo.createdDate = [NSDate date];
//        noteInfo.lastModifiedDate = [NSDate date];
//
//        if(save) {
//            [self _writeNotebookInfo:noteInfo];
//        }
//    }
//    
//    return noteInfo;
//}

- (BOOL)updateNotebookInfo:(NJNotebookInfo *)notebookInfo
{

    if(isEmpty(notebookInfo)) return NO;
    //if(notebookInfo.notebookId <= 0 || notebookInfo.notebookId > kMAX_NOTE_ID) return NO;
    
    
    return [self _writeNotebookInfo:notebookInfo];
    
}


//- updateNotebook:(NSUInteger)notebookId forTitle:(NSString *)string;


- (BOOL)checkIfSameNotebookNameAlreadyExist:(NSString *)notebookTitle
{
    BOOL found = NO;
    
    NJNotebookReaderManager *reader = [NJNotebookReaderManager sharedInstance];
    NSArray *allNotebookList = [reader totalNotebookList];

    for(NSString *notebookUuid in allNotebookList) {
        NJNotebookInfo *notebookInfo = [self getNotebookInfo:notebookUuid];
        if([notebookInfo.notebookTitle isEqual:notebookTitle]) {
            found = YES;
            break;
        }
            
    }
    return found;
}


/* Utility function for restor/backup */
+ (BOOL)writeNotebookInfo:(NJNotebookInfo *)notebookInfo inDirectory:(NSString*)directory
{
    
    NSMutableData* data = [[NSMutableData alloc] init];
    NSKeyedArchiver* archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:notebookInfo forKey:kNOTEBOOK_INFO_KEY];
    [archiver finishEncoding];
    NSString *path = [directory stringByAppendingPathComponent:kNOTEBOOK_INFO_FILE_NAME];
    BOOL success = [data writeToFile:path atomically:YES];
    return success;
}
@end
