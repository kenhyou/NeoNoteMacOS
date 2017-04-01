//
//  NJVoiceManager.m
//  NeoJournal
//
//  Created by Heogun You on 15/06/2014.
//  Copyright (c) 2014 Neolab. All rights reserved.
//

#import "NJVoiceManager.h"
#import "NJNotebookWriterManager.h"
#import "NJVoiceMemo.h"
#import "NJAppDelegate.h"

typedef enum {
    NONE_MODE,
    RECORD_MODE,
    PLAY_MODE
} AUDIO_MODE;

extern NSString * NJPageChangedNotification;
//extern NSString * AEAudioControllerSessionInterruptionEndedNotification;

@interface NJVoiceManager () {
    //AVAudioRecorder *recorder;
    //AVAudioPlayer *player;
    NSString *_startNotbookUuid;
    NSInteger _startPageNum;
}
@property (strong, nonatomic) NSString *fileName;
@property (strong, nonatomic) NJVoiceMemo *voiceMemoStater;
@property (strong, nonatomic) NSMutableData *vmRecoderMetaData;
@property (strong, nonatomic) NSMutableArray *vmPlayerMetaList;
@property (nonatomic) AUDIO_MODE audioMode;

- (NSString *)newVoiceFileName;
+ (NSString *)voiceMemoDirectory;
- (NSURL *) newVoiceFileUrl;
@end

@implementation NJVoiceManager
@synthesize recorder,player;
- (instancetype)init
{
    self = [super init];
    if (self == nil) return nil;
    
    player = nil;
    recorder = nil;
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    _audioMode = NONE_MODE;
    return self;
}

+ (NJVoiceManager *) sharedInstance
{
    static NJVoiceManager *shared = nil;
    
    @synchronized(self) {
        if(!shared){
            shared = [[NJVoiceManager alloc] init];
        }
    }
    return shared;
}


+ (BOOL) isVoiceMemoFileExistForNoteId:(NSString *)noteUuid andPageNum:(NSUInteger)pageNum
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *list = [fm contentsOfDirectoryAtPath:[NJVoiceManager voiceMemoDirectory] error:nil];
    //NSMutableArray *mList = [NSMutableArray arrayWithArray:list];
    
    for(NSString *fileName in list) {
        if([[fileName pathExtension] compare:@"m4a" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            NSString * tNoteUuid = [NJVoiceManager getUuidFromFileName:fileName];
            UInt64 tPageNum = [NJVoiceManager getNumberFor:VM_NUMBER_PAGE_ID from:fileName];
            
            if([tNoteUuid isEqualToString:noteUuid] && pageNum == tPageNum)
                return YES;
        }
    }
    return NO;
}
+ (NSUInteger) getNumberOfVoiceMemoForNoteId:(NSString *)noteUuid
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *list = [fm contentsOfDirectoryAtPath:[NJVoiceManager voiceMemoDirectory] error:nil];
    //NSMutableArray *mList = [NSMutableArray arrayWithArray:list];
    NSUInteger count = 0;
    for(NSString *fileName in list) {
        if([[fileName pathExtension] compare:@"m4a" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            NSString * tNoteUuid = [NJVoiceManager getUuidFromFileName:fileName];
            if([tNoteUuid isEqualToString:noteUuid]) count++;
        }
    }
    return count;
}
+ (NSUInteger) getNumberOfVoiceMemoForAllNotebook
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *list = [fm contentsOfDirectoryAtPath:[NJVoiceManager voiceMemoDirectory] error:nil];
    //NSMutableArray *mList = [NSMutableArray arrayWithArray:list];
    NSUInteger count = [list count];

    return count;
}
+ (NSArray *) getVoiceMemosForNotebookUuid:(NSString *)notebookUuid
{
    NSMutableArray *vms = [NSMutableArray array];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *list = [fm contentsOfDirectoryAtPath:[NJVoiceManager voiceMemoDirectory] error:nil];
    //NSMutableArray *mList = [NSMutableArray arrayWithArray:list];
    
    for(NSString *fileName in list) {
        if([[fileName pathExtension] compare:@"m4a" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            NSString * tNoteUuid = [NJVoiceManager getUuidFromFileName:fileName];
            if([tNoteUuid isEqualToString:notebookUuid]) [vms addObject:fileName];
        }
    }
    return vms;
}
/* Delete voice memo and meta files based on noteuuid and pagenumber.
 * If pageNum is -1, remove all files matching noteuuid.
 */
+ (BOOL) deleteAllVoiceMemoForNoteUUid:(NSString *)noteUuid andPageNum:(NSInteger)pageNum
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *list = [fm contentsOfDirectoryAtPath:[NJVoiceManager voiceMemoDirectory] error:nil];
    
    for(NSString *fileName in list) {
        NSString* tNoteUuid = [NJVoiceManager getUuidFromFileName:fileName];
        UInt64 tPageNum = [NJVoiceManager getNumberFor:VM_NUMBER_PAGE_ID from:fileName];
        
        if([tNoteUuid isEqualToString:noteUuid] && (pageNum == -1  || pageNum == tPageNum)) {
            NSString *filePath = [[NJVoiceManager voiceMemoDirectory] stringByAppendingPathComponent:fileName];
            [fm removeItemAtPath:filePath error:NULL];
        }
    }
    return YES;
}



