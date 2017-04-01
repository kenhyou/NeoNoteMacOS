//
//  NJNotebookReaderManager.h
//  NeoJournal
//
//  Created by Ken on 14/02/2014.
//  Copyright (c) 2014 Neolab. All rights reserved.
//

#import "NJNotebookManager.h"

@class NJPage;
@interface NJNotebookReaderManager : NJNotebookManager

+ (NJNotebookReaderManager *) sharedInstance;

- (NJPage *)getQuickPageData:(NSUInteger)pageNum notebookUuid:(NSString *)notebookUuid;
- (NJPage *)getPageData:(NSUInteger)pageNum notebookUuid:(NSString *)notebookUuid;
- (NJPage *)getPageData:(NSUInteger)pageNum notebookUuid:(NSString *)notebookUuid loadStrokes:(BOOL)loadStrokes;
- (NSDictionary *)getPageImageAttr:(NSUInteger)pageNum forNotebookUuid:(NSString *)notebookUuid;
- (NSImage *)getPageImage:(NSUInteger)pageNum notebookUuid:(NSString *)notebookUuid scaledWidth:(CGFloat)width;
- (NSImage *)getSmallSizePageImage:(NSUInteger)pageNum notebookUuid:(NSString *)notebookUuid;
- (void)createAsyncPageThumbnail:(NSUInteger)pageNum notebookUuid:(NSString *)notebookUuid;
- (NSArray *)getFirstAndLastImagesForNotebookUuid:(NSString *)notebookUuid;
- (BOOL)syncOpenNotebook2:(NSString *)notebookUuid withPageNumber:(NSUInteger)pageNumber;
- (long)sizeForNotebook:(NSString *)notebookUuid;


@end
