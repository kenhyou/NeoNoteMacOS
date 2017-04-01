//
//  NPNotebookInfoEntity+CoreDataProperties.h
//  NeoNotes
//
//  Created by Sang Nam on 2/20/16.
//  Copyright © 2016 Neolabconvergence. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "NPNotebookInfoEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface NPNotebookInfoEntity (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *datePublished;
@property (nullable, nonatomic, retain) NSString *keyName;
@property (nullable, nonatomic, retain) NSNumber *noPages;
@property (nullable, nonatomic, retain) NSNumber *pdfPageReferType;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSNumber *type;
@property (nullable, nonatomic, retain) NSSet<NPPaperInfoEntity *> *paperInfo;

@end

@interface NPNotebookInfoEntity (CoreDataGeneratedAccessors)

- (void)addPaperInfoObject:(NPPaperInfoEntity *)value;
- (void)removePaperInfoObject:(NPPaperInfoEntity *)value;
- (void)addPaperInfo:(NSSet<NPPaperInfoEntity *> *)values;
- (void)removePaperInfo:(NSSet<NPPaperInfoEntity *> *)values;

@end

NS_ASSUME_NONNULL_END
