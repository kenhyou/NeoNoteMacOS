//
//  NJCoreDataManager.m
//  NeoJournal
//
//  Created by NamSSan on 26/06/2014.
//  Copyright (c) 2014 Neolab. All rights reserved.
//

#import "NJCoreDataStore.h"
#import <CoreData/CoreData.h>

#import "NJPageEntity+CoreDataProperties.h"
#import "NJTagEntity+CoreDataProperties.h"
#import "NJTranscribeEntity+CoreDataProperties.h"
#import "NJTagXML.h"
#import "NJNotebookIdStore.h"
#import "NJMigrationManager.h"

@interface NJCoreDataStore () <NJMigrationManagerDelegate>

@end


@implementation NJCoreDataStore

@synthesize privateMoc = __privateMoc;
@synthesize moc = __moc;
@synthesize mom = __mom;
@synthesize psc = __psc;

// db transfer NeoJournal to NeoNotes
+ (NJCoreDataStore *)sharedStore
{
    static NJCoreDataStore *sharedStore = nil;
    
    @synchronized(self) {
        
        if(!sharedStore) {
            sharedStore = [[super allocWithZone:nil] init];
        }
    }
    
    return sharedStore;
}
- (id)init
{
    self = [super init];
    
    if(self) {
        
    }
    return self;
}

- (void)saveContext:(BOOL)wait
{
    NSManagedObjectContext *moc = self.moc;
    NSManagedObjectContext *private = self.privateMoc;
    
    if(!moc) return;
    if([moc hasChanges]) {
        [moc performBlockAndWait:^{
            NSError *error = nil;
            [moc save:&error];
        }];
    }
    
    void (^savePrivate)(void) = ^{
        NSError *error = nil;
        [private save:&error];
    };
    
    if([private hasChanges]) {
        if(wait)
            [private performBlockAndWait:savePrivate];
        else
            [private performBlock:savePrivate];
    }
}




#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)privateMoc
{
    if (__privateMoc != nil) {
        return __privateMoc;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self psc];
    if (coordinator != nil) {
        NSUInteger type = NSPrivateQueueConcurrencyType;
        __privateMoc = [[NSManagedObjectContext alloc] initWithConcurrencyType:type];
        [__privateMoc setPersistentStoreCoordinator:coordinator];
    }
    return __privateMoc;
}

- (NSManagedObjectContext *)moc
{
    if (__moc != nil) {
        return __moc;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self psc];
    if (coordinator != nil) {
        NSUInteger type = NSMainQueueConcurrencyType;
        __moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:type];
        [__moc setParentContext:self.privateMoc];
    }
    return __moc;
}



// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)mom
{
    if (__mom != nil) {
        return __mom;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"NeoNotes" withExtension:@"momd"];
    __mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __mom;
}



// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)psc
{
    if (__psc != nil) {
        return __psc;
    }
    
    NSError *error = nil;
    NSDictionary *options = nil;
    
    if ([self isMigrationNeeded]) {
        options = @{
                    NSInferMappingModelAutomaticallyOption: @YES,
                    NSSQLitePragmasOption: @{@"journal_mode": @"DELETE"}
                    };
    } else {
        options = @{
                    NSInferMappingModelAutomaticallyOption: @YES,
                    NSSQLitePragmasOption: @{@"journal_mode": @"WAL"}
                    };
    }
    
//    [options setValue:[NSNumber numberWithBool:YES] forKey:NSMigratePersistentStoresAutomaticallyOption];
//    [options setValue:[NSNumber numberWithBool:YES] forKey:NSInferMappingModelAutomaticallyOption];
    NSLog(@"store URL-->%@",[self sourceStoreURL]);
    __psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self mom]];
    if (![__psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[self sourceStoreURL] options:options error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return __psc;
}


- (NSURL *)sourceStoreURL
{
    return [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"NeoNotes.sqlite"];
}

- (NSString *)sourceStoreType
{
    return NSSQLiteStoreType;
}
- (NSDictionary *)sourceMetadata:(NSError **)error
{
    return [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:[self sourceStoreType]
                                                                      URL:[self sourceStoreURL]
                                                                    error:error];
}
- (BOOL)isMigrationNeeded
{
    NSError *error = nil;
    
    // Check if we need to migrate
    NSDictionary *sourceMetadata = [self sourceMetadata:&error];
    BOOL isMigrationNeeded = NO;
    
    if (sourceMetadata != nil) {
        NSManagedObjectModel *destinationModel = [self mom];
        // Migration is needed if destinationModel is NOT compatible
        isMigrationNeeded = ![destinationModel isConfiguration:nil
                                   compatibleWithStoreMetadata:sourceMetadata];
    }
    NSLog(@"isMigrationNeeded: %d", isMigrationNeeded);
    return isMigrationNeeded;
}
- (BOOL)migrate:(NSError *__autoreleasing *)error
{
    // Enable migrations to run even while user exits app
    NJMigrationManager *migrationManager = [NJMigrationManager new];
    migrationManager.delegate = self;
    
    BOOL OK = [migrationManager progressivelyMigrateURL:[self sourceStoreURL]
                                                 ofType:[self sourceStoreType]
                                                toModel:[self mom]
                                                  error:error];
    if (OK) {
        NSLog(@"migration complete");
    }
    return OK;
}




#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}





- (NSArray *)fetchAllTags
{
    
    NSManagedObjectContext *context = self.moc;
    
    // first check if this entry is already exist in the db
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"NJTagEntity" inManagedObjectContext:context];
    
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    
    //NSString *predicateString = [NSString stringWithFormat: @"notebookId == %ld AND pageNum == %ld",notebookId,pageNum];
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
    //[fetchRequest setPredicate:predicate];
    
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    
    return results;
}

