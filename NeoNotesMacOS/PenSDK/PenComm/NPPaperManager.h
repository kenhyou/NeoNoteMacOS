//
//  NJPaperInfoManager
//  NeoPenSDK
//
//  Created by NamSang on 7/01/2016.
//  Copyright © 2016 Neolabconvergence. All rights reserved.
//

#import <Foundation/Foundation.h>



static NSString * const NPPaperInfoStorePaperBecomeAvailableNotification = @"NPPaperInfoStorePaperBecomeAvailableNotification";


@interface NPPaperManager : NSObject

@property (nonatomic) BOOL isDeveloperMode;

+ (instancetype) sharedInstance;
+ (NSString *) keyNameForNotebookId:(NSUInteger)notebookId section:(NSUInteger)section owner:(NSUInteger)owner;
+ (BOOL) notebookId:(NSUInteger *)notebookId section:(NSUInteger *)section owner:(NSUInteger *)owner fromKeyName:(NSString *)keyName;
+ (BOOL) section:(NSUInteger *)section owner:(NSUInteger *)owner fromNotebookId:(NSUInteger)notebookId;



- (NSArray *) notesSupported;
- (BOOL)installNotebookInfoForKeyName:(NSString *)keyName zipFilePath:(NSURL *)zipFilePath deleteExisting:(BOOL)deleteExisting;
- (NPNotebookInfo *) getNotebookInfoForKeyName:(NSString *)keyName;
- (NPNotebookInfo *) getNotebookInfoForNotebookId:(NSUInteger)notebookId section:(NSUInteger)section owner:(NSUInteger)owner;
- (NPPaperInfo *) getPaperInfoForNotebookId:(NSUInteger)notebookId pageNum:(NSUInteger)pageNum section:(NSUInteger)section owner:(NSUInteger)owner;



- (BOOL) hasPaperInfoForKeyName:(NSString *)keyName;
- (NSURL *) getPdfURLForNotebookId:(NSUInteger)notebookId section:(NSUInteger)section owner:(NSUInteger)owner;
- (NSImage *) getDefaultCoverImageForNotebookId:(NSUInteger)notebookId section:(NSUInteger)section owner:(NSUInteger)owner;
- (NSString *) getDefaultCoverNameForNotebookId:(NSUInteger)notebookId section:(NSUInteger)section owner:(NSUInteger)owner;
- (NSInteger) getEstimateNoteTypeFromDB:(CGSize)paperSize;
- (NSMutableArray *) notesSupportedFromDB;

@end
