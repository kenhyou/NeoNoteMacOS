//
//  NJPage.m
//  NeoJournal
//
//  Copyright (c) 2014 Neolab. All rights reserved.
//

#import "NJPage.h"
#import "NJNode.h"
#import "NJStroke.h"
#import "NJVoiceMemo.h"
#import "NJVoiceManager.h"
#import "NJTransformation.h"
#import "NJNotebookPaperInfo.h"
#import "PDFPageConverter.h"
#import "NPPaperManager.h"
#import "NSImage+saveAsJpegWithName.h"

#define FILE_VERSION_1 1
#define FILE_VERSION_2 2
#define FILE_VERSION_3 3
#define FILE_VERSION_4 4
#define USE_FILE_VERSION_4


NSString * NJPageImageUpdateNotification = @"NJPageImageUpdateNotification";

@interface NJPage() {
    float _startOffsetX, _startOffsetY;
    CGFloat _normalizer;
    NSImage *_backgroundImg;
}
// Digital notes may need to know original noteId and page number.
@property (strong, nonatomic) NJTransformation* transformation;
@property (strong, nonatomic) NJNotebookPaperInfo *paperInfo;
//@property (nonatomic) float page_x;
//@property (nonatomic) float page_y;
@property (nonatomic) int contentReadPosition;
@property (strong, nonatomic) NSData *contentData;
@end

@implementation NJPage
@synthesize mTime = _mTime;
@synthesize dirtyBit = _dirtyBit;
@synthesize pageGuid = _pageGuid;

- (void)dealloc
{
    _strokes = nil;
    _voiceMemo = nil;
    _contentData = nil;
    _transformation = nil;
    _paperInfo = nil;
}

- (id) initWitPage:(NJPage *)page
{
    self = [super init];
    if(!self) return nil;
    
    self.notebookId = page.notebookId;
    self.pageNumber = page.pageNumber;
    self.strokes = [[NSMutableArray alloc] init];
    self.transformation = [[NJTransformation alloc] init];
    self.paperSize = page.paperSize;
    float startX, startY, inputScale;
    if([self.paperInfo getPaperDotcodeStartForNotebook:(int)self.notebookId PageNumber:self.pageNumber startX:&startX startY:&startY])
    {
        //inputScale = MAX(self.paperSize.width, self.paperSize.height);
        //_startOffsetX = startX / inputScale;
        //_startOffsetY = startY / inputScale;
        _startOffsetX = startX;
        _startOffsetY = startY;
        
    }
    else {
        _startOffsetX = 0; _startOffsetY = 0;
    }
    
    self.dirtyBit = page.dirtyBit;
    _fileVersion = FILE_VERSION_4;
    _pageHasChanged = page.pageHasChanged;
    
    for(NJStroke *stroke in page.strokes) {
        if(stroke.type == MEDIA_STROKE) {
            NJStroke *copyStroke = [[NJStroke alloc] initWithStroke:stroke];
            [self.strokes addObject:copyStroke];
        }
    }

    return self;
}

