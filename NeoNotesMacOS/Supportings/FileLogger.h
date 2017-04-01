//
//  FileLogger.h
//  NeoNotes
//
//  Copyright (c) 2015년 Neolabconvergence. All rights reserved.
//

@interface FileLogger : NSObject {
    NSFileHandle *logFile;
}
+ (FileLogger *)sharedInstance;
- (void)log:(NSString *)format, ...;
@end

#define FLog(fmt, ...) [[FileLogger sharedInstance] log:fmt, ##__VA_ARGS__]