- (void)AEAudioControllerSessionInterruptionEnded:(NSNotification *)notification
{
//    NJAppDelegate *delegate = (NJAppDelegate *)[[UIApplication sharedApplication] delegate];
//    [delegate.audioController stop];
}
- (void) vmMetaDataListInit
{
    _vmRecoderMetaData = [[NSMutableData alloc] init];
}
- (NSTimeInterval) playerCurrentTime
{
    return player.currentTime;
}
- (void) setPlayerCurrentTime:(NSTimeInterval)newTime
{
    [player setCurrentTime:newTime];
}
- (NSTimeInterval) playerDuration
{
    
    return player.duration;
}
- (NSTimeInterval) playerTimeLeft
{
    return (player.duration - player.currentTime);
}
- (NSTimeInterval) recoderCurrentTime
{
    return recorder.currentTime;
}

- (BOOL) isRecording
{
    if (recorder != nil && recorder.recording) {
        return YES;
    }
    return NO;
}

- (BOOL) isPlaying
{
    if (player != nil && player.playing) {
        return YES;
    }
    return NO;
}
- (void) saveVmRecoderMeta
{
    NSString *metaFileName = [self.fileName stringByDeletingPathExtension];
    metaFileName = [NSString stringWithFormat:@"%@.meta", metaFileName];
    NSString *path = [[NJVoiceManager voiceMemoDirectory] stringByAppendingPathComponent:metaFileName];
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm createFileAtPath:path contents:_vmRecoderMetaData attributes:nil];
    _vmRecoderMetaData = nil;
}
- (void) startRecording
{
    // Set the audio file
    NSString *voiceFileName = [self newVoiceFileName];
    self.fileName = voiceFileName;
    NSString *path = [[NJVoiceManager voiceMemoDirectory] stringByAppendingPathComponent:voiceFileName];
    NSURL *outputFileURL = [NSURL URLWithString:path];
    
    // Setup audio session
    [self setAudioSessionMode:RECORD_MODE];
    
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    if (recorder!=nil) {
        [recorder stop];
    }
    // Initiate and prepare the recorder
    recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:NULL];
    recorder.delegate = self;
    recorder.meteringEnabled = YES;
    [recorder prepareToRecord];
    if (!recorder.recording) {
        // Start recording
        [recorder record];
        NSLog(@"Recording Started");
        [self addVoiceMemoStartWithFileName:voiceFileName];
        
        NJNotebookWriterManager *writer = [NJNotebookWriterManager sharedInstance];
        if(!isEmpty(writer) && !isEmpty(writer.activeNotebookUuid)) {
            _startNotbookUuid = writer.activeNotebookUuid;
            _startPageNum = writer.activePageNumber;
        }
        
    }
}
- (void)stopRecording
{
    
    NSLog(@"Recording Stopped : %f seconds", recorder.currentTime);
    [recorder stop];
    
    player = nil;
    recorder = nil;
    _startNotbookUuid = nil;
    _startPageNum = -1;
}
- (void) startPlayFileName:(NSString *)fileName
{
//    [self setAudioRouting];
    if (!recorder.recording){
        [self setAudioSessionMode:PLAY_MODE];
        [self setPlayFileName:fileName];
        [player setDelegate:self];
        player.volume = 0;
        //[player play];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(100 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
            player.volume = 1;
        });
    }
}
- (void) setPlayFileName:(NSString *)fileName
{
    NSString *path = [[NJVoiceManager voiceMemoDirectory] stringByAppendingPathComponent:fileName];
    NSURL *inputFileURL = [NSURL URLWithString:path];
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:inputFileURL error:nil];
    NSString *metaFileName = [fileName stringByDeletingPathExtension];
    metaFileName = [NSString stringWithFormat:@"%@.meta", metaFileName ];
    
    _vmPlayerMetaList = [NSMutableArray arrayWithArray:[NJVoiceManager vmMetaDataFromMetaFileAtPath:metaFileName]];
}
+ (NSArray *)vmMetaDataFromMetaFileAtPath:(NSString*)metaFileName
{
    NSString *path = [[NJVoiceManager voiceMemoDirectory] stringByAppendingPathComponent:metaFileName];
    NSData *metaData = [NSData dataWithContentsOfFile:path];
    unsigned int dataLength = (unsigned int)[metaData length];
    UInt64 timestamp;
    UInt32 noteId, pageNumber;
    NSRange range;
    unsigned int offset = 0;
    NSMutableArray * vmMetaList = [[NSMutableArray alloc] init];
    char uuidString[VM_NOTEBOOK_UUID_SIZE] = {0,};
    unsigned int dataSize = sizeof(UInt64) + sizeof(UInt32) *2 + VM_NOTEBOOK_UUID_SIZE;
    while (dataLength >= dataSize) {
        NJVoiceMemo *memo = [[NJVoiceMemo alloc] init];
        range.length = sizeof(UInt64);
        range.location = offset;
        [metaData getBytes:&timestamp range:range];
        offset += sizeof(UInt64);
        range.length = sizeof(UInt32);
        range.location = offset;
        [metaData getBytes:&noteId range:range];
        offset += sizeof(UInt32);
        range.location = offset;
        range.length = VM_NOTEBOOK_UUID_SIZE;
        [metaData getBytes:uuidString range:range];
        offset += VM_NOTEBOOK_UUID_SIZE;
        range.location = offset;
        range.length = sizeof(UInt32);
        [metaData getBytes:&pageNumber range:range];
        offset += sizeof(UInt32);
        dataLength -= dataSize;
        memo->start_time = timestamp;
        memo.noteId = noteId;
        memo.noteUuid = [NSString stringWithCString:uuidString encoding:NSASCIIStringEncoding];
        memo.pageNumber = pageNumber;
        [vmMetaList addObject:memo];
    }
    return vmMetaList;
}
- (NJVoiceMemo *)playerMetaFromTimestamp:(UInt64)timestamp
{
    if(_vmPlayerMetaList == nil) return nil;
    for (int i = (int)[_vmPlayerMetaList count]-1; i >= 0; i--) {
        NJVoiceMemo *vm = _vmPlayerMetaList[i];
        if (vm->start_time <= timestamp) {
            return vm;
        }
    }
    return nil;
}
-(void) setAudioSessionMode:(AUDIO_MODE)mode
{
    NSError *setCategoryErr = nil;
    NSError *activationErr  = nil;
    NSLog(@"setAudioSessionMode : %@", (mode == RECORD_MODE) ? @"RECORD_MODE" : @"PLAY_MODE");
    if (mode == _audioMode) {
        return;
    }
}
+ (BOOL) isVoiceMemoFileExist:(NSString *)fileName
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *filePath = [[NJVoiceManager voiceMemoDirectory] stringByAppendingPathComponent:fileName];
    return [fm fileExistsAtPath:filePath];
}
+ (void) deleteVoiceMemoFile:(NSString *)fileName
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *filePath = [[NJVoiceManager voiceMemoDirectory] stringByAppendingPathComponent:fileName];
    [fm removeItemAtPath:filePath error:NULL];
    NJNotebookReaderManager *reader = [NJNotebookReaderManager sharedInstance];
    NJPage *page;
    if (reader.activePageDocument!=nil && reader.activePageDocument.page!= nil ){
        page = reader.activePageDocument.page;
        if ([page.voiceMemo count] > 0) {
            for (int i=0; i < [page.voiceMemo count];i++) {
                NSString *voicefile = [[page.voiceMemo objectAtIndex:i] objectForKey:@"fileName"];
                if ([fileName isEqualToString:voicefile]) {
                    [page.voiceMemo removeObjectAtIndex:i];
                    break;
                }
            }
        }
    }
}

