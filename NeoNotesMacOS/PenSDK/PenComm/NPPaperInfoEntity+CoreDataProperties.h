//
//  NPPaperInfoEntity+CoreDataProperties.h
//  NeoNotes
//
//  Created by Sang Nam on 2/20/16.
//  Copyright © 2016 Neolabconvergence. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "NPPaperInfoEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface NPPaperInfoEntity (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *height;
@property (nullable, nonatomic, retain) NSNumber *pageNum;
@property (nullable, nonatomic, retain) NSNumber *startX;
@property (nullable, nonatomic, retain) NSNumber *startY;
@property (nullable, nonatomic, retain) NSNumber *width;
@property (nullable, nonatomic, retain) NPNotebookInfoEntity *notebookInfo;
@property (nullable, nonatomic, retain) NSSet<NPPUIInfoEntity *> *puiInfo;

@end

@interface NPPaperInfoEntity (CoreDataGeneratedAccessors)

- (void)addPuiInfoObject:(NPPUIInfoEntity *)value;
- (void)removePuiInfoObject:(NPPUIInfoEntity *)value;
- (void)addPuiInfo:(NSSet<NPPUIInfoEntity *> *)values;
- (void)removePuiInfo:(NSSet<NPPUIInfoEntity *> *)values;

@end

NS_ASSUME_NONNULL_END