- (BOOL)addTagNoteUuid:(NSString *)notebookUuid andPageNum:(NSInteger)pageNum andTag:(NSString *)tagStr
{
    return [self addTagNoteUuid:notebookUuid andPageNum:pageNum andTag:tagStr andDate:nil];
}
- (BOOL)addTagNoteUuid:(NSString *)notebookUuid andPageNum:(NSInteger)pageNum andTag:(NSString *)tagStr andDate:(NSDate *)date
{

    if(isEmpty(tagStr)) return NO;
    if(isEmpty(date)) date = [NSDate date];

    NSManagedObjectContext *context = self.moc;
    
    // first check if this entry is already exist in the db
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"NJPageEntity" inManagedObjectContext:context];
    
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    
    //NSString *predicateString = [NSString stringWithFormat: @"notebookId LIKE %@ AND pageNum == %ld",notebookUuid,pageNum];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"notebookUuid LIKE %@ AND pageNum == %ld",notebookUuid,pageNum];
    [fetchRequest setPredicate:predicate];
    
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    
    if(!results) {
        
        NSLog(@"Failed to fetch data from DB");
        return NO;
        
    } else {
        
        BOOL found = NO;
        
        NJPageEntity *pageEntity = nil;
        
        if(results.count == 0) {
            // no entry for the page --> so we create one first
            pageEntity = [NSEntityDescription insertNewObjectForEntityForName:@"NJPageEntity" inManagedObjectContext:context];
            pageEntity.notebookUuid =notebookUuid;
            pageEntity.pageNum = [NSNumber numberWithInteger:pageNum];
            
        } else {
            // this entry already exist so we just update it with new tag entries
            pageEntity = [results objectAtIndex:0];
            NSSet *tagSet = pageEntity.tags;
            NSArray *tagArray = [tagSet allObjects];
            
            for(NJTagEntity *e in tagArray) {
                //NSLog(@"tag (%@) ---> %@",e.dateCreated,e.tagName);
                if([e.tagName isEqualToString:tagStr]) {
                    found = YES;
                    break;
                }
            }
        }

        if(!found) {
            
            NJTagEntity *tagEntity = [NSEntityDescription insertNewObjectForEntityForName:@"NJTagEntity" inManagedObjectContext:context];
            tagEntity.tagName = [tagStr copy];
            tagEntity.dateCreated = date;
            
            [pageEntity addTagsObject:tagEntity];
            
            [self saveContext:YES];
            
        } else {
            NSLog(@"tag[\"%@\"] alreay exist -- not saving again",tagStr);
            return NO;
        }
        
    }
    
    return YES;
}
- (NSArray *)tagListForNotebook:(NSString *)notebookUuid pageNum:(NSUInteger)pageNum
{
    // save to db & unset dirty-bit
    NSManagedObjectContext *context = self.moc;
    
    // first check if this entry is already exist in the db
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"NJPageEntity" inManagedObjectContext:context];
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"notebookUuid LIKE %@ AND pageNum == %ld",notebookUuid,pageNum];
    [fetchRequest setPredicate:predicate];
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    NSArray *tagList = nil;
    
    if(results) {
        
        NJPageEntity *pageEntity = nil;
        if(results.count > 0) {

            pageEntity = [results objectAtIndex:0];
            NSSet *tagSet = pageEntity.tags;
            tagList = [tagSet allObjects];
            
            if(!isEmpty(tagList)) {
                NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"tagName" ascending:YES];
                tagList = [tagList sortedArrayUsingDescriptors:@[sd]];
            }
        }
    }
    return tagList;
}




- (BOOL)deleteTagNoteUuid:(NSString *)notebookUuid andPageNum:(NSInteger)pageNum andTag:(NSString *)tag
{
    
    if(isEmpty(tag)) return NO;
    
    NSManagedObjectContext *context = self.moc;
    
    // first check if this entry is already exist in the db
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"NJPageEntity" inManagedObjectContext:context];
    
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    
    //NSString *predicateString = [NSString stringWithFormat: @"notebookId LIKE %@ AND pageNum == %ld",notebookUuid,pageNum];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"notebookUuid LIKE %@ AND pageNum == %ld",notebookUuid,pageNum];
    [fetchRequest setPredicate:predicate];
    
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    
    if(!results) {
        
        NSLog(@"Failed to fetch data from DB");
        //return;
        
    } else {
        
        NJPageEntity *pageEntity = nil;
        
        if(results.count == 0) {
            
            // Impossible!
            // should not be happened.. we already created/updated at least one page to reach this VC
            NSLog(@"ERROR: no record found from DB");
            return NO;
            
        } else {
            
            // this entry already exist so we just update it with new tag entries
            pageEntity = [results objectAtIndex:0];
            
            NSSet *tagSet = pageEntity.tags;
            NSArray *tagArray = [tagSet allObjects];
            
            
            BOOL found = NO;
            
            NJTagEntity *e = nil;
            
            for(e in tagArray) {
    
                if([e.tagName isEqualToString:tag]) {
                    found = YES;
                    break;
                }
            }
            
            if(found) {
                
                [context deleteObject:e];
                [self saveContext:YES];
                
            } else {
                
                NSLog(@"tag:%@ not found must be error",tag);
                return NO;
            }
        }
    }
    
    return YES;
}





