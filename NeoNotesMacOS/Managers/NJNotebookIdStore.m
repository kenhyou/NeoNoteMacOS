//
//  NJNotebookNameStore.m
//  NeoJournal
//
//  Created by NamSSan on 17/09/2014.
//  Copyright (c) 2014 Neolab. All rights reserved.
//

#import "NJNotebookIdStore.h"
#import "NJVoiceManager.h"
#import "NJNotebookInfo.h"
#import "NJNotebookInfoStore.h"

NSString * const kNoteboookUUIDTableFileName = @"nj_notebook_uuid_table_fn";
NSString * NJNotebookIdStoreSealLabelScanned = @"NJNotebookIdStoreSealLabelScanned";

@interface NJNotebookIdEntry : NSObject <NSCoding>
@property (nonatomic) NSUInteger noteType;
@property (nonatomic, strong) NSString *UUID;
@property (nonatomic, strong) NSDate *timeCreated;
@end

@implementation NJNotebookIdStore



+ (NJNotebookIdStore *)sharedStore
{
    static NJNotebookIdStore *sharedStore = nil;
    
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
        
        // load existing table -- last active uuid for each note type
        // or re-construct table from every launching of the app --> not works
        [self loadAllItems];
        
    }
    return self;
}


- (NSString *)itemArchivePath
{
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
    
	return [documentsDirectory stringByAppendingPathComponent:kNoteboookUUIDTableFileName];
}





- (BOOL)loadAllItems
{
	NSString* path = [self itemArchivePath];
    
	if ([[NSFileManager defaultManager] fileExistsAtPath:path])
	{
        
		NSData* data = [[NSData alloc] initWithContentsOfFile:path];
		NSKeyedUnarchiver* unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        
        _notebook_uuid_table = [unarchiver decodeObjectForKey:kNoteboookUUIDTableFileName];
		[unarchiver finishDecoding];
        [self _printAllItems];
        return YES;
        
    } else {
        
        _notebook_uuid_table = [[NSMutableArray alloc] init];
        //[self addSampleItems];
        return NO;
	}
}



- (void)_printAllItems
{
    if(isEmpty(_notebook_uuid_table)) return;
    
    NSLog(@"\n\n");
    NSLog(@"**************** NotebookID Table **********************\n");
    NSLog(@"   INDEX     |    NOTE_TYPE     |           UUID        \n");
    NSLog(@"********************************************************\n");
    int count = 0;
    
    for(NJNotebookIdEntry *entry in _notebook_uuid_table) {
    
        NSLog(@"%05d        |      %07lu     | %@",++count,(unsigned long)entry.noteType,entry.UUID);
        
    }
    NSLog(@"********************************************************\n");
}



- (void)saveAllItems
{
    NSMutableData* data = [[NSMutableData alloc] init];
    
    NSKeyedArchiver* archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    
    [archiver encodeObject:_notebook_uuid_table forKey:kNoteboookUUIDTableFileName];
    
    [archiver finishEncoding];
    [data writeToFile:[self itemArchivePath] atomically:YES];
    NSLog(@"Saving All Notebook ID entries to...%@\n",[self itemArchivePath]);
}

- (NSString *)notebookIdName:(NSUInteger)notebookId
{
    NSString *notebookUuid = nil;
    if(((NSInteger)notebookId) <= 0 || notebookId > 99999999) {
        
        // if this error happenes. we will have to check source code and modify according to new uuid protocol
        //NSAssert(NO, @"got cha!! notebook ID %lu is invalid, will create unknown notebook and folders",(unsigned long)notebookUuid);
        return nil;
    }
    
    for(NJNotebookIdEntry *entry in _notebook_uuid_table) {
        
        if(entry.noteType == notebookId) {
            notebookUuid = entry.UUID;
            return notebookUuid;
        }
    }
    
    return [self _notebookIdName:notebookId];
}
- (NSString *)notebookIdNameForDigitalNotebook:(NSUInteger)notebookId
{
    return [self _notebookIdName:notebookId];
}
- (NSString *)_notebookIdName:(NSUInteger)notebookId
{
    
    NSString *notebookUuid = nil;
    //if not exist in the table - create one
    // crate NEW
    notebookUuid = [NSString stringWithFormat:@"%05ld_%@",(unsigned long)notebookId,[NJNotebookIdStore createUuid]];
    
    // add New entry into table
    NJNotebookIdEntry *entry = [[NJNotebookIdEntry alloc] init];
    entry.noteType = notebookId;
    entry.UUID = notebookUuid;
    entry.timeCreated = [NSDate date];
    [_notebook_uuid_table addObject:entry];
    [self saveAllItems];
    [self _printAllItems];
    
    return notebookUuid;
}
- (NSString *)getCurrentActiveNotebookUuid:(NSUInteger)notebookId
{
    NSString *notebookUuid = nil;
    if(((NSInteger)notebookId) <= 0 || notebookId > 99999999) {
        
        // if this error happenes. we will have to check source code and modify according to new uuid protocol
        //NSAssert(NO, @"got cha!! notebook ID %lu is invalid, will create unknown notebook and folders",(unsigned long)notebookUuid);
        return nil;
    }
    
    for(NJNotebookIdEntry *entry in _notebook_uuid_table) {
        
        if(entry.noteType == notebookId) {
            notebookUuid = entry.UUID;
            return notebookUuid;
        }
    }
    
    return nil;
}


