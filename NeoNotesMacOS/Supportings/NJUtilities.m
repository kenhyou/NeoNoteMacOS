//
//  MyFunctions.m
//  NeoJournal
//
//  Created by NamSSan on 14/05/2014.
//  Copyright (c) 2014 Neolab. All rights reserved.
//

#import "NJUtilities.h"
#import "NJStroke.h"
#import "KeychainItemWrapper.h"
#import "NJNotebookInfo.h"
#import "NJNotebookInfoStore.h"
#import "NJNotebookPaperInfo.h"
#import "NJCoverManager.h"
#import "NPPaperManager.h"
#import <AppKit/AppKit.h>

@implementation NJUtilities

#define kKeyChainKey @"neoNotesPen"

+ (NSStoryboard *)getStoryBoard
{
    
    return [NSStoryboard storyboardWithName:@"Main" bundle:nil];
        
}
+ (BOOL)isIOS7
{
    return NO;
}

+ (BOOL)isIOS8
{
    return NO;
}


+ (CGFloat)freeDiskSpaceInBytes {
    long long freeSpace = [[[[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil] objectForKey:NSFileSystemFreeSize] longLongValue];
    return freeSpace;
}

#define MIN_DISK_ALLOWANCE (500 * 1024 * 1024)
+ (BOOL)hasMinimumDiskSpace
{
    return ([self freeDiskSpaceInBytes] >= MIN_DISK_ALLOWANCE);
}


+ (NSString *)generatePageStr:(NSArray *)array
{
    if(isEmpty(array)) return @"";
    
    int index = 0;
    NSString *formatStr;
    NSMutableString *pageStr = [[NSMutableString alloc] init];
    
    for(NSString *pageName in array) {
        
        if(index++ == 0)
            formatStr = @"%d";
        else
            formatStr = @",%d";
        
        if(index >= 5) {
            formatStr = @"...";
            [pageStr appendString:[NSString stringWithFormat:formatStr,[pageName intValue]]];
            break;
        }
        
        [pageStr appendString:[NSString stringWithFormat:formatStr,[pageName intValue]]];
    }
    
    return pageStr;
}

+ (NSDate*)normalizedDateWithDate:(NSDate*)date
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents* components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate: date];
    
    return [calendar dateFromComponents:components];
}



+ (NSDate *)convertDateFromString:(NSString *)strDate
{
    //Create a formatter
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //Set the format & TimeZone - essential as otherwise the time component wont be used
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //[formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    //Create your NSDate
    NSDate *date = [formatter dateFromString:strDate];
    //NSLog(@"sd %@", date);
    
    return date;
}
+ (NSDate *)convertDateFromString2:(NSString *)strDate
{
    //Create a formatter
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //Set the format & TimeZone - essential as otherwise the time component wont be used
    [formatter setDateFormat:@"yyyy.MM.dd"];
    //[formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    //Create your NSDate
    NSDate *date = [formatter dateFromString:strDate];
    //NSLog(@"sd %@", date);
    
    return date;
}



+ (NSString *)convertDateFromDateOjbect:(NSDate *)date
{
    if(isEmpty(date)) return nil;
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    /*
     [formatter setDateStyle:NSDateFormatterShortStyle];
     [formatter setTimeStyle:NSDateFormatterShortStyle];
     [formatter setDoesRelativeDateFormatting:YES];
     */
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strDate = [formatter stringFromDate:date];
    
    return strDate;
}


+ (NSString *)convertDateFromDateOjbectWithShortStyle:(NSDate *)date
{
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    /*
     [formatter setDateStyle:NSDateFormatterShortStyle];
     [formatter setTimeStyle:NSDateFormatterShortStyle];
     [formatter setDoesRelativeDateFormatting:YES];
     */
    [formatter setDateFormat:@"dd-MMM-YY HH:mm"];
    NSString *strDate = [formatter stringFromDate:date];
    
    return strDate;
}


+ (NSInteger)daysBetween:(NSDate *)dt1 and:(NSDate *)dt2
{
    
    
    NSUInteger unitFlags = NSCalendarUnitDay;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:unitFlags fromDate:dt1 toDate:dt2 options:0];
    NSInteger daysBetween = abs((int)[components day]);
    
    return daysBetween+1;
}


