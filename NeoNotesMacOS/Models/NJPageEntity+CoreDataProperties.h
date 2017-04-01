//
//  NJPageEntity+CoreDataProperties.h
//  NeoNotes
//
//  Created by NamSang on 12/10/2015.
//  Copyright © 2015 Neolabconvergence. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "NJPageEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface NJPageEntity (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *dateCreated;
@property (nullable, nonatomic, retain) NSDate *dateModified;
@property (nullable, nonatomic, retain) NSString *evGuid;
@property (nullable, nonatomic, retain) NSDate *evSyncTime;
@property (nullable, nonatomic, retain) NSString *notebookUuid;
@property (nullable, nonatomic, retain) NSNumber *pageNum;
@property (nullable, nonatomic, retain) NJNotebookEntity *notebookInfo;
@property (nullable, nonatomic, retain) NJTranscribeEntity *pageText;
@property (nullable, nonatomic, retain) NSSet<NJStrokeEntity *> *strokes;
@property (nullable, nonatomic, retain) NSSet<NJTagEntity *> *tags;

@end

@interface NJPageEntity (CoreDataGeneratedAccessors)

- (void)addStrokesObject:(NJStrokeEntity *)value;
- (void)removeStrokesObject:(NJStrokeEntity *)value;
- (void)addStrokes:(NSSet<NJStrokeEntity *> *)values;
- (void)removeStrokes:(NSSet<NJStrokeEntity *> *)values;

- (void)addTagsObject:(NJTagEntity *)value;
- (void)removeTagsObject:(NJTagEntity *)value;
- (void)addTags:(NSSet<NJTagEntity *> *)values;
- (void)removeTags:(NSSet<NJTagEntity *> *)values;

@end

NS_ASSUME_NONNULL_END
