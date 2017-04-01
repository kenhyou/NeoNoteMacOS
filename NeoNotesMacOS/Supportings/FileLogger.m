//
//  FileLogger.m
//  NeoNotes
//
//  Copyright (c) 2015년 Neolabconvergence. All rights reserved.
//

#import "FileLogger.h"

@implementation FileLogger

static FileLogger *instance = nil;

+ (FileLogger *)sharedInstance
{
    //static FileLogger *instance = nil;
    @synchronized(self) {
        if(!instance){
            instance = [[FileLogger alloc] init];
        }
    }
    return instance;
}

- (id) init {
    if (self == [super init]) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"NeoNotes.log"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:filePath])
            [fileManager createFileAtPath:filePath
                                 contents:nil
                               attributes:nil];
        logFile = [NSFileHandle fileHandleForWritingAtPath:filePath];
        [logFile seekToEndOfFile];
    }
    
    return self;
}

#define LOG_FILE_SIZE 1*1024*1024
- (void)log:(NSString *)format, ... {
    va_list ap;
    va_start(ap, format);
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"NeoNotes.log"];

    NSError* error;
    NSDictionary *fileDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error: &error];
    NSNumber *size = [fileDictionary objectForKey:NSFileSize];
    
    if ([size integerValue] > LOG_FILE_SIZE) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error;
        BOOL success = [fileManager removeItemAtPath:filePath error:&error];
        if (success) {
            NSLog(@"Log file has been deleted successfully ");
            instance = nil;
        }
        else
        {
            NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
        }
        return;
    }
    NSString *timeStr = [NJUtilities convertDateFromDateOjbect:[NSDate date]];
    NSString *msg = [[NSString alloc] initWithFormat:format arguments:ap];
    NSString *message = [NSString stringWithFormat:@"%@ %@",timeStr, msg];
    NSLog(@"%@",message);
    [logFile writeData:[[message stringByAppendingString:@"\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [logFile synchronizeFile];
    va_end(ap);
}

- (void)dealloc {
    logFile = nil;
}

@end