- (id) initWithNotebookId:(int)notebookId andPageNumber:(int)pageNumber
{
    self = [super init];
    if(!self) {
        return nil;
    }
    self.notebookId = notebookId;
    self.pageNumber = pageNumber;
    self.strokes = [[NSMutableArray alloc] init];
    self.transformation = [[NJTransformation alloc] init];
    self.paperInfo = [NJNotebookPaperInfo sharedInstance];
    /* Get Paper size */
    [self.paperInfo getPaperDotcodeRangeForNotebook:(int)notebookId PageNumber:pageNumber Xmax:&_page_x Ymax:&_page_y];
    CGSize paperSize;
    paperSize.width = _page_x;
    paperSize.height = _page_y;
    /* set paper size and input scale. Input scale is used to nomalize stroke data */
    self.paperSize = paperSize;
    float startX, startY, inputScale;
    if([self.paperInfo getPaperDotcodeStartForNotebook:notebookId PageNumber:pageNumber startX:&startX startY:&startY])
    {
        //inputScale = MAX(paperSize.width, paperSize.height);
        //_startOffsetX = startX / inputScale;
        //_startOffsetY = startY / inputScale;
        _startOffsetX = startX;
        _startOffsetY = startY;
    }
    else {
        _startOffsetX = 0; _startOffsetY = 0;
    }
    
    self.dirtyBit = NO;
    _fileVersion = FILE_VERSION_4;
    _pageHasChanged = NO;

    return self;
}
- (void) setPaperSize:(CGSize)paperSize
{
    _paperSize = paperSize;
    //_inputScale = MAX(paperSize.width, paperSize.height);
    _normalizer = MAX(_paperSize.width, _paperSize.height);
    _paperOffset = CGPointMake(_startOffsetX, _startOffsetY);
    //_inputScale = paperSize.height;
}
- (CGFloat)normalizer
{
    return _normalizer;
}
- (NSDate *)cTime
{
    if(_cTime == nil) return [NSDate date];
    return _cTime;
}
- (NSDate *)mTime
{
    if(_mTime == nil) return [NSDate date];
    return _mTime;
}
- (void)setMTime:(NSDate *)mTime
{
    if(_mTime == nil) {
        _mTime = mTime;
        return;
    }
    
    if([_mTime compare:mTime] == NSOrderedAscending)
        _mTime = mTime;
}
- (BOOL) dirtyBit
{
    return _dirtyBit;
}
- (void) setDirtyBit:(BOOL)dirtyBit
{
    if (_dirtyBit == dirtyBit) {
        return;
    }
    _dirtyBit = dirtyBit;
    if (_dirtyBit == NO) {
        //Will be saved automatically if dirty is YES.
        _pageHasChanged = YES;
        [self saveToURL:self.fileUrl imageSaving:NO];
    }
}