+ (NSString *)stringDescForDateDifferenceFrom:(NSDate *)from to:(NSDate *)to forShortStyle:(BOOL)shortStyle showTime:(BOOL)showTime
{
    
    // set date/time label -- we have now most recently updated page info
    NSUInteger unitFlags =  NSCalendarUnitSecond | NSCalendarUnitMinute | NSCalendarUnitHour| NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comp = [calendar components:unitFlags fromDate:from toDate:to options:0];
    
    NSString *unitStr;
    NSInteger diff = 0;
    
    if(shortStyle) {
      
        NSInteger timeStyle = (showTime)? NSDateFormatterShortStyle : NSDateFormatterNoStyle;
        if(comp.year > 0 || comp.month > 0 || comp.day) {
        
            return [NSDateFormatter localizedStringFromDate:from
                                           dateStyle:NSDateFormatterMediumStyle
                                           timeStyle:timeStyle];
            
        }
    }
    
    if(comp.year > 0) {
        
        diff = comp.year;
        unitStr = @"year";
        
    } else {
        
        
        if(comp.month > 0) {
            
            diff = comp.month;
            unitStr = @"month";
            
        } else {
            
            if(comp.day > 0) {
                
                diff = comp.day;
                unitStr = NSLocalizedString(@"MSC_TIME_FRMT_DAYS", nil);
                
            } else {
                
                if(comp.hour > 0) {
                    
                    diff = comp.hour;
                    //unitStr = @"hour";
                    unitStr = NSLocalizedString(@"MSC_TIME_FRMT_HOURS", nil);
                    
                } else {
                    
                    if(comp.minute > 0) {
                        
                        diff = comp.minute;
                        //unitStr = @"minute";
                        unitStr = NSLocalizedString(@"MSC_TIME_FRMT_MINUTES", nil);
                        
                    } else {
                        diff = comp.second;
                        //unitStr = @"second";
                        unitStr = NSLocalizedString(@"MSC_TIME_FRMT_SECONDS", nil);
                    }
                }
                
            }
        }
    }
    
    
    return NSLocalizedFormatString(unitStr,diff);
    //return [NSString stringWithFormat:@"%ld %@%@ ago",diff,unitStr,(diff > 1)? @"s":@""];
}

+ (NSString*)removeEmoji:(NSString *)oStr {
    
    NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:@"(/?%*:|\"\'<>."];
    NSString *str = [[oStr componentsSeparatedByCharactersInSet:charSet] componentsJoinedByString:@""];
    
    __block NSMutableString* temp = [NSMutableString string];
    
    [str enumerateSubstringsInRange: NSMakeRange(0, [str length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop){
         
         const unichar hs = [substring characterAtIndex: 0];
         
         // surrogate pair
         if (0xd800 <= hs && hs <= 0xdbff) {
             const unichar ls = [substring characterAtIndex: 1];
             const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
             
             [temp appendString: (0x1d000 <= uc && uc <= 0x1f77f)? @"": substring]; // U+1D000-1F77F
             
             // non surrogate
         } else {
             [temp appendString: (0x2100 <= hs && hs <= 0x26ff)? @"": substring]; // U+2100-26FF
         }
     }];
    
    return temp;
}


+ (NSImage*) blur:(NSImage*)theImage withInputRadius:(float)input
{

    return NULL;
}



+ (NSImage *)imageWithImage:(NSImage *)image scaledToSize:(CGSize)newSize rounded:(BOOL)round {
    return NULL;
}


+ (NSImage *)imageWithImage:(NSImage *)image scaledToWidth:(CGFloat)newWidth rounded:(BOOL)round {
    
    CGSize oSize = image.size;
    CGFloat ratio = oSize.width / newWidth;
    CGFloat newHeight = oSize.height / ratio;
    CGSize nSize = {newWidth,newHeight};
    
    return [NJUtilities imageWithImage:image scaledToSize:nSize rounded:round];
}

typedef struct {
    int note_id;
    int width;
    int heght;
} NotebookPDFSizeType;

NotebookPDFSizeType notebookPDFSizeTypeArray[] = {
    {2, 516, 729},
    {551, 595, 842},
    {552, 595, 842},
    {553, 595, 842},
    {554, 595, 842},
    {555, 842, 595},
    {556, 595, 842},
    {557, 595, 842},
    {601, 235, 420}, //pocket note
    {602, 235, 420}, //memo note
    {603, 425, 595}, //spring note
    {604, 499, 709}, //plain note 01
    {605, 420, 595}, //FP_Memopad
    {606, 243, 504}, //franklin planner original CEO
    {608, 306, 487}, //franklin planner casual
    {609, 595, 771}, //idea pad
    {610, 499, 709}, //plain note 02
    {611, 499, 709}, //plain note 03
    {612, 499, 709}, //plain note 04
    {613, 499, 709}, //plain note 05
    {614, 595, 842}, //N A4
    {615, 397, 581}, //Professional note
    {616, 255, 397}, //Professional note mini
    {617, 612, 794}, //college note 01
    {618, 612, 794}, //college note 02
    {619, 612, 794}, //college note 03
    {620, 360, 566}, //idea pad
    {621, 244, 505}, //franklin planner CEO 2016
    {622, 323, 488}, //franklin planner CO 2016
    {623, 306, 488}, //casual planner 32 2016
    {624, 425, 629}, //casual planner 25 2016
    {625, 425, 595}, //casual planner 25 2016
    {114, 420, 595}, //oree note
    {700, 369, 590}, //Moleskine Neobook
    {701, 369, 595}, //Moleskine M1
    {702, 369, 595}, //Moleskine M2
    {800, 369, 595}, //Moleskine M2
};

+ (NSData *)createPDF:(NSString*)filePath notebookId:(NSUInteger)noteId imgArray:(NSArray *)imgArray
{
    
    if(isEmpty(imgArray)) return nil;
    
    CGFloat width=612, height=792; // default size for unknown/unregistered noteTypes
    
    int infoSize = sizeof(notebookPDFSizeTypeArray)/sizeof(NotebookPDFSizeType);
    
    for (int i = 0; i < infoSize; i++) {
        
        NotebookPDFSizeType info = notebookPDFSizeTypeArray[i];
        
        if (info.note_id == (int)noteId) {
            width = info.width;
            height = info.heght;
            break;
        }
        
    }
    NSData *pdfData = [NSData dataWithContentsOfFile:filePath];
    
    return pdfData;
}