- (BOOL)deletePage:(NSUInteger)pageNum forNotebookUuid:(NSString *)notebookUuid
{
    NSManagedObjectContext *context = self.moc;
    // first check if this entry is already exist in the db
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"NJPageEntity" inManagedObjectContext:context];
    
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    
    //NSString *predicateString = [NSString stringWithFormat: @"notebookId LIKE %@ AND pageNum == %ld",notebookUuid,pageNum];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"notebookUuid LIKE %@ AND pageNum == %ld",notebookUuid,pageNum];
    [fetchRequest setPredicate:predicate];
    
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    
    if(!results) {
        
        NSLog(@"Failed to fetch data from DB");
        //return;
        
    } else {
        
        NJPageEntity *pageEntity = nil;
        
        if(results.count == 0) {
            
            // Impossible!
            // should not be happened.. we already created/updated at least one page to reach this VC
            NSLog(@"NOT Found but NOT ERROR: we just don't have db info for this page");
            return YES;
            
        } else {
            
            // this entry already exist so we just update it with new tag entries
            pageEntity = [results objectAtIndex:0];
            
            NSSet *tagSet = pageEntity.tags;
            NSArray *tagArray = [tagSet allObjects];
            
            
            NJTagEntity *e = nil;
            
            for(e in tagArray) {
                
                [context deleteObject:e];
                
            }
            [context deleteObject:pageEntity];
            
            [self saveContext:YES];
            /*
            if (![context save:&error]) {
                
                NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
                return YES;
            }
            */
            
        }
    }
    
    return YES;
}

- (NSUInteger)getNumberOfTagsForNotebookUuid:(NSString *)notebookUuid
{
    // save to db & unset dirty-bit
    NSManagedObjectContext *context = self.moc;
    
    // first check if this entry is already exist in the db
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"NJPageEntity" inManagedObjectContext:context];
    
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    
    //NSString *predicateString = [NSString stringWithFormat: @"notebookId LIKE %@",notebookUuid];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"notebookUuid LIKE %@",notebookUuid];
    [fetchRequest setPredicate:predicate];
    
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    NSUInteger totTags = 0;
    
    if(!results) {
        
        NSLog(@"Failed to fetch data from DB");
        return 0;
        
    } else {
        
        NJPageEntity *pageEntity = nil;
        
        if(results.count == 0) {
            
            return 0;
            
        } else {

            for (int i=0; i < results.count; i++) {
            
                // this entry already exist so we just update it with new tag entries
                pageEntity = [results objectAtIndex:i];
                
                NSSet *tagSet = pageEntity.tags;
                //NSArray *tagArray = [tagSet allObjects];
                
                totTags += tagSet.count;

            }
            
            
        }
    }
    
    return totTags;
}
- (void)importTagsForNotebookUuid:(NSString *)notebookUuid tags:(NSArray *)tags
{
    
    if(isEmpty(tags) || notebookUuid) return;
    
    NJTagXML *tagXML = nil;
    for(tagXML in tags) {
        [self addTagNoteUuid:notebookUuid andPageNum:tagXML.pageNum andTag:tagXML.tagName];
    }
    
    
}
- (NSArray *)exportTagsForNotebookUuid:(NSString *)notebookUuid
{
    NSManagedObjectContext *context = self.moc;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"NJPageEntity" inManagedObjectContext:context];
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"notebookUuid LIKE %@",notebookUuid];
    [fetchRequest setPredicate:predicate];
    
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    NSMutableArray *tags = [NSMutableArray array];
    
    if(error) {
        NSLog(@"Failed to fetch data from DB");
        return tags;
    }
    
    NJPageEntity *pageEntity = nil;
    NJTagXML *tagXML = nil;
    
    for (int i=0; i < results.count; i++) {
    
        pageEntity = [results objectAtIndex:i];
        NSSet *tagSet = pageEntity.tags;
        NSArray *tagArray = [tagSet allObjects];
        
        for(int j=0; j < tagArray.count; j++) {
            
            NJTagEntity *tagEntity = [tagArray objectAtIndex:j];
            tagXML = [[NJTagXML alloc] init];
            tagXML.tagName = tagEntity.tagName;
            tagXML.dateCreated = tagEntity.dateCreated;
            tagXML.pageNum = [pageEntity.pageNum integerValue];
            
            [tags addObject:tagXML];
        }
    }
    return tags;
}


@end