- (void) setPageGuid:(NSString *)pageGuid
{
    if (_pageGuid == pageGuid) {
        return;
    }
    _pageGuid = pageGuid;

    if ([_pageGuid isEqualToString:@""]) {
        NSLog(@"_pageGuid: @""");
    }
    _pageHasChanged = YES;
    [self saveToURL:self.fileUrl];

}
- (NSMutableArray *)voiceMemo
{
    if (_voiceMemo == nil) {
        _voiceMemo = [[NSMutableArray alloc] init];
    }
    return _voiceMemo;
}
- (void)setTransformationWithOffsetX:(float)x offset_y:(float)y scale:(float)scale
{
    self.transformation.offset_x = x;
    self.transformation.offset_y = y;
    self.transformation.scale = scale;
    for (NJStroke *stroke in self.strokes) {
        [stroke setTransformation:self.transformation];
    }
}
- (void) removeVoiceMemoFile:(NSString *)fileName
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *filePath = [[NJVoiceManager voiceMemoDirectory] stringByAppendingPathComponent:fileName];
    [fm removeItemAtPath:filePath error:NULL];
    if ([self.voiceMemo count] > 0) {
        for (int i=0; i < [self.voiceMemo count];i++) {
            NSString *voicefile = [[self.voiceMemo objectAtIndex:i] objectForKey:@"fileName"];
            if ([fileName isEqualToString:voicefile]) {
                [self.voiceMemo removeObjectAtIndex:i];
                break;
            }
        }
    }
}
- (void) removeStroke:(NJStroke *)stroke
{
    [self.strokes removeObject:stroke];
    //NSLog(@"Stroke count : %lu", (unsigned long)[self.strokes count]);
    _pageHasChanged = YES;
    self.dirtyBit = YES;
}
- (void) addMedia:(NJMedia *)media
{
    if (media.type == MEDIA_STROKE) {
        NJStroke *stroke = (NJStroke *)media;
        //[stroke setTransformation:self.transformation];
        [self addStroke:stroke];
    }
    else if(media.type == MEDIA_VOICE) {
        NJVoiceMemo *vm = (NJVoiceMemo *)media;
        if (vm.status == VOICEMEMO_START || vm.status == VOICEMEMO_PAGE_CHANGED) {
            BOOL addVM = YES;
            for (NSDictionary *memo in _voiceMemo) {
                if ([vm.fileName isEqualToString:(NSString *)[memo objectForKey:@"fileName"]]) {
                    addVM = NO;
                    break;
                }
            }
            if (addVM) {
                UInt64 timestamp = [NJVoiceManager getNumberFor:VM_NUMBER_TIME from:vm.fileName];
                UInt32 noteId = (UInt32)[NJVoiceManager getNumberFor:VM_NUMBER_NOTE_ID from:vm.fileName];
                UInt32 pageId = (UInt32)[NJVoiceManager getNumberFor:VM_NUMBER_PAGE_ID from:vm.fileName];
                NSDictionary *vmData = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        [NSNumber numberWithUnsignedInteger:noteId], @"noteId",
                                        [NSNumber numberWithUnsignedInteger:pageId], @"pageNumber",
                                        [NSNumber numberWithLongLong:timestamp], @"timestamp",
                                        vm.fileName, @"fileName", nil];
                [self.voiceMemo addObject:vmData];
            }
        }
	[self.strokes addObject:media];	
    }
    //[self.strokes addObject:media];
    _pageHasChanged = YES;
}
- (void) addStroke:(NJStroke *)stroke
{
    //[stroke setTransformation:self.transformation];
    _paperOffset = CGPointMake(_startOffsetX, _startOffsetY);
    [stroke normalize:_normalizer offset:_paperOffset];
    [self.strokes addObject:stroke];
    //NSLog(@"Stroke count : %lu", (unsigned long)[self.strokes count]);
    _pageHasChanged = YES;
    self.dirtyBit = YES;
}
- (void) insertStrokeByTimestamp:(NJStroke *)stroke
{
    //[stroke setTransformation:self.transformation];
    _paperOffset = CGPointMake(_startOffsetX, _startOffsetY);
    [stroke normalize:_normalizer offset:_paperOffset];
    NSUInteger count = [self.strokes count];
    NSUInteger index;
    for (index = 0; index < count; index++) {
        NJStroke *aStroke = self.strokes[index];
        if (stroke->start_time == aStroke->start_time) {
            return;
        }
        if (stroke->start_time < aStroke->start_time) {
            break;
        }
    }
    [self.strokes insertObject:stroke atIndex:index];
    _pageHasChanged = YES;
    self.dirtyBit = YES;
}
- (void) readContentOfURL:(NSURL *)fileUrl
{
    self.contentData = [NSData dataWithContentsOfURL:fileUrl];
    self.contentReadPosition = 0;
}
- (BOOL) readDataTo:(void *)buffer length:(int)length
{
    if (self.contentData.length < self.contentReadPosition + length) {
        return NO;
    }
    NSRange range = {self.contentReadPosition, length};
    [self.contentData getBytes:buffer range:range];
    self.contentReadPosition += length;
    return YES;
}
- (void) finishReadContent
{
    self.contentData = nil;
}
- (NeoMediaType) readTypeFromData:(NSData*)data at:(int)position
{
    unsigned char type;
    NSRange range = {position, sizeof(unsigned char)};
    [data getBytes:&type range:range];
    return (NeoMediaType)type;
}