+ (NSData *)createPDFForNotebookUuid:(NSString *)notebookUuid pageArray:(NSArray <NSString *> *)pageArray atFilePath:(NSString *)filePath includingBookCover:(BOOL)includingBookCover
{
    NJNotebookReaderManager *reader = [NJNotebookReaderManager sharedInstance];
    NJNotebookPaperInfo *noteInfo = [NJNotebookPaperInfo sharedInstance];
    
    if(isEmpty(pageArray)) return nil;
    if(filePath == nil)
        filePath = [self getPDFFilePath:[NSString stringWithFormat:@"%@_%@_%@.pdf",notebookUuid,[pageArray objectAtIndex:0],[self _createRandom5]]];
    CGContextRef ctx;
    CGPDFDocumentRef PDFDocRef;
    CGRect bounds = CGRectMake(0.0f, 0.0f, 470.0f, 702.f);
    CFDataRef boxData = NULL;
    CFMutableDictionaryRef pageDictionary = NULL;
    ctx = CGPDFContextCreateWithURL((CFURLRef)[NSURL fileURLWithPath:filePath isDirectory:NO], &bounds, NULL);
    
    NSImage *coverImg = nil;
    BOOL callOnce = NO;
    
    for(NSString *pageStr in pageArray) {
        
        NSUInteger pageNum = [pageStr integerValue];
        NJPage *page = [reader getPageData:pageNum notebookUuid:notebookUuid loadStrokes:YES];
        //NJPage *page = [NJNotebookManager getPageForNotebookUuid:notebookUuid pageNum:pageNum loadStrokes:YES];
        //if(isEmpty(page) || isEmpty(page.strokes)) continue;
        if(isEmpty(page)) continue;
        
        //pageNum = page.pdfPageNum;
        CGPDFPageRef PDFPageRef = NULL;
        //NSURL *fileURL =  [[NPPaperManager sharedInstance] getPdfURLForNotebookId:page.notebookId section:page.section owner:page.owner];
        
        int noteId = page.notebookId;
        //int pageNum = page.pageNumber;
        
        NSString *pdfFileName = [noteInfo backgroundFileNameForSection:0 owner:0 note:noteId pageNumber:(int)pageNum];
        NSURL *fileURL =  [[NSBundle mainBundle] URLForResource:pdfFileName withExtension:nil];
        //jr
        if (isEmpty(fileURL)) {
            NSUInteger section, owner;
            [NPPaperManager section:&section owner:&owner fromNotebookId:noteId];
            fileURL =  [[NPPaperManager sharedInstance] getPdfURLForNotebookId:noteId section:section owner:owner];
        }
        
        if(includingBookCover)
            coverImg = [NJCoverManager getCoverResourceImage:(NSUInteger)noteId];
            //coverImg = [[NJNotebookInfoStore sharedStore] getNotebookInfo:notebookUuid].coverImage;
            //coverImg = [NJNotebookManager getNotebookInfoForUuid:notebookUuid].coverImage;
        if (fileURL != nil)
        {
            PDFDocRef = CGPDFDocumentCreateWithURL((CFURLRef)fileURL);
            if (PDFDocRef != NULL)
            {
                if (pageNum < 1) pageNum = 1;
                NSInteger pages = CGPDFDocumentGetNumberOfPages(PDFDocRef);
                if (pageNum > pages) pageNum = pages;
                
                PDFPageRef = CGPDFDocumentGetPage(PDFDocRef, pageNum);
                if (PDFPageRef == NULL)
                    CGPDFDocumentRelease(PDFDocRef), PDFDocRef = NULL;
            }
        }
        
        CGPDFPageRetain(PDFPageRef);
        CGRect cropBoxRect = CGPDFPageGetBoxRect(PDFPageRef, kCGPDFCropBox);
        CGRect mediaBoxRect = CGPDFPageGetBoxRect(PDFPageRef, kCGPDFMediaBox);
        CGRect effectiveRect = CGRectIntersection(cropBoxRect, mediaBoxRect);
        pageDictionary = CFDictionaryCreateMutable(NULL, FALSE,
                                                   &kCFTypeDictionaryKeyCallBacks,
                                                   &kCFTypeDictionaryValueCallBacks); // 6
        
        
        if(includingBookCover && coverImg && !callOnce) {
            callOnce = YES;
            boxData = CFDataCreate(NULL,(const UInt8 *)&bounds, sizeof (CGRect));
            CFDictionarySetValue(pageDictionary, kCGPDFContextMediaBox, boxData);
            CGPDFContextBeginPage (ctx, pageDictionary); // 7
            CGContextSaveGState(ctx);
            CGContextRestoreGState(ctx);
            CGPDFContextEndPage (ctx);
            CFRelease(boxData);
        }
        
        bounds = CGRectMake(0.0f, 0.0f, effectiveRect.size.width, effectiveRect.size.height);
        boxData = CFDataCreate(NULL,(const UInt8 *)&bounds, sizeof (CGRect));
        CFDictionarySetValue(pageDictionary, kCGPDFContextMediaBox, boxData);
        CGPDFContextBeginPage (ctx, pageDictionary); // 7
        CGContextSaveGState(ctx);
        CGContextConcatCTM(ctx, CGPDFPageGetDrawingTransform(PDFPageRef, kCGPDFCropBox, bounds, 0, true));
        CGContextDrawPDFPage(ctx, PDFPageRef); // Render the PDF page into the context
        CGContextRestoreGState(ctx);
        
        CGContextSaveGState(ctx);
        CGContextTranslateCTM(ctx, 0.0, bounds.size.height);
        CGContextScaleCTM(ctx, 1.0, -1.0);
        
        CGFloat normalizerScale = MAX(bounds.size.width,bounds.size.height);
        
        for (NJStroke *stroke in page.strokes) {
            if (stroke.type != MEDIA_STROKE) continue;
            @autoreleasepool {
                [stroke renderWithScale:normalizerScale];
                [stroke drawStrokeInContext:ctx];
            }
        }
        CGPDFPageRelease(PDFPageRef), PDFPageRef = NULL;
        CGContextRestoreGState(ctx);
        CGPDFContextEndPage (ctx);// 9
    }
    
    CGContextRelease (ctx);// 10
    if (pageDictionary != nil) {
        CFRelease(pageDictionary); // 11
    }
    
    if (boxData != nil) {
        CFRelease(boxData);
    }
    
    NSData *pdfData = [NSData dataWithContentsOfFile:filePath];
    return pdfData;
}