#define kMINIMUM_SEAL_SCAN_INTERVAL_IN_MINUTES 1

- (NSString *)sealLabelScanned:(NSUInteger)notebookId
{
    if(notebookId == 898 || notebookId == 899 || notebookId >= kNOTEBOOK_ID_START_DIGITAL)
        return nil;
    if([NJVoiceManager sharedInstance].isRecording) return nil;
    
    NSString *notebookUuid = nil;
    //notebookId = 602;
    NSMutableArray *discardedItems = [[NSMutableArray alloc] init];
    for(NJNotebookIdEntry *entry in _notebook_uuid_table) {
        
        if(entry.noteType == notebookId) {
            if(!isEmpty(entry.timeCreated)) {
                NSTimeInterval timeInterval = [entry.timeCreated timeIntervalSinceNow];
                if(timeInterval <= 0)
                    timeInterval *= -1;
                //NSLog(@"time interval is %fl",timeInterval);
                if(timeInterval <= (kMINIMUM_SEAL_SCAN_INTERVAL_IN_MINUTES * 60)) {
                    NSString *msg = [NSString stringWithFormat:@"*********************\n Can not create new notebook. minimum interval is set to %d minutes\n*********************",kMINIMUM_SEAL_SCAN_INTERVAL_IN_MINUTES];
                    NSLog(@"%@",msg);
                    //ShowPopupMessage(@"SORRY!", msg);
                    return entry.UUID;
                }
            }
            //[_notebook_uuid_table removeObject:entry];
            [discardedItems addObject:entry];
            break;
        }
    }
    if(!isEmpty(discardedItems))
        [_notebook_uuid_table removeObjectsInArray:discardedItems];
    
    //if not exist in the table - create one
    [[NJNotebookWriterManager sharedInstance] closeCurrentNotebook];
    // crate NEW
    notebookUuid = [NSString stringWithFormat:@"%05ld_%@",(unsigned long)notebookId,[NJNotebookIdStore createUuid]];
    
    // add New entry into table
    NJNotebookIdEntry *entry = [[NJNotebookIdEntry alloc] init];
    entry.noteType = notebookId;
    entry.UUID = notebookUuid;
    entry.timeCreated = [NSDate date];
    [_notebook_uuid_table addObject:entry];
    [self saveAllItems];
    [self _printAllItems];
    [[NJNotebookInfoStore sharedStore] createNewNotebookInfo:notebookId];
    [[NSNotificationCenter defaultCenter] postNotificationName:NJNotebookIdStoreSealLabelScanned object:nil userInfo:nil];
    return notebookUuid;
}


