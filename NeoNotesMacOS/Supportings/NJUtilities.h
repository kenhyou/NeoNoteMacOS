//
//  MyFunctions.h
//  NeoJournal
//
//  Created by NamSSan on 14/05/2014.
//  Copyright (c) 2014 Neolab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NJUtilities : NSObject

///+ (UIStoryboard *)getStoryBoard;
+ (BOOL)isIOS7;
+ (BOOL)isIOS8;
+ (BOOL)hasMinimumDiskSpace;
+ (CGFloat)freeDiskSpaceInBytes;
+ (NSString *)generatePageStr:(NSArray *)array;
+ (NSDate*)normalizedDateWithDate:(NSDate*)date;

+ (NSDate *)convertDateFromString:(NSString *)strDate;
+ (NSDate *)convertDateFromString2:(NSString *)strDate;
+ (NSString *)convertDateFromDateOjbect:(NSDate *)date;
+ (NSString *)convertDateFromDateOjbectWithShortStyle:(NSDate *)date;
+ (NSInteger)daysBetween:(NSDate *)dt1 and:(NSDate *)dt2;
//+ (NSString *)stringDescForDateDifferenceFrom:(NSDate *)from to:(NSDate *)to forShortStyle:(BOOL)shortStyle;
+ (NSString *)stringDescForDateDifferenceFrom:(NSDate *)from to:(NSDate *)to forShortStyle:(BOOL)shortStyle showTime:(BOOL)showTime;
+ (NSString*)removeEmoji:(NSString *)str;



// Image Related
+ (NSImage*) blur:(NSImage*)theImage withInputRadius:(float)input;
+ (NSImage *)imageWithImage:(NSImage *)image scaledToSize:(CGSize)newSize rounded:(BOOL)round;
+ (NSImage *)imageWithImage:(NSImage *)image scaledToWidth:(CGFloat)newWidth rounded:(BOOL)round;

// create PDF
+ (NSData *)createPDF:(NSString*)filePath notebookId:(NSUInteger)noteId imgArray:(NSArray *)imgArray;
+ (NSData *)createPDFForNotebookUuid:(NSString *)notebookUuid pageArray:(NSArray <NSString *> *)pageArray atFilePath:(NSString *)filePath includingBookCover:(BOOL)includingBookCover;
+ (NSString *)getPDFFilePath:(NSString *)fileName;
+ (void)clearTmpDirectory;
+ (NSString *)generateAttachFileNameForNotebook:(NSString *)notebookUuid andPages:(NSArray *)pages andExt:(NSString *)ext;
+ (NSString *)generateAttachFileNameForImage:(NSString *)notebookUuid andPageNum:(NSString *)pageName andExt:(NSString *)ext;

// color
+ (UInt32)convertUIColorToAlpahRGB:(NSColor *)color;
+ (NSColor *)convertUIColorFromIntColor:(UInt32)intColor;


+ (NSString *) appVersion;
+ (NSString *) versionBuild;

+ (NSString *)loadPasswd;
+ (void)saveIntoKeyChainWithPasswd:(NSString *)passwd;
+ (void)deleteKeyChain;
+ (BOOL) isValidEmail:(NSString *)checkString;

+ (NSString *)svgExportWithStrokes:(NSArray *)strokes AndScale:(CGFloat)scale AndPressure:(BOOL)pressure;
+ (NSString *)inkMLExportWithStrokes:(NSArray *)strokes;

+ (NSString *)detectLanguage:(NSString *)str;

+ (NSString *)stringFromCGRect:(CGRect) rect;
@end