+ (NSString *)getPDFFilePath:(NSString *)fileName
{
    
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *pdfFileDirectory = [documentDirectory stringByAppendingPathComponent:@"NoteNotesTMP"];
    NSFileManager *fm = [NSFileManager defaultManager];
    __block NSError *error = nil;
    [fm createDirectoryAtURL:[NSURL fileURLWithPath:pdfFileDirectory] withIntermediateDirectories:YES attributes:nil error:&error];
    
    
    NSString* pdfFileName = [pdfFileDirectory stringByAppendingPathComponent:fileName];
    return pdfFileName;
}

+ (NSString *)generateAttachFileNameForNotebook:(NSString *)notebookUuid andPages:(NSArray *)pages andExt:(NSString *)ext
{
    
    NJNotebookInfo *notebookInfo = [[NJNotebookInfoStore sharedStore] getNotebookInfo:notebookUuid];
    
    NSString *notebookTitle = @"";
    // 1. generate notebook title str
    if(!isEmpty(notebookInfo) && !isEmpty(notebookInfo.notebookTitle))
        notebookTitle = notebookInfo.notebookTitle;

    // 2. generate page str
    NSString *pageStr = @"";
    if(!isEmpty(pages)) {
        
        NSInteger tmpNum = 0;
        id page = [pages objectAtIndex:0];
        if([page isKindOfClass:[NSString class]] || [page isKindOfClass:[NSNumber class]])
            tmpNum = [page integerValue];
        
        if(pages.count <= 1) {
            pageStr = [NSString stringWithFormat:@"_p%tu",tmpNum];
            
        } else {
            NSInteger smallestPageNum = INT_MAX;
            NSInteger largestPageNum = -1;
            NSInteger tmpNum = 0;
            for(id page in pages) {
                
                if([page isKindOfClass:[NSString class]] || [page isKindOfClass:[NSNumber class]])
                    tmpNum = [page integerValue];
                
                if(tmpNum < smallestPageNum)
                    smallestPageNum = tmpNum;
                
                if(tmpNum > largestPageNum)
                    largestPageNum = tmpNum;
                    
            }
            
            pageStr = [NSString stringWithFormat:@"_p%tu-%tu",smallestPageNum,largestPageNum];
        }
    }
    
    // 3. generate date str
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    [formatter setDateFormat:@"YYYYMMdd"];
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    
    
    NSString *fileName = nil;
    fileName = [NSString stringWithFormat:@"%@%@_%@.%@",notebookTitle,pageStr,dateStr,ext];
    fileName = [fileName stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    
    return fileName;
    
}

+ (NSString *)generateAttachFileNameForImage:(NSString *)notebookUuid andPageNum:(NSString *)pageName andExt:(NSString *)ext
{
    
    NJNotebookInfo *notebookInfo = [[NJNotebookInfoStore sharedStore] getNotebookInfo:notebookUuid];
    
    NSString *notebookTitle = @"";
    // 1. generate notebook title str
    if(!isEmpty(notebookInfo) && !isEmpty(notebookInfo.notebookTitle))
        notebookTitle = notebookInfo.notebookTitle;
    
    // 2. generate page str
    NSString *pageStr = @"";
    NSInteger tmpNum = 0;
    tmpNum = [pageName integerValue];
    pageStr = [NSString stringWithFormat:@"_p%tu",tmpNum];
        
    // 3. generate date str
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    [formatter setDateFormat:@"YYYYMMdd"];
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    
    
    NSString *fileName = nil;
    fileName = [NSString stringWithFormat:@"%@%@_%@.%@",notebookTitle,pageStr,dateStr,ext];
    fileName = [fileName stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    
    return fileName;
    
}

+ (void)clearTmpDirectory
{
    NSArray* tmpDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:NSTemporaryDirectory() error:NULL];
    for (NSString *file in tmpDirectory) {
        [[NSFileManager defaultManager] removeItemAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:file] error:NULL];
    }
    
    
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    //NSString *pdfFileDirectory = [documentDirectory stringByAppendingPathComponent:@"NoteNotesTMP"];
    
    NSArray *mainDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentDirectory error:NULL];
    for(NSString *file in mainDirectory ) {
        
        NSString *extension = [file pathExtension];
        if([extension isEqualToString:@"pdf"] || [extension isEqualToString:@"PDF"])
            [[NSFileManager defaultManager] removeItemAtPath:[documentDirectory stringByAppendingPathComponent:file] error:NULL];
    }
    
    [[NSFileManager defaultManager] removeItemAtPath:[documentDirectory stringByAppendingPathComponent:@"NoteNotesTMP"] error:NULL];
    [[NSFileManager defaultManager] removeItemAtPath:[documentDirectory stringByAppendingPathComponent:@"NoteNotesTMP2"] error:NULL];
}