- (BOOL) readFromURL:(NSURL *)url readMetaFile:(BOOL)readMeta metaOnly:(BOOL)metaOnly
{
    int strokeCount;
    if(url)
        self.fileUrl = url;
    NSString *path = [[self.fileUrl path] stringByAppendingPathComponent:@"page.data"];
    [self readContentOfURL:[NSURL fileURLWithPath:path]];
    CGSize paperSize;
    paperSize.width = self.page_x;
    paperSize.height = self.page_y;
    float startX = 0;
    float startY = 0;
    self.paperSize = paperSize;
    char neo;
    // Start read file content
    if(![self readDataTo:&neo length:sizeof(char)]) return NO;
    if (neo != 'n') return NO;
    if(![self readDataTo:&neo length:sizeof(char)]) return NO;
    if (neo != 'e') return NO;
    if(![self readDataTo:&neo length:sizeof(char)]) return NO;
    if (neo != 'o') return NO;
    UInt32 version;
    if(![self readDataTo:&version length:sizeof(UInt32)]) return NO;

    UInt32 noteId =0, pageNumber =0;
    if (version >= FILE_VERSION_2) {
        if(![self readDataTo:&noteId length:sizeof(UInt32)]) return NO;
        if(![self readDataTo:&pageNumber length:sizeof(UInt32)]) return NO;
    }
    Float32 sizeData;
    if(![self readDataTo:&sizeData length:sizeof(Float32)]) return NO;
    if (sizeData != 0) {
        paperSize.width = sizeData;
        if(![self readDataTo:&sizeData length:sizeof(Float32)]) return NO;
        if (sizeData != 0) {
            paperSize.height = sizeData;
//            if(self.isTemporal && version < FILE_VERSION_4) {
//                // from version #4, we store raw pen data (no offset & normalized data due to note server issue)
//                // in order to revert old version file to original pen data  we need to know correct paper size.
//                // however if the page is temporal (so sdk does not have paper info yet) we use info from file instead.
//                // unfortunately, we might loose offset info for file version #1
//                self.paperSpace = CGRectMake(0.0f,0.0f,paperSize.width,paperSize.height);
//            }
        }

            //jr
            //self.paperSize = paperSize;
        
    }
    if (version >= FILE_VERSION_2)
    {
        // Try again so that we can possiblely get proper offset values.
        if (_startOffsetX == 0 && _startOffsetY == 0) {
            //float inputScale = MAX(paperSize.width, paperSize.height);
            [self.paperInfo getPaperDotcodeStartForNotebook:(int)_notebookId PageNumber:_pageNumber startX:&startX startY:&startY];
            //_startOffsetX = startX / inputScale;
            //_startOffsetY = startY / inputScale;
            _startOffsetX = startX;
            _startOffsetY = startY;
        }
        startX = _startOffsetX;
        startY = _startOffsetY;
    }

    UInt64 ctimeInterval;
    if(![self readDataTo:&ctimeInterval length:sizeof(UInt64)]) return NO;
    UInt64 mtimeInterval;
    if(![self readDataTo:&mtimeInterval length:sizeof(UInt64)]) return NO;
    unsigned char dirtyBit = 0;
    if(![self readDataTo:&dirtyBit length:sizeof(unsigned char)]) return NO;
    if (dirtyBit == 0) {
        _dirtyBit = NO;
    }
    else {
        _dirtyBit = YES;
    }

    if(readMeta) {
        _fileVersion = version;
        if (version >= FILE_VERSION_2) {
            self.notebookId = noteId;
            self.pageNumber = pageNumber;
        }
        //        self.paperSize = paperSize;
        self.cTime = [self convertIntervalToNSDate:ctimeInterval];
        self.mTime = [self convertIntervalToNSDate:mtimeInterval];
        
    }
    
    if(metaOnly) {
        [self finishReadContent];
        return YES;
    }
    
    [self readDataTo:&strokeCount length:sizeof(UInt32)];
    int position;
    NeoMediaType type;
    NJStroke *media;
    for (int count = 0; count < strokeCount;count++ ) {
        position = self.contentReadPosition;
        type = [self readTypeFromData:self.contentData at:position];
        if (type == MEDIA_STROKE) {
            media = [NJStroke strokeFromData:self.contentData at:&position version:version paperSize:self.paperSize];
            if(isEmpty(media)) continue;
            self.contentReadPosition = position;
            
            if(version == FILE_VERSION_1) { // was save -offset & /normalize
                
                for (int j=0; j < media.dataCount; j++) {
                    media->point_x[j] *= _normalizer;
                    media->point_y[j] *= _normalizer;
                    //media->point_x[j] += _paperOffset.x;
                    //media->point_y[j] += _paperOffset.y;
                    media->point_x[j] += _paperOffset.x;
                    media->point_y[j] += _paperOffset.y;
                }
            } else if(version == FILE_VERSION_2 || version == FILE_VERSION_3) {
                
                for (int j=0; j < media.dataCount; j++) {
                    float x = media->point_x[j] * _normalizer;
                    float y = media->point_y[j] * _normalizer;
                    media->point_x[j] = x;
                    media->point_y[j] = y;
                }
            }
            
            [self addMedia:media];
        }
        else if (type == MEDIA_VOICE) {
            NJVoiceMemo *vm = [NJVoiceMemo voiceMemoFromData:self.contentData at:&position];
            self.contentReadPosition = position;
            if (vm == nil) break;
            // Check if the vm file still exists or not
            if ([NJVoiceManager isVoiceMemoFileExist:vm.fileName ])
                [self addMedia:vm];
            }
        }
    
    
    //page guid size
    UInt32 guidSizeData;
    [self readDataTo:&guidSizeData length:sizeof(UInt32)];
    //page guid data
    unsigned char guidDataBytes[guidSizeData];
    [self readDataTo:guidDataBytes length:guidSizeData];
    NSData *guidData = [NSData dataWithBytes:(const void*)guidDataBytes length:guidSizeData];
    _pageGuid = [[NSString alloc] initWithData:guidData encoding:NSUTF8StringEncoding];
    
    
    [self finishReadContent];
    return YES;
}
- (BOOL) saveWithImage:(BOOL)imageSaving
{
    _pageHasChanged = YES;
    return [self saveToURL:self.fileUrl imageSaving:imageSaving];
}
- (BOOL) saveToURL:(NSURL *)url
{
    if(url == nil)
        url = self.fileUrl;
    
   return [self saveToURL:url imageSaving:YES];
}
- (BOOL) saveToURL:(NSURL *)url imageSaving:(BOOL)imgSaving
{
    if (_pageHasChanged == NO) {
        NSLog(@"no changes, return from  saveToURL");
        return NO;
    }
    _pageHasChanged = NO;
    NSError *error = nil;
    NSFileManager *fm = [NSFileManager defaultManager];

    if ([fm fileExistsAtPath:[url path]] ||
        [fm createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:&error])
    {
        self.fileUrl = url;
        NSString *path = [[url path] stringByAppendingPathComponent:@"page.data"];

        NSMutableData *pageData = [[NSMutableData alloc] init];
        // Start write file content
        char neo[3] = {'n', 'e', 'o'};
        [pageData appendBytes:neo length:3];

        _fileVersion = FILE_VERSION_4;
        UInt32 noteId = (UInt32)self.notebookId;
        UInt32 pageNumber = (UInt32)self.pageNumber;
        [pageData appendBytes:&_fileVersion length:sizeof(UInt32)];
        [pageData appendBytes:&noteId length:sizeof(UInt32)];
        [pageData appendBytes:&pageNumber length:sizeof(UInt32)];
        //startX = _startOffsetX;
        //startY = _startOffsetY;
        
        // Paper information
        CGSize paperSize = self.paperSize;
        Float32 sizeData = (Float32)paperSize.width;
        [pageData appendBytes:&sizeData length:sizeof(Float32)];
        sizeData = (Float32)paperSize.height;
        [pageData appendBytes:&sizeData length:sizeof(Float32)];
        // Creation time & modification time
        UInt64 ctimeInterval = [self.cTime timeIntervalSince1970] * 1000.0f;
        [pageData appendBytes:&ctimeInterval length:sizeof(UInt64)];
        UInt64 mtimeInterval = [self.mTime timeIntervalSince1970] * 1000.0f;
        [pageData appendBytes:&mtimeInterval length:sizeof(UInt64)];
        unsigned char dirtyBit = (self.dirtyBit ? 1:0);
        [pageData appendBytes:&dirtyBit length:sizeof(unsigned char)];
        
        // Media
        UInt32 strokeCount = (UInt32)[self.strokes count];
        [pageData appendBytes:&strokeCount length:sizeof(UInt32)];
        NJMedia *media;
        for (int count=0; count < strokeCount; count++) {
            media = [self.strokes objectAtIndex:count];
            if (media.type == MEDIA_STROKE) {
                //[(NJStroke *)media writeMediaToData:pageData withStartX:startX andStartY:startY];
                [(NJStroke *)media writeMediaToData:pageData];
            }
            else if(media.type == MEDIA_VOICE) {
                [(NJVoiceMemo *)media writeMediaToData:pageData];
            }
        }
        
        NSData* guidData = [self.pageGuid dataUsingEncoding:NSUTF8StringEncoding];
        //guid data size
        UInt32 guidSizeData = (UInt32)[guidData length];
        [pageData appendBytes:&guidSizeData length:sizeof(UInt32)];
        //guid data
        unsigned char *guidDataBytes = (unsigned char *)[guidData bytes];
        [pageData appendBytes:guidDataBytes length:[guidData length]];
        
        [fm createFileAtPath:path contents:pageData attributes:nil];

        if(imgSaving) {
            @autoreleasepool {
                NSImage *thumb = [self createPageImageSmall:url];
                thumb = nil;
            }
        }
//        NSLog(@"saveToURL saved");
        
        return YES;
    }
    return NO;
}
- (NSImage *)createPageImageSmall:(NSURL *)url
{
    NSImage *thumb=[self renderPageWithSize:[self imageSize:350] bgOption:NJBgOptionsPDF];
    if (thumb) {
        NSString *path = [[url path] stringByAppendingPathComponent:@"thumb.jpg"];
        [thumb saveAsJpegWithName:path];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        if(!isEmpty(self.notebookUuid)) {
            NSDictionary *info = @{@"notebookUuid":self.notebookUuid,@"pageNum":[NSNumber numberWithInteger:self.pageNumber]};
            [[NSNotificationCenter defaultCenter] postNotificationName:NJPageImageUpdateNotification object:nil userInfo:info];
        }
    });
    return thumb;
}