- (void)activateNotebookUuid:(NSString *)notebookUuid
{
    BOOL isDigital = [NJNotebookIdStore isDigitalNote:notebookUuid];
    if(isDigital) {
        NJNotebookInfo *notebookInfo = [[NJNotebookInfoStore sharedStore] getNotebookInfo:notebookUuid];
        notebookInfo.archivedDate = nil;
        [[NJNotebookInfoStore sharedStore] updateNotebookInfo:notebookInfo];
    }
    NSUInteger noteType = [NJNotebookIdStore noteIdFromUuid:notebookUuid];
    NSDate *lastCreated = nil;
    NSMutableArray *discardedItems = [[NSMutableArray alloc] init];
    for(NJNotebookIdEntry *entry in _notebook_uuid_table) {
        
        if((isDigital && ([entry.UUID isEqualToString:notebookUuid])) || (!isDigital && (entry.noteType == noteType))) {
            lastCreated = entry.timeCreated;
            //[_notebook_uuid_table removeObject:entry];
            [discardedItems addObject:entry];
            if([[NJNotebookWriterManager sharedInstance] isActiveNotebook:entry.UUID])
                [[NJNotebookWriterManager sharedInstance] closeCurrentNotebook];
            //break;
        }
    }
    if(!isEmpty(discardedItems))
        [_notebook_uuid_table removeObjectsInArray:discardedItems];
    // add New entry into table
    NJNotebookIdEntry *entry = [[NJNotebookIdEntry alloc] init];
    entry.noteType = noteType;
    entry.UUID = [notebookUuid copy];
    entry.timeCreated = (lastCreated == nil)?[NSDate date]:lastCreated;
    [_notebook_uuid_table addObject:entry];
    [self saveAllItems];
    [self _printAllItems];
}
- (BOOL)deActivateNotebookUuid:(NSString *)notebookUuid
{
    //if(![self isActiveNotebook:notebookUuid]) return NO;
    BOOL result = NO;
    NSMutableArray *discardedItems = [[NSMutableArray alloc] init];
    for(NJNotebookIdEntry *entry in _notebook_uuid_table) {
        
        if([entry.UUID isEqualToString:notebookUuid]) {
            NJNotebookInfo *notebookInfo = [[NJNotebookInfoStore sharedStore] getNotebookInfo:notebookUuid];
            notebookInfo.archivedDate = [NSDate date];
            [[NJNotebookInfoStore sharedStore] updateNotebookInfo:notebookInfo];
            //[_notebook_uuid_table removeObject:entry];
            [discardedItems addObject:entry];
            result = YES;
            NJNotebookWriterManager *writer = [NJNotebookWriterManager sharedInstance];
            if([writer isActiveNotebook:notebookUuid])
                [writer closeCurrentNotebook];
            break;
        }
    }
    if(!isEmpty(discardedItems))
        [_notebook_uuid_table removeObjectsInArray:discardedItems];
    [self saveAllItems];
    [self _printAllItems];
    
    return result;
}
- (BOOL)isActiveNotebook:(NSString *)notebookUuid
{
    //if([NJNotebookIdStore isDigitalNote:notebookUuid]) return YES;
    if([NJNotebookIdStore isDigitalNote:notebookUuid]) {
        
        NJNotebookInfo *notebookInfo = [[NJNotebookInfoStore sharedStore] getNotebookInfo:notebookUuid];
        if(isEmpty(notebookInfo.archivedDate))
            return YES;
        
    } else {
        
        if(!isEmpty(_notebook_uuid_table)) {
            
            //NSUInteger noteType = [NJNotebookIdStore noteIdFromUuid:notebookUuid];
            for(NJNotebookIdEntry *entry in _notebook_uuid_table) {
                if([entry.UUID isEqualToString:notebookUuid]) return YES;
            }
        }
    }
    
    return NO;
}

- (BOOL)removeNotebook:(NSString *)notebookUuid
{
    NJNotebookIdEntry *removeEntry = nil;
    
    if(!isEmpty(_notebook_uuid_table)) {
        
        //NSUInteger noteType = [NJNotebookIdStore noteIdFromUuid:notebookUuid];
        for(NJNotebookIdEntry *entry in _notebook_uuid_table) {
            if([entry.UUID isEqualToString:notebookUuid]) {
                removeEntry = entry;
                break;
            }
        }
    }
    
    if(removeEntry != nil) {
        [_notebook_uuid_table removeObject:removeEntry];
        [self saveAllItems];
        return YES;
    }
    return NO;
}