+ (NSColor *)convertUIColorFromIntColor:(UInt32)intColor
{
    float colorA = (intColor>>24)/255.0f;
    float colorR = ((intColor>>16)&0x000000FF)/255.0f;
    float colorG = ((intColor>>8)&0x000000FF)/255.0f;
    float colorB = (intColor&0x000000FF)/255.0f;
    
    return [NSColor colorWithRed:colorR green:colorG blue:colorB alpha:colorA];
}


+ (UInt32)convertUIColorToAlpahRGB:(NSColor *)color
{

    return 0;
}

+ (NSString *) appVersion
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
}


+ (NSString *) build
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
}



+ (NSString *) versionBuild
{
    NSString * version = [self appVersion];
    NSString * build = [self build];
    
    NSString * versionBuild = [NSString stringWithFormat: @"v%@", version];
#ifdef DEBUG
    versionBuild = [NSString stringWithFormat: @"v%@ (%@)", version, build];
#endif
    
    /*
     if (![version isEqualToString: build]) {
     //versionBuild = [NSString stringWithFormat: @"%@(%@)", versionBuild, build];
     versionBuild = [NSString stringWithFormat:@"%@.%@",version,build];
     }
     */
    
    
    return versionBuild;
}

+ (KeychainItemWrapper *)getKeyChainItemWrapper
{    
   
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"Pen_Password" accessGroup:nil];
    
    return keychain;
}
+ (NSString *)loadPasswd
{
    //NSString *passwd = [JNKeychain loadValueForKey:kKeyChainKey];
    NSString *passwd = [[NSUserDefaults standardUserDefaults] objectForKey:kKeyChainKey];
    
    if(passwd == nil || isEmpty(passwd))
        passwd = @"0000";
    
    return passwd;
}
+ (NSString *)_loadPasswd2
{
    KeychainItemWrapper *keychain = [self getKeyChainItemWrapper];
    
    NSString *passwd = [keychain objectForKey:(__bridge id)(kSecValueData)];
    
    return passwd;
}

+ (void)saveIntoKeyChainWithPasswd:(NSString *)passwd
{
    if(isEmpty(passwd))
        passwd = @"0000";
 
    [[NSUserDefaults standardUserDefaults] setObject:passwd forKey:kKeyChainKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    /*
    if ([JNKeychain saveValue:passwd forKey:kKeyChainKey]) {
        NSLog(@"[KeyChain]  Correctly saved !");
    } else {
        NSLog(@"[KeyChain] Failed to save!");
    }
    KeychainItemWrapper *keychain = [self getKeyChainItemWrapper];
    
    // store user email & password for next automatic login
    [keychain setObject:@"neo lab convergence" forKey:(__bridge id)kSecAttrService];
    [keychain setObject:@"neo note pen" forKey:(__bridge id)kSecAttrAccount];
    [keychain setObject:passwd forKey:(__bridge id)kSecValueData];
    
    NSLog(@"Key chain Saved");
    */
}

+ (void)deleteKeyChain
{
    // remove keychainItem to prevent automatic logain from next time
    
    /*
    KeychainItemWrapper *keychain = [self getKeyChainItemWrapper];
    [keychain resetKeychainItem];
     */
}

+ (BOOL) isValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"^[_A-Za-z0-9-+]+(\\.[_A-Za-z0-9-+]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9-]+)*(\\.[A-Za-z‌​]{2,4})$";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}