- (NSImage *)createPageImageForSharingWithBackground:(NJBgOptions)bgOption
{
   return [self renderPageWithSize:[self imageSize:0] bgOption:bgOption];
}
- (CGRect)imageSize:(int)size
{
    CGSize imgSize = [self _getBackgroundImage].size;
    if(CGSizeEqualToSize(imgSize, CGSizeZero))
        imgSize = _paperSize;
    float scale = 1;
    float targetShortSize = ((size == 0)? (1024.0f / scale * 2.0f) : size);
    float ratio = 1;
    float page_w = imgSize.width;
    float page_h = imgSize.height;
    float shortSize = MIN(page_w,page_h);
    
    ratio = targetShortSize/shortSize;
    
    CGSize retSize;
    retSize.width = page_w*ratio;
    retSize.height = page_h*ratio;
    CGRect ret;
    ret.size = retSize;
    CGPoint origin = {0.0f, 0.0f};
    ret.origin = origin;
    return ret;
}
- (NSDate *)convertIntervalToNSDate:(UInt64)interval
{
    // in old file systems we did not store time by multiplying 1000
    // so if the number is very small id do not divide 1000 again
    NSTimeInterval timeInterval = interval;
    if(interval > 10000000000)
        timeInterval = (double)(interval/1000.0);
    NSDate *time = [[NSDate alloc]initWithTimeIntervalSince1970:timeInterval];
    return  time;
}


