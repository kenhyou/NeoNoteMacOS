//
//  NJNotebookNameStore.h
//  NeoJournal
//
//  Created by NamSSan on 17/09/2014.
//  Copyright (c) 2014 Neolab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NJNotebookIdStore : NSObject
{
    
    NSMutableArray *_notebook_uuid_table;
}


+ (NJNotebookIdStore *)sharedStore;
+ (NSString *)createUuid;
+ (NSString *)createUuidOfSameType:(NSInteger)noteType;
+ (BOOL)hasFranklinNotebook;
+ (BOOL)isSampleNote:(NSString *)notebookUuid;
+ (BOOL)isDigitalNote:(NSString *)notebookUuid;
+ (NSUInteger)noteIdFromUuid:(NSString *)uuid;


- (NSString *)notebookIdName:(NSUInteger)notebookId;
- (NSString *)notebookIdNameForDigitalNotebook:(NSUInteger)notebookId;
- (NSString *)getCurrentActiveNotebookUuid:(NSUInteger)notebookId;
- (BOOL)removeNotebook:(NSString *)notebookUuid;
- (BOOL)isActiveNotebook:(NSString *)notebookUuid;
- (NSString *)sealLabelScanned:(NSUInteger)notebookId;
- (void)activateNotebookUuid:(NSString *)notebookUuid;
- (BOOL)deActivateNotebookUuid:(NSString *)notebookUuid;

@end