+ (NSString *) getUuidFromFileName:(NSString*)fileName
{
    //[NSString stringWithFormat:@"VM-%013llu-%@-%06d.m4a", timeInMiliseconds, notebookUuid, (unsigned int)pageNumber];
    // kind : VM_NUMBER_TIME, VM_NUMBER_NOTE_ID, VM_NUMBER_PAGE_ID
    NSString *name = [fileName stringByDeletingPathExtension];
    NSArray *nameComponents = [name componentsSeparatedByString:@"-"];
    if ([nameComponents count] != 4) {
        return nil;
    }
    NSString *uuid = (NSString *)[nameComponents objectAtIndex:2];
    return uuid;
}
+ (UInt64) getNumberFor:(VM_NUMBER_TYPE)kind from:(NSString*)fileName
{
    //[NSString stringWithFormat:@"VM-%013llu-%@-%06d.m4a", timeInMiliseconds, notebookUuid, (unsigned int)pageNumber];
    // kind : VM_NUMBER_TIME, VM_NUMBER_NOTE_ID, VM_NUMBER_PAGE_ID
    NSString *name = [fileName stringByDeletingPathExtension];
    NSArray *nameComponents = [name componentsSeparatedByString:@"-"];
    UInt64 value = 0;
    if ([nameComponents count] != 4) {
        return value;
    }
    switch (kind) {
        case VM_NUMBER_NOTE_ID:
        {
            // uuid format : 00001_20141005030630_CEE11
            NSString *uuid = (NSString *)[nameComponents objectAtIndex:2];
            NSArray *uuidComponents = [uuid componentsSeparatedByString:@"_"];
            if ([uuidComponents count] != 3) {
                value = 0;
            }
            else {
                value = (UInt64)[((NSString *)uuidComponents[0]) longLongValue];
            }
        }
            break;
        case VM_NUMBER_PAGE_ID:
        {
            NSString* pageNumber = (NSString *)[nameComponents objectAtIndex:3];
            value = (UInt64)[(NSString *)pageNumber longLongValue];
        }
            break;
        case VM_NUMBER_TIME:
        {
            NSString* startTime = (NSString *)[nameComponents objectAtIndex:1];
            value = (UInt64)[(NSString *)startTime longLongValue];
        }
            break;
        default:
            break;
        
    }
    return value;
}
- (void) resumePlay
{
    [player play];
}
- (void) pausePlay
{
    [player pause];
}
- (void) stopPlay
{
    [player stop];
}
- (void) addVoiceMemoStartWithFileName:(NSString *)fileName
{
    UInt64 timeInMiliseconds = [NJVoiceManager getNumberFor:VM_NUMBER_TIME from:fileName];
    NJNotebookWriterManager *writeManager = [NJNotebookWriterManager sharedInstance];
    UInt32 noteId = (UInt32)writeManager.activeNoteBookId;
    UInt32 pageNumber = (UInt32)writeManager.activePageNumber;
    NJVoiceMemo *voiceMemo = [NJVoiceMemo voiceMemoWithFileName:fileName andTime:timeInMiliseconds];
    voiceMemo.status = VOICEMEMO_START;
    voiceMemo.noteId = noteId;
    voiceMemo.pageNumber = pageNumber;
    NSString *uuid = writeManager.activeNotebookUuid;
    voiceMemo.noteUuid = uuid;
    [self vmMetaDataListInit];
    dispatch_async(dispatch_get_main_queue(), ^{
        char uuidString[VM_NOTEBOOK_UUID_SIZE] = {0,};
        const char *name = [uuid cStringUsingEncoding:NSASCIIStringEncoding];
        memcpy(uuidString, name, strlen(name));
        [_vmRecoderMetaData appendBytes:&timeInMiliseconds length:sizeof(UInt64)];
        [_vmRecoderMetaData appendBytes:&noteId length:sizeof(UInt32)];
        [_vmRecoderMetaData appendBytes:uuidString length:VM_NOTEBOOK_UUID_SIZE];
        [_vmRecoderMetaData appendBytes:&pageNumber length:sizeof(UInt32)];
        [writeManager.activePageDocument.page addMedia:voiceMemo];
        [[NSNotificationCenter defaultCenter]postNotificationName:NJPageChangedNotification
                                                           object:writeManager.activePageDocument.page userInfo:nil];
    });
}
- (void) addVoiceMemoPageChangingTo:(UInt32)noteId pageNumber:(UInt32)pageNumber
{
    UInt64 timeInMiliseconds = (UInt64)([[NSDate date] timeIntervalSince1970]*1000);
    NJNotebookWriterManager *writeManager = [NJNotebookWriterManager sharedInstance];
    NJVoiceMemo *voiceMemo = [NJVoiceMemo voiceMemoWithFileName:self.fileName andTime:timeInMiliseconds];
    voiceMemo.status = VOICEMEMO_PAGE_CHANGING;
    voiceMemo.noteId = noteId;
    voiceMemo.pageNumber = pageNumber;
    NSString *uuid = writeManager.activeNotebookUuid;
    voiceMemo.noteUuid = uuid;
    char uuidString[VM_NOTEBOOK_UUID_SIZE] = {0,};
    const char *name = [uuid cStringUsingEncoding:NSASCIIStringEncoding];
    memcpy(uuidString, name, strlen(name));
    [_vmRecoderMetaData appendBytes:&timeInMiliseconds length:sizeof(UInt64)];
    [_vmRecoderMetaData appendBytes:&noteId length:sizeof(UInt32)];
    [_vmRecoderMetaData appendBytes:uuidString length:VM_NOTEBOOK_UUID_SIZE];
    [_vmRecoderMetaData appendBytes:&pageNumber length:sizeof(UInt32)];
    // Do not use "dispatch_async" addVoiceMemoPageChangingTo is called in main queue by parser.
//    dispatch_async(dispatch_get_main_queue(), ^{
    [writeManager.activePageDocument.page addMedia:voiceMemo];
    [[NSNotificationCenter defaultCenter]postNotificationName:NJPageChangedNotification
                                                       object:writeManager.activePageDocument.page userInfo:nil];
//    });
}
- (void) addVoiceMemoPageChanged:(UInt64)startTime
{
    //UInt64 timeInMiliseconds = (UInt64)([[NSDate date] timeIntervalSince1970]*1000);
    NJNotebookWriterManager *writeManager = [NJNotebookWriterManager sharedInstance];
    UInt32 noteId = (UInt32)writeManager.activeNoteBookId;
    UInt32 pageNumber = (UInt32)writeManager.activePageNumber;
    NJVoiceMemo *voiceMemo = [NJVoiceMemo voiceMemoWithFileName:self.fileName andTime:startTime];
    voiceMemo.status = VOICEMEMO_PAGE_CHANGED;
    voiceMemo.noteId = noteId;
    voiceMemo.pageNumber = pageNumber;
    NSString *uuid = writeManager.activeNotebookUuid;
    voiceMemo.noteUuid = uuid;
    char uuidString[VM_NOTEBOOK_UUID_SIZE] = {0,};
    const char *name = [uuid cStringUsingEncoding:NSASCIIStringEncoding];
    memcpy(uuidString, name, strlen(name));
    [_vmRecoderMetaData appendBytes:&startTime length:sizeof(UInt64)];
    [_vmRecoderMetaData appendBytes:&noteId length:sizeof(UInt32)];
    [_vmRecoderMetaData appendBytes:uuidString length:VM_NOTEBOOK_UUID_SIZE];
    [_vmRecoderMetaData appendBytes:&pageNumber length:sizeof(UInt32)];
    // Do not use "dispatch_async" addVoiceMemoPageChangingTo is called in main queue by parser.
//    dispatch_async(dispatch_get_main_queue(), ^{
    [writeManager.activePageDocument.page addMedia:voiceMemo];
    [[NSNotificationCenter defaultCenter]postNotificationName:NJPageChangedNotification
                                                       object:writeManager.activePageDocument.page userInfo:nil];
//    });
}