+ (NSString *)detectLanguage:(NSString *)str {
    
    if (isEmpty(str))
        return nil;
    
    NSString *string = nil;
    
    // You can set a larger detect number here
    if (str.length > 30) {
        string = str;
    } else {
        NSMutableString *tempString = [NSMutableString stringWithString:str];
        
        while (tempString.length < 30) {
            [tempString appendFormat:@" %@",str];
        }
        
        string = tempString;
    }
    
    NSArray *tagschemes = [NSArray arrayWithObjects:NSLinguisticTagSchemeLanguage, nil];
    NSLinguisticTagger *tagger = [[NSLinguisticTagger alloc] initWithTagSchemes:tagschemes options:0];
    [tagger setString:string];
    NSString *language = [tagger tagAtIndex:0 scheme:NSLinguisticTagSchemeLanguage tokenRange:NULL sentenceRange:NULL];
    
    if (![language isEqualToString:@"und"]) {
        return language;
    }
    
    return (__bridge NSString *)CFStringTokenizerCopyBestStringLanguage((CFStringRef)string, CFRangeMake(0, MIN(string.length,400)));
}


+ (NSString *)svgExportWithStrokes:(NSArray *)strokes AndScale:(CGFloat)scale AndPressure:(BOOL)pressure
{
    /// 필압 적용 방법
    /// 각각의 포인트에 대한 좌우 폭(펜 압력)의 좌표를 구한다.
    /// 구하는 방법
    /// 첫번쨰 점 P1(x1, y1)과 두번쨰 점 P2(x2, y2) 가 있다고 하고, P1을 지나면서 직선 P와 직교하는 점 pL(xL, yL), pR(xR, yR)이 있다 하자
    /// 두 점을 지나는 직선 P = P1 + ( P2 - P2) * t 로 표현 이때, t는 0부터 1 사이의 값
    /// 이 직선 P의 기울기가 = (y2 - y1) / (x2 - x1) 즉, dy/dx 이고, 이 직선과 직교하는 직선의 기울기는 -(x2-x1)/(y2-y1) 즉, -dx/dy이다.
    ///  여기 까지 적용 하면,
    /// 두점 사이의 간격이 멀어지면, 펜 압력 즉 직교하는 점의 거리가 멀어진다. 의미인 즉, 우리 펜으로 아주 빨리 그리면, 두껍게 표현 된다는 이야기
    /// 이것의 문제는 너무 빨리 그렸을 경우에 터무니 없이 두꺼워 질 수 있음.
    ///
    /// 해서, 일정한 간격을 유지 할 수 있도록 Norm을 계산하여 나누어 준다.
    /// 필압에 가속도 까지 같이 더 할 경우의 방정식
    /// xR = x1 + f/2 * dy (직교하니깐. dy를 쓴다)
    /// yR = y1 - f/2 * dx (직교하니깐, dx를 쓴다)
    /// xL = x1 - f/2 * dy
    /// yL = y1 + f/2 * dx
    /// 순수 필압 만으로 계산 할 때의 방정식
    /// xR = x1 + f/(2* |norm|) * dy (직교하니깐. dy를 쓴다)
    /// yR = y1 - f/(2* |norm|) * dx (직교하니깐, dx를 쓴다)
    /// xL = x1 - f/(2* |norm|) * dy
    /// yL = y1 + f/(2* |norm|) * dx
    /// 이 점을 모두 연결하여 폐곡선을 만들어서 그 안을 채우면 필압이 먹은 Stoke가 완성 됨.
    /// 필압은 8bit ADC이므로, 0 255사이의 값으로 normalize해서 사용하였음.
    
    //float scale = 1000;//*= _targetScale;
    //float offset_x = 0, offset_y = 0;
    float lineThicknessScale = (float)1/960.0f;  //1/4000.f
    float scaled_pen_thickness = scale * lineThicknessScale; //490 * lineThicknessScale;//
    float x0, x1, y0, y1;
    float xDistance, yDistance;
    
    float norm;
    
    
    float dx, dy;
    float xL, yL, xR, yR;
    float k, n;
    
    float p;
    float orig_xL, orig_yL;
    
    
    
    k=1.3;
    
    
    NSString *svg = @"<svg xmlns=\"http://www.w3.org/2000/svg\" version=\"1.1\"> ";
    
    NSMutableArray *sA = [NSMutableArray array];
    
    NSString *svg_end = @"</svg>";
    
    if (pressure) {
    //pen pressure applied
        for(int i=0; i < strokes.count; i++)
        {
            @autoreleasepool {
                NJStroke *aStroke = (NJStroke *)[strokes objectAtIndex:i];
                if (aStroke.type != MEDIA_STROKE) {
                    sA[i] = @"";
                    
                    continue;
                }
                
                int size = aStroke.dataCount;
                
                float *point_x = (float *)malloc(sizeof(float) * size);
                float *point_y = (float *)malloc(sizeof(float) * size);
                float *point_p = (float *)malloc(sizeof(float) * size);
                
                memcpy(point_x, aStroke->point_x, sizeof(float) * size);
                memcpy(point_y, aStroke->point_y, sizeof(float) * size);
                memcpy(point_p, aStroke->point_p, sizeof(float) * size);
                
                //x0 = point_x[ 0 ] * scale + offset_x + 0.1f;
                //y0 = point_y[ 0 ] * scale + offset_y;
                
                //x1 = point_x[ 1 ] * scale + offset_x + 0.1f;
                //y1 = point_y[ 1 ] * scale + offset_y;
                
                x0 = point_x[ 0 ] * scale + 0.1f;
                y0 = point_y[ 0 ] * scale;
                
                x1 = point_x[ 1 ] * scale + 0.1f;
                y1 = point_y[ 1 ] * scale;
                
                dx = x1 - x0;
                dy = y1 - y0;
                
                norm = (float)sqrtf(dx*dx + dy*dy+0.0001f);
                n = 2.0 * norm;
                
                //p = point_p[0]*k;
                p = point_p[0]*scaled_pen_thickness;
                
                xDistance = p/n * dy;
                yDistance = p/n * dx;
                
                
                xR = x0 + xDistance;
                yR = y0 - yDistance;
                
                xL = x0 - xDistance;
                yL = y0 + yDistance;
                
                orig_xL = xL;
                orig_yL = yL;
                
                sA[i] = @"<path ";
                
                
                sA[i] =  [NSString stringWithFormat:@"%@ d=\"M %f %f \n", sA[i], xL, yL];
                
                
                sA[i] =  [NSString stringWithFormat:@"%@ L %f %f \n", sA[i], xR, yR];
                
                
                for(int j = 1 ; j < (size - 2) ; j++ )
                {
                    
                    // calculate from left to right
                    
                    
                    x0 = point_x[j] * scale + 0.1f;
                    y0 = point_y[j] * scale;
                    
                    x1 = point_x[j+1] * scale + 0.1f;
                    y1 = point_y[j+1] * scale;
                    
                    dx = x1 - x0;
                    dy = y1 - y0;
                    
                    norm = (float)sqrtf(dx*dx + dy*dy+0.0001f);
                    n = 2.0f * norm;
                    
                    p = point_p[j]*scaled_pen_thickness;
                    
                    xDistance = p/n * dy;
                    yDistance = p/n * dx;
                    
                    xR = x0 + xDistance;
                    yR = y0 - yDistance;
                    
                    
                    sA[i] =  [NSString stringWithFormat:@"%@ L %f %f \n", sA[i], xR, yR];
                    
                    
                }
                
                x0 = point_x[ size - 1 ] * scale + 0.1f;
                y0 = point_y[ size - 1 ] * scale ;
                x1 = point_x[ size - 2 ] * scale + 0.1f;
                y1 = point_y[ size - 2 ] * scale ;
                
                dx = x1 - x0;
                dy = y1 - y0;
                
                
                norm = (float)sqrtf(dx*dx + dy*dy+0.0001f);
                n = 2.0f *norm;
                
                p = point_p[size - 1]*scaled_pen_thickness;
                
                xDistance = p/n * dy;
                yDistance = p/n * dx;
                
                
                xR = x0 + xDistance;
                yR = y0 - yDistance;
                
                xL = x0 - xDistance;
                yL = y0 + yDistance;
                
                sA[i] =  [NSString stringWithFormat:@"%@ L %f %f \n", sA[i], xL, yL];
                
                sA[i] = [NSString stringWithFormat:@"%@ L %f %f \n", sA[i], xR, yR];
                
                
                
                for(int j = size -2; j > 0; j--)
                {
                    
                    x0 = point_x[ j ] * scale + 0.1f;
                    y0 = point_y[ j ] * scale;
                    x1 = point_x[j-1] * scale + 0.1f;
                    y1 = point_y[j-1] * scale;
                    
                    
                    dx = x1 - x0;
                    dy = y1 - y0;
                    
                    norm = (float)sqrtf(dx*dx + dy*dy+0.0001f);
                    n = 2.0f *norm;
                    
                    p = point_p[j]*scaled_pen_thickness;
                    
                    xDistance = p/n * dy;
                    yDistance = p/n * dx;
                    
                    // Right Left is flipped!!!!!!!!!!!! because the vector we are looking at is all the way around!!!!
                    xR = x0 + xDistance;
                    yR = y0 - yDistance;
                    
                    sA[i] = [NSString stringWithFormat:@"%@ L %f %f \n", sA[i], xR, yR];
                    
                }
                /*
                 x0 = point_x[0] * scale + offset_x + 0.1f;
                 y0 = point_y[0] * scale + offset_y;
                 x1 = point_x[1] * scale + offset_x + 0.1f;
                 y1 = point_y[1] * scale + offset_y;
                 
                 dx = x1 - x0;
                 dy = y1 - y0;
                 
                 norm = (float)sqrtf(dx*dx + dy*dy+0.0001f);
                 n = 2.0f *norm;
                 
                 p = point_p[0]*scaled_pen_thickness;
                 
                 xL = x0 - p/n * dy;
                 yL = y0 + p/n * dx;
                 */
                sA[i] = [NSString stringWithFormat:@"%@ L %f %f \n", sA[i], orig_xL, orig_yL];
                
                
                
                
                
                sA[i] = [NSString stringWithFormat:@"%@\" ", sA[i]];
                NSString *strokeColorWidth = @"stroke=\"black\" stroke-width=\"1\" fill=\"black\" stroke-linejoin=\"round\" /> ";
                
                sA[i] = [NSString stringWithFormat:@"%@ %@", sA[i], strokeColorWidth];
                
            }
        }
        
        for(int i = 0 ; i  < strokes.count ; i++)
        {
            @autoreleasepool {
                svg = [NSString stringWithFormat:@"%@ %@", svg, sA[i]];
            }
        }
        
        
        //NSLog(@"svg_string :%@ %@", svg, svg_end);
        svg = [NSString stringWithFormat:@"%@ %@", svg, svg_end];

    } else {
    //no pen pressure applied
        for(int i=0; i < strokes.count; i++) {
            @autoreleasepool {
                NJStroke *aStroke = (NJStroke *)[strokes objectAtIndex:i];
                if (aStroke.type != MEDIA_STROKE) {
                    sA[i] = @"";
                    continue;
                }
                
                int size = aStroke.dataCount;
                
                float *point_x = (float *)malloc(sizeof(float) * size);
                float *point_y = (float *)malloc(sizeof(float) * size);
                float *point_p = (float *)malloc(sizeof(float) * size);
                
                memcpy(point_x, aStroke->point_x, sizeof(float) * size);
                memcpy(point_y, aStroke->point_y, sizeof(float) * size);
                memcpy(point_p, aStroke->point_p, sizeof(float) * size);
                
                for(int j=0; j < aStroke.dataCount; j++) {
                    
                    float valX = point_x[j];
                    float valY = point_y[j];
                    
                    point_x[j] = (valX * scale);
                    point_y[j] = (valY * scale);
                }
                sA[i] = @"<path ";
                
                sA[i] = [NSString stringWithFormat:@"%@ d=\"M %f %f ", sA[i], point_x[0], point_y[0]];
                
                for(int j = 1 ; j < aStroke.dataCount ; j++ ){
                    sA[i] = [NSString stringWithFormat:@"%@ L %f %f ", sA[i], point_x[j], point_y[j]];
                }
                
                sA[i] = [NSString stringWithFormat:@"%@\" ", sA[i]];
                
                NSString *strokeColorWidth = @"stroke=\"black\" stroke-width=\"1\" fill=\"none\" /> ";
                sA[i] = [NSString stringWithFormat:@"%@ %@", sA[i], strokeColorWidth];
            }
        }
        
        for(int i = 0 ; i  < strokes.count ; i++){
            @autoreleasepool {
                svg = [NSString stringWithFormat:@"%@ %@", svg, sA[i]];
            }
        }
        //NSLog(@"svg_string :%@ %@", svg, svg_end);
        svg = [NSString stringWithFormat:@"%@ %@", svg, svg_end];

    }
    
    return svg;
    
}

