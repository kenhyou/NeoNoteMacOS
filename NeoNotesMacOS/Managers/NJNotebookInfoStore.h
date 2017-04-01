//
//  NJNotebookInfoStore.h
//  NeoJournal
//
//  Created by NamSSan on 10/08/2014.
//  Copyright (c) 2014 Neolab. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NJNotebookInfo;
@interface NJNotebookInfoStore : NSObject
{
    
    NSUInteger _curDigitalNoteId;
}


+ (NJNotebookInfoStore *)sharedStore;
+ (BOOL)writeNotebookInfo:(NJNotebookInfo *)notebookInfo inDirectory:(NSString*)directory;

- (NJNotebookInfo *)createNewDigitalNotebookInfo;
- (NJNotebookInfo *)createNewNotebookInfo:(NSUInteger)notebookId;
- (NJNotebookInfo *)getNotebookInfo:(NSString *)notebookUuid;
- (NJNotebookInfo *)getNotebookInfoWithDefaultInfo:(NSString *)notebookUuid;
- (NJNotebookInfo *)getNotebookInfoWithDefaultInfo:(NSString *)notebookUuid autoSave:(BOOL)save;
- (NJNotebookInfo *)getNotebookInfo:(NSString *)notebookUuid shouldCreateDefault:(BOOL)createDefault isTemporal:(BOOL)isTemporal autoSave:(BOOL)save;
- (NJNotebookInfo *)getNotebookInfoForGuid:(NSString *)notebookGuid;
- (BOOL)updateNotebookInfo:(NJNotebookInfo *)notebookInfo;
- (BOOL)checkIfSameNotebookNameAlreadyExist:(NSString *)notebookTitle;

@end