- (void) addVoiceMemoEnd
{
    UInt64 timeInMiliseconds = (UInt64)([[NSDate date] timeIntervalSince1970]*1000);
    NJNotebookWriterManager *writeManager = [NJNotebookWriterManager sharedInstance];
    NJVoiceMemo *voiceMemo = [NJVoiceMemo voiceMemoWithFileName:self.fileName andTime:timeInMiliseconds];
    voiceMemo.status = VOICEMEMO_END;
    voiceMemo.noteId = (UInt32)writeManager.activeNoteBookId;
    voiceMemo.pageNumber = (UInt32)writeManager.activePageNumber;
    NSString *uuid = writeManager.activeNotebookUuid;
    voiceMemo.noteUuid = uuid;
    NSLog(@"addVoiceMemoEnd at %llu", voiceMemo->start_time);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self saveVmRecoderMeta];
        [writeManager.activePageDocument.page addMedia:voiceMemo];
        [[NSNotificationCenter defaultCenter]postNotificationName:NJPageChangedNotification
                                                           object:writeManager.activePageDocument.page userInfo:nil];
    });
}
#pragma mark - Private Methods
// Voice recording has some latency before actually start recording....
#define VOICE_RECORD_LATENCY 200   //ms
/* Voicememo filename has special role.
 * 1. Used for get start time. 
      : + (UInt64) getNumberFor:(VM_NUMBER_TYPE)kind from:(NSString*)fileName
 * 2. notebook UUID
 * 3. note id, page number  
      : + (UInt64) getNumberFor:(VM_NUMBER_TYPE)kind from:(NSString*)fileName
*/
- (NSString *) newVoiceFileName
{
    UInt64 timeInMiliseconds = (UInt64)([[NSDate date] timeIntervalSince1970]*1000) + VOICE_RECORD_LATENCY; // 13 digits
    NJNotebookWriterManager *writeManager = [NJNotebookWriterManager sharedInstance];
//    UInt32 noteId = (UInt32)writeManager.activeNoteBookId;
    UInt32 pageNumber = (UInt32)writeManager.activePageNumber;
    NSString *notebookUuid = writeManager.activeNotebookUuid;
    NSString *fileName = [NSString stringWithFormat:@"VM-%013llu-%@-%06d.m4a", timeInMiliseconds, notebookUuid, (unsigned int)pageNumber];
    NSLog(@"Voice Memo Name : %@", fileName);
    return fileName;
}