+ (BOOL)isSampleNote:(NSString *)notebookUuid
{
    NSUInteger noteType = [NJNotebookIdStore noteIdFromUuid:notebookUuid];
    
    if(noteType == 898 || noteType == 899)
        return YES;
    
    return NO;
}
+ (BOOL)hasFranklinNotebook
{
    NSArray *noteList = [[NJNotebookReaderManager sharedInstance] realNotebookList];
    
    for(NSString *notebookUuid in noteList) {
        
        NSUInteger noteType = [NJNotebookIdStore noteIdFromUuid:notebookUuid];
        if((noteType >= 606 && noteType <= 608) || (noteType >= 621 && noteType <= 624))
            return YES;
    }
    
    return NO;
}
+ (BOOL)isDigitalNote:(NSString *)notebookUuid
{
    NSUInteger noteType = [NJNotebookIdStore noteIdFromUuid:notebookUuid];
    
    if(noteType >= kNOTEBOOK_ID_START_DIGITAL)
        return YES;
    
    return NO;
}
+ (NSUInteger)noteIdFromUuid:(NSString *)uuid
{
    
    NSString *noteUUID = [uuid stringByDeletingPathExtension];
    NSArray *numbers = [noteUUID componentsSeparatedByString:@"_"];
    
    NSInteger noteId = [(NSString *)numbers[0] integerValue];
    
    if(noteId < 0)
        noteId = kNOTEBOOK_ID_START_DIGITAL;
    
    return noteId;
}
+ (NSString *)createUuid
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    [formatter setDateFormat:@"YYYYMMddHHmmss"];
    NSString *uuid_date = [formatter stringFromDate:[NSDate date]];
    
    if(isEmpty(uuid_date) || (uuid_date.length != 14)
       || ([uuid_date rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].location != NSNotFound)
       || ([uuid_date rangeOfCharacterFromSet:[NSCharacterSet symbolCharacterSet]].location != NSNotFound))
        uuid_date = [self _createRandomDigit14];

    NSString *uuid_rnd = [NJNotebookIdStore _createRandom5];
    NSString *uuid = [NSString stringWithFormat:@"%@_%@",uuid_date,uuid_rnd];
    
    return uuid;
}
+ (NSString *)createUuidOfSameType:(NSInteger)noteType
{
    // check if this entry is digital notebook and has -1 as it is
    if(noteType < 0) {
        NSUInteger rnd = (arc4random() % 1000) + 9000;
        noteType = kNOTEBOOK_ID_START_DIGITAL + rnd;
    }
    NSString *newNotebookUuid = [NSString stringWithFormat:@"%05ld_%@",(unsigned long)noteType,[self createUuid]];
    return newNotebookUuid;
}
+ (NSString *)_createRandom5
{
    int count = 0;
    NSMutableString *rndStr = [[NSMutableString alloc] initWithCapacity:5];
    
    BOOL number;
    char gen;
    
    while(count++ < 5) {
        
        number = arc4random() % 2;
        if(number)
            gen = '0' + (arc4random() % 10);
        else
            gen = 'A' + (arc4random() % 24);
        
        [rndStr appendString:[NSString stringWithFormat:@"%c",gen]];
    }
    return rndStr;
}
+ (NSString *)_createRandomDigit14
{
    int count = 0;
    NSMutableString *rndStr = [[NSMutableString alloc] initWithCapacity:14];
    char gen;

    while(count++ < 14) {
        gen = '0' + (arc4random() % 10);
        if(count < 2)
            gen = '9';
        [rndStr appendString:[NSString stringWithFormat:@"%c",gen]];
    }
    return rndStr;
}
@end




NSString * const kNotebookIdEntryNoteType =         @"njnotebookId_note_type";
NSString * const kNotebookIdEntryNoteUUID =         @"njnotebookId_note_uuid";
NSString * const kNotebookIdEntryTimeCreated =      @"njnotebookId_time_created";

@implementation NJNotebookIdEntry

- (id)init
{
    self = [super init];
    if(self) {
        
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if(self) {
        [self setNoteType:[aDecoder decodeIntegerForKey:kNotebookIdEntryNoteType]];
        [self setUUID:[aDecoder decodeObjectForKey:kNotebookIdEntryNoteUUID]];
        [self setTimeCreated:[aDecoder decodeObjectForKey:kNotebookIdEntryTimeCreated]];
    }
    
    return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:_noteType forKey:kNotebookIdEntryNoteType];
    [aCoder encodeObject:_UUID forKey:kNotebookIdEntryNoteUUID];
    [aCoder encodeObject:_timeCreated forKey:kNotebookIdEntryTimeCreated];
}


@end