- (NSImage *) renderStroke:(NJStroke *)stroke withImage:(NSImage *)image
{
    NSImage *newImage = nil;
    NSArray *allStrokes = @[stroke];
    CGRect rect = CGRectZero;
    rect.size = image.size;
    if(CGRectIsEmpty(rect))
        rect = [self imageSize:350];
    newImage = [self renderStrokes:allStrokes withImage:image size:rect drawBG:YES opaque:YES scale:0.0 shouldCrop:NO];
    //NSLog(@"image size --> %@\nbounds size --> %@",NSStringFromCGSize(image.size),NSStringFromCGSize(bounds.size));
    
    return newImage;
}
#define MAX_IMG_WIDTH_SIZE 2048.0f
- (NSImage *) renderPageWithSize:(CGRect)bounds bgOption:(NJBgOptions)bgOption
{
    if((bgOption > 2))
        bgOption = NJBgOptionsPDF;
    
    CGSize paperSize=self.paperSize;
    float H = bounds.size.height;
    float W = bounds.size.width;
    
    CGFloat scale = (bgOption == NJBgOptionsPDF)? 0.0f : 1.0f;
    BOOL opaqueOption = (bgOption != NJBgOptionsTransparent);
    BOOL shouldCrop = (bgOption != NJBgOptionsPDF);
    CGSize scaledSize = (bgOption == NJBgOptionsPDF)? bounds.size : CGSizeMake(W * 2.0f, H * 2.0f);
    CGRect scaledRect = CGRectMake(0.0, 0.0, scaledSize.width, scaledSize.height);
    
    //NSLog(@"scaled rect --> %@",NSStringFromCGRect(scaledRect));
    if(scaledRect.size.width >= MAX_IMG_WIDTH_SIZE)
        scaledRect = [self imageSize:MAX_IMG_WIDTH_SIZE];
    //NSLog(@"scaled rect --> %@",NSStringFromCGRect(scaledRect));
    
    H = scaledSize.height;
    W = scaledSize.width;
    
    CGFloat wRatio = paperSize.width / W;
    CGFloat hRatio = paperSize.height / H;
    CGFloat ratio = MIN(wRatio, hRatio); // aspect full
    CGFloat rWidth = paperSize.width / ratio;
    CGFloat rHeight = paperSize.height / ratio;
    scaledRect = CGRectMake(0.0, 0.0, rWidth, rHeight);
    
    
    NSImage *newImage = nil;
    NSArray *allStrokes = [NSArray arrayWithArray:self.strokes];
    BOOL drawBG = (bgOption == NJBgOptionsPDF);
    newImage = [self renderStrokes:allStrokes withImage:nil size:bounds drawBG:drawBG opaque:opaqueOption scale:scale shouldCrop:shouldCrop];
    
    return newImage;

}
- (NSImage *) renderStrokes:(NSArray *)strokes withImage:(NSImage *)image size:(CGRect)bounds drawBG:(BOOL)drawBG opaque:(BOOL)opaque scale:(CGFloat)scale shouldCrop:(BOOL)shouldCrop
{
//    if(isEmpty(strokes)) return nil;
    @autoreleasepool {
        CGSize imageSize = bounds.size;
        if(scale > 0) {
            imageSize = CGSizeMake(bounds.size.width*scale, bounds.size.height*scale);
            bounds.size.width = bounds.size.width*scale;
            bounds.size.height = bounds.size.height*scale;
        }
        NSImage *newImage = [[NSImage alloc] initWithSize:imageSize];
        [newImage lockFocusFlipped:YES];
        
        //UIGraphicsBeginImageContextWithOptions(bounds.size, opaque, scale);
        //CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
        
        if(opaque) {
            NSBezierPath *rectpath = [NSBezierPath bezierPathWithRect:bounds];
            [[NSColor colorWithWhite:1.0f alpha:1] setFill];
            [rectpath fill];
        }
        
        if(drawBG) {
            
            if (image==nil) image = [self _getBackgroundImage];
            if (image) {
                [[NSColor whiteColor] set];
                NSRectFill(bounds);
                [image drawInRect:bounds];
            
            }
        }
        
        
        CGRect cropRect = CGRectZero;
        BOOL firstStroke = YES;
        CGFloat normalizerScale = MAX(bounds.size.width,bounds.size.height);

        
        for (NJStroke *stroke in strokes) {
            if (stroke.type != MEDIA_STROKE) continue;
            @autoreleasepool {
            [stroke renderWithScale:normalizerScale];
            [stroke drawStrokeInContext:context];
            }
            if(shouldCrop) {
                if(firstStroke) {
                    firstStroke = NO;
                    cropRect = stroke.totalBounds;
                    continue;
                }
                cropRect = CGRectUnion(cropRect, stroke.totalBounds);
            }
        }
        
        //NSImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        
        if(shouldCrop && !CGRectIsEmpty(cropRect)) {
            //NSLog(@"clipping rect ---> %@ of %@",NSStringFromCGRect(cropRect),NSStringFromCGRect(bounds));
            newImage = [self _cropImage:newImage withRect:cropRect];
        }
        
        CGContextFlush(context);
        //UIGraphicsEndImageContext();
        [newImage unlockFocus];
        return newImage;
    }
}
- (NSImage *)_getBackgroundImage
{
    //jr
    //if(_backgroundImg != nil) return _backgroundImg;
    //return nil;
    NJNotebookPaperInfo *noteInfo = [NJNotebookPaperInfo sharedInstance];
    int noteId = _notebookId;
    int pageNum = _pageNumber;
    NSString *pdfFileName = [noteInfo backgroundFileNameForSection:0 owner:0 note:noteId pageNumber:pageNum];
    if (pdfFileName) {
        NSURL *url =  [[NSBundle mainBundle] URLForResource:pdfFileName withExtension:nil];
        CGPDFDocumentRef pdf;
        pdf = CGPDFDocumentCreateWithURL((CFURLRef)url);
        int pageOffset = [noteInfo pdfPageOffsetForSection:0 owner:0 note:noteId];
        
        CGPDFPageRef pdfPage;
        if (/*(_notebookId == 501)||(_notebookId == 502)||*/(_notebookId == 2)||(_notebookId == 604)||(_notebookId == 610)
            ||(_notebookId == 611)||(_notebookId == 612)||(_notebookId == 613)||(_notebookId == 609)||(_notebookId == 614)
            ||(_notebookId == 615)||(_notebookId == 616)||(_notebookId == 617)||(_notebookId == 618)||(_notebookId == 619)
            ||(_notebookId == 620) || (_notebookId == 555)||(_notebookId == 700)||(_notebookId == 701)||(_notebookId == 702))
        {
            pdfPage = CGPDFDocumentGetPage(pdf, 1);
        }else{
            pdfPage = CGPDFDocumentGetPage(pdf, MAX(pageNum - pageOffset, 1));
            //CGPDFPageRef pdfPage = CGPDFDocumentGetPage(pdf, self.pageNumber - pageOffset);
        }
        CGPDFPageRetain(pdfPage); // Retain the PDF page
        _backgroundImg = [PDFPageConverter convertPDFPageToImage:pdfPage withResolution:144];
        
        CGPDFPageRelease(pdfPage);
        CGPDFDocumentRelease(pdf);
    } else {
        NSUInteger section, owner;
        [NPPaperManager section:&section owner:&owner fromNotebookId:noteId];
        NSURL *url =  [[NPPaperManager sharedInstance] getPdfURLForNotebookId:noteId section:section owner:owner];
        if(isEmpty(url)) return nil;
        
        CGPDFDocumentRef pdf;
        pdf = CGPDFDocumentCreateWithURL((CFURLRef)url);
        
        //CGPDFPageRef pdfPage = CGPDFDocumentGetPage(pdf, MAX(pageNum, 1));
        if (pageNum < 1) pageNum = 1;
        NSInteger pages = CGPDFDocumentGetNumberOfPages(pdf);
        
        if (pageNum > pages) pageNum = (int)pages;
        CGPDFPageRef pdfPage = CGPDFDocumentGetPage(pdf, pageNum);
        
        //CGPDFPageRef pdfPage = CGPDFDocumentGetPage(pdf, 1);
        CGPDFPageRetain(pdfPage); // Retain the PDF page
        _backgroundImg = [PDFPageConverter convertPDFPageToImage:pdfPage withResolution:144];
        
        CGPDFPageRelease(pdfPage);
        CGPDFDocumentRelease(pdf);
    }
    return _backgroundImg;
}
- (NSImage *)_cropImage:(NSImage *)image withRect:(CGRect)cropRect
{
    return image;
}



@end
