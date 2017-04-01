//
//  NPPUIInfoEntity+CoreDataProperties.h
//  NeoNotes
//
//  Created by Sang Nam on 2/20/16.
//  Copyright © 2016 Neolabconvergence. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "NPPUIInfoEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface NPPUIInfoEntity (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *cmd;
@property (nullable, nonatomic, retain) NSString *extraInfo;
@property (nullable, nonatomic, retain) NSNumber *height;
@property (nullable, nonatomic, retain) NSNumber *shape;
@property (nullable, nonatomic, retain) NSNumber *startX;
@property (nullable, nonatomic, retain) NSNumber *startY;
@property (nullable, nonatomic, retain) NSNumber *width;
@property (nullable, nonatomic, retain) NPPaperInfoEntity *paperInfo;

@end

NS_ASSUME_NONNULL_END
