//
//  NJPage.h
//  NeoJournal
//
//  Copyright (c) 2014 Neolab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NJMedia.h"

#define MAX_NODE_NUMBER 1024*STROKE_NUMBER_MAGNITUDE

typedef NS_ENUM (NSInteger, NJBgOptions) {
    NJBgOptionsPDF,
    NJBgOptionsWhite,
    NJBgOptionsTransparent
};

@class NJStroke;

@interface NJPage : NSObject
@property (strong, nonatomic) NSURL *fileUrl;
@property (strong, nonatomic) NSMutableArray *strokes;
@property (nonatomic) BOOL pageHasChanged;
@property (nonatomic) CGSize paperSize; //notebook size
@property (nonatomic) CGPoint paperOffset;
@property (nonatomic) CGSize userSpaceSize;
@property (nonatomic) int notebookId;
@property (nonatomic) int pageNumber;
@property (nonatomic) BOOL dirtyBit;
@property (nonatomic) float page_x;
@property (nonatomic) float page_y;

@property (nonatomic) float inputScale;
@property (nonatomic, readonly) UInt32 fileVersion;
@property (nonatomic) UInt32 penColor;
@property (nonatomic, strong) NSDate *cTime;
@property (nonatomic, strong) NSDate *mTime;
@property (strong, nonatomic) NSMutableArray *voiceMemo;
@property (nonatomic, strong) NSString *pageGuid;
@property (nonatomic,strong) NSString *notebookUuid; // for handling seal

- (instancetype) initWitPage:(NJPage *)page;
- (instancetype) initWithNotebookId:(int)notebookId andPageNumber:(int)pageNumber;
- (void) addMedia:(NJMedia *)media;
- (void) addStroke:(NJStroke *)stroke;
- (void) removeVoiceMemoFile:(NSString *)fileName;
- (void) removeStroke:(NJStroke *)stroke;
- (void) insertStrokeByTimestamp:(NJStroke *)stroke;
- (NSImage *) createPageImageSmall:(NSURL *)url;
- (NSImage *) createPageImageForSharingWithBackground:(NJBgOptions)bgOption;
- (NSImage *) renderStroke:(NJStroke *)stroke withImage:(NSImage *)image;
- (NSImage *) renderPageWithSize:(CGRect)bounds bgOption:(NJBgOptions)bgOption;
- (void) setTransformationWithOffsetX:(float)x offset_y:(float)y scale:(float)scale;
- (BOOL) saveWithImage:(BOOL)imageSaving;
- (BOOL) saveToURL:(NSURL *)url imageSaving:(BOOL)imgSaving;
- (BOOL) saveToURL:(NSURL *)url;
//- (BOOL) readFromURL:(NSURL *)url error:(NSError *__autoreleasing *)outError loadStrokes:(BOOL)loadStrokes;
- (BOOL) readFromURL:(NSURL *)url readMetaFile:(BOOL)readMeta metaOnly:(BOOL)metaOnly;
- (CGRect) imageSize:(int)size;
- (UInt32) fileVersion;
//- (void) simplifyStrokes;
- (CGFloat) normalizer;



//- (void) renderInContext:(CGContextRef)ctx clipRect:(CGRect)clip withBackground:(BOOL)background;
///@property (nonatomic) CGRect bounds;
//@property (nonatomic) float screenRatio;
//@property (nonatomic) int notebookIdInFile;
//@property (nonatomic) int pageNumberInFile;
@end