+ (NSString *)inkMLExportWithStrokes:(NSArray *)strokes
{
    NSString *ink = @"<ink xmlns=\"http://www.w3.org/2003/InkML\"> ";
    NSString *ink2 = @"<inkSource xml:id = \"neo note\"> ";
    NSString *ink3 = @"<activeArea width=\"1.0\" height=\"1.0\" /> ";
    NSString *ink4 = @"</inkSource> ";
    
    ink = [NSString stringWithFormat:@"%@ %@ %@ %@", ink, ink2, ink3, ink4];
    NSMutableArray *iA = [NSMutableArray array];
    NSString *ink_end = @"</ink>";
    
    @autoreleasepool {
    for(int i=0; i < strokes.count; i++) {
        
        NJStroke *aStroke = (NJStroke *)[strokes objectAtIndex:i];
        if (aStroke.type != MEDIA_STROKE) {
            iA[i] = @"";
            continue;
        }
        
        int size = aStroke.dataCount;
        
        float *x0 = (float *)malloc(sizeof(float) * size);
        float *y0 = (float *)malloc(sizeof(float) * size);
        
        memcpy(x0, aStroke->point_x, sizeof(float) * size);
        memcpy(y0, aStroke->point_y, sizeof(float) * size);
        
        iA[i] = @"<trace> ";
        
        for(int j = 0 ; j < (aStroke.dataCount - 1) ; j++ ){
            
            iA[i] = [NSString stringWithFormat:@"%@ %f %f, ", iA[i], x0[j], y0[j]];
        }
        
        iA[i] = [NSString stringWithFormat:@"%@ %f %f ", iA[i], x0[aStroke.dataCount - 1], y0[aStroke.dataCount - 1] ];
        
        NSString *trace_end = @"</trace> ";
        iA[i] = [NSString stringWithFormat:@"%@ %@", iA[i], trace_end];
        
    }
    }
    @autoreleasepool {
    for(int i = 0 ; i  < strokes.count ; i++){
        
        ink = [NSString stringWithFormat:@"%@ %@", ink, iA[i]];
    }
    }
    //NSLog(@"svg_string :%@ %@", ink, ink_end);
    ink = [NSString stringWithFormat:@"%@ %@", ink, ink_end];
    return ink;
    
}



+ (CGVector)createUnitVectorFrom:(CGPoint)origin to:(CGPoint)dest
{
    CGFloat length = sqrtf(((origin.x - dest.x)*(origin.x - dest.x)) + ((origin.y - dest.y)*(origin.y - dest.y)));
    CGFloat dx = (origin.x - dest.x) / length;
    CGFloat dy = (origin.y - dest.y) / length;
    
    return CGVectorMake(dx, dy);
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

+ (NSString *)stringFromCGRect:(CGRect) rect
{
    return [NSString stringWithFormat:@"{{%f, %f}, {%f, %f}}", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height];
}
@end
