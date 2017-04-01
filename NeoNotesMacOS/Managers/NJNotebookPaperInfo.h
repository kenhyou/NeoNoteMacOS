//
//  NJNotebookPaperInfo.h
//  NeoJournal
//
//  Copyright (c) 2014 Neolab. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
    unsigned section_id;
    UInt32 owner_id;  // 3 bytes
    UInt32 note_id;
    int max_page;
    int width;
    int heght;
    int dx;
    int dy;
    float startX;
    float startY;
    char *page_1;
    char *page_2;
    char *page_even;
    char *page_odd;
} NotebookInfoType;


@interface NJNotebookPaperInfo : NSObject
@property (nonatomic) int noteListLength;
@property (strong, nonatomic) NSMutableDictionary *notebookPuiInfo;
@property (strong, nonatomic) NSMutableArray *tempNotebooks;

+ (NJNotebookPaperInfo *) sharedInstance;
- (BOOL) hasInfoForNotebookId:(int)notebookId;
- (BOOL) hasInfoForNotebookIdFromPlist:(int)notebookId;
- (BOOL) hasInfoForSectionId:(int)sectionId OwnerId:(int)ownerId;
//- (BOOL) getPaperDotcodeRangeForNotebook:(int)notebookId Xmax:(float *)x Ymax:(float *)y;
- (BOOL) getPaperDotcodeRangeForNotebook:(int)notebookId PageNumber:(int)pageNumber Xmax:(float *)x Ymax:(float *)y;
//- (BOOL) getPaperDotcodeStartForNotebook:(int)notebookId startX:(float *)x startY:(float *)y;
- (BOOL) getPaperDotcodeStartForNotebook:(int)notebookId PageNumber:(int)pageNumber startX:(float *)x startY:(float *)y;

/* Deprecated : This function should not be used. BG has been replaced by dpf. */
- (NSString *) backgroundImageNameForNotebook:(int)notebookId atPage:(int)pageNumber;
- (UInt32) noteIdAt:(int)index;
- (UInt32) sectionOwnerIdAt:(int)index;
- (NSArray *) notesSupported;
/* Return background pdf file name. */
- (NSString *) backgroundFileNameForSection:(int)section owner:(UInt32)onwerId note:(UInt32)noteId pageNumber:(UInt32)pageNmber;
/* Return difference in page number between pdf and note. */
- (int) pdfPageOffsetForSection:(int)sectionId owner:(UInt32)onwerId note:(UInt32)noteId;
- (NotebookInfoType) getPaperInfoForNotebook:(int)notebookId;
- (NSInteger)estimateNoteTypeFromPaperSize:(CGSize)paperSize;
@end
