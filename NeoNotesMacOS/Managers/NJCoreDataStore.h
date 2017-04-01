//
//  NJCoreDataManager.h
//  NeoJournal
//
#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>

@interface NJCoreDataStore : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *privateMoc;
@property (readonly, strong, nonatomic) NSManagedObjectContext *moc;
@property (readonly, strong, nonatomic) NSManagedObjectModel *mom;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *psc;


+ (NJCoreDataStore *)sharedStore;
- (void)saveContext:(BOOL)wait;
- (NSURL *)applicationDocumentsDirectory;

- (BOOL)addTagNoteUuid:(NSString *)notebookUuid andPageNum:(NSInteger)pageNum andTag:(NSString *)tag;
- (BOOL)addTagNoteUuid:(NSString *)notebookUuid andPageNum:(NSInteger)pageNum andTag:(NSString *)tagStr andDate:(NSDate *)date;
- (NSArray *)tagListForNotebook:(NSString *)notebookUuid pageNum:(NSUInteger)pageNum;

- (BOOL)deletePage:(NSUInteger)pageNum forNotebookUuid:(NSString *)notebookUuid;
- (BOOL)deleteTagNoteUuid:(NSString *)notebookUuid andPageNum:(NSInteger)pageNum andTag:(NSString *)tag;
- (NSUInteger)getNumberOfTagsForNotebookUuid:(NSString *)notebookUuid;


- (void)importTagsForNotebookUuid:(NSString *)notebookUuid tags:(NSArray *)tags;
- (NSArray *)exportTagsForNotebookUuid:(NSString *)notebookUuid;
- (BOOL)isMigrationNeeded;
- (BOOL)migrate:(NSError *__autoreleasing *)error;

@end
