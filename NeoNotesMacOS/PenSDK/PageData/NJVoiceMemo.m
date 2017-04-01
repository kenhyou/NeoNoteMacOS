//
//  NJVoiceMemo.m
//  NeoJournal
//
//  Created by Heogun You on 16/06/2014.
//  Copyright (c) 2014 Neolab. All rights reserved.
//

#import "NJVoiceMemo.h"

#define FILENAME_BUFFER_LENGTH 60 // prefix 3(VM-) + time 14(13 + -) + note Id 6(5 + -) + uuid 21 (20 + -) + page number 5 + 4(.m4a) + buffer 6
//#define FILENAME_LENGTH 54
@implementation NJVoiceMemo
- (instancetype) init
{
    self = [super init];
    if (self == nil) return nil;
    self.type = MEDIA_VOICE;
    self.fileName = @"";
    self->start_time = 0;
    return self;
}
+ (NJVoiceMemo *) voiceMemoWithFileName:(NSString *)name andTime:(UInt64)time
{
    NJVoiceMemo *vm = [[NJVoiceMemo alloc] init];
    if (vm == nil) return nil;
    
    vm.fileName = name;
    vm->start_time = time;
    return vm;
}
+ (NJVoiceMemo *) voiceMemoFromData:(NSData *)data at:(int *)position
{
    NJVoiceMemo *voice = [[NJVoiceMemo alloc] init];
    if (voice == nil) return nil;
    [voice initFromData:data at:position];
    return voice;
}
- (BOOL) initFromData:(NSData *)data at:(int *)position
{
    char fileName[FILENAME_BUFFER_LENGTH] = {0,};
    char noteUuid[VM_NOTEBOOK_UUID_SIZE] = {0,};
    unsigned char status;
    *position += 1; //skip type
    [self readValueFromData:data to:&start_time at:position length:sizeof(UInt64)];
    [self readValueFromData:data to:fileName at:position length:FILENAME_BUFFER_LENGTH];
    self.fileName = [NSString stringWithCString:fileName encoding:NSASCIIStringEncoding];
    [self readValueFromData:data to:&status at:position length:sizeof(unsigned char)];
    self.status = (NeoVoiceMemoStatus)status;
    [self readValueFromData:data to:&_noteId at:position length:sizeof(UInt32)];
    [self readValueFromData:data to:noteUuid at:position length:VM_NOTEBOOK_UUID_SIZE];
    self.noteUuid = [NSString stringWithCString:noteUuid encoding:NSASCIIStringEncoding];
    [self readValueFromData:data to:&_pageNumber at:position length:sizeof(UInt32)];
    return YES;
}
- (BOOL) writeMediaToData:(NSMutableData *)data
{
    char fileName[FILENAME_BUFFER_LENGTH] = {0,};
    char noteUuid[VM_NOTEBOOK_UUID_SIZE] = {0,};
    unsigned char kind = (unsigned char)MEDIA_VOICE;
    unsigned char status = (unsigned char)self.status;
    UInt64 time_stamp = self->start_time;
    [data appendBytes:&kind length:sizeof(unsigned char)];
    [data appendBytes:&time_stamp length:sizeof(UInt64)];
    const char *name = [self.fileName cStringUsingEncoding:NSASCIIStringEncoding];
    memcpy(fileName, name, strlen(name));
    [data appendBytes:fileName length:FILENAME_BUFFER_LENGTH];
    [data appendBytes:&status length:sizeof(unsigned char)];
    [data appendBytes:&_noteId length:sizeof(UInt32)];
    const char *uuid = [self.noteUuid cStringUsingEncoding:NSASCIIStringEncoding];
    memcpy(noteUuid, uuid, strlen(uuid));
    [data appendBytes:noteUuid length:VM_NOTEBOOK_UUID_SIZE];
    [data appendBytes:&_pageNumber length:sizeof(UInt32)];
    return YES;
}
@end