+ (NSString *) voiceMemoDirectory
{
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *memoDirectory = [documentDirectory stringByAppendingPathComponent:@"NJVoiceMemo"];
    NSFileManager *fm = [NSFileManager defaultManager];
    __block NSError *error = nil;
    [fm createDirectoryAtURL:[NSURL fileURLWithPath:memoDirectory] withIntermediateDirectories:YES attributes:nil error:&error];

    return memoDirectory;
}

- (NSURL *) newVoiceFileUrl
{
    NSString *path = [[NJVoiceManager voiceMemoDirectory] stringByAppendingPathComponent:[self newVoiceFileName]];
    return [NSURL URLWithString:path];
}
#pragma mark - AVAudioRecorderDelegate
/* audioRecorderDidFinishRecording:successfully: is called when a recording has been finished or stopped. 
 This method is NOT called if the recorder is stopped due to an interruption. */
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    NSLog(@"audioRecorderDidFinishRecording");
    [self addVoiceMemoEnd];
}
/* if an error occurs while encoding it will be reported to the delegate. */
- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    NSLog(@"audioRecorderEncodeErrorDidOccur");
}
/* audioRecorderBeginInterruption: is called when the audio session has been interrupted while the recorder was recording. 
 The recorded file will be closed. */
- (void)audioRecorderBeginInterruption:(AVAudioRecorder *)a_recorder
{
    NSLog(@"audioRecorderBeginInterruption");
    [self addVoiceMemoEnd];
    if (self.delegate != nil) {
        [self.delegate voiceRecorderStopped];
    }
}
/* audioRecorderEndInterruption:withOptions: is called when the audio session interruption has ended and this recorder had been interrupted while recording. */
/* Currently the only flag is AVAudioSessionInterruptionFlags_ShouldResume. */
- (void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder withOptions:(NSUInteger)flags
{
    NSLog(@"audioRecorderEndInterruption");
}
#pragma mark - AVAudioPlayerDelegate
/* audioPlayerDidFinishPlaying:successfully: is called when a sound has finished playing. 
 This method is NOT called if the player is stopped due to an interruption. */
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"audioPlayerDidFinishPlaying");
    if (self.delegate != nil) {
        [self.delegate voicePlayerDidFinishPlaying];
    }
        
}

/* if an error occurs while decoding it will be reported to the delegate. */
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    NSLog(@"audioPlayerDecodeErrorDidOccur");
}

/* audioPlayerBeginInterruption: is called when the audio session has been interrupted while the player was playing. The player will have been paused. */
- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    
}

/* audioPlayerEndInterruption:withOptions: is called when the audio session interruption has ended and this player had been interrupted while playing. */
/* Currently the only flag is AVAudioSessionInterruptionFlags_ShouldResume. */
- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags
{
    
}
@end
