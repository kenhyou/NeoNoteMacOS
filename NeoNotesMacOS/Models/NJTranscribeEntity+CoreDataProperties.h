//
//  NJTranscribeEntity+CoreDataProperties.h
//  NeoNotes
//
//  Created by NamSang on 12/10/2015.
//  Copyright © 2015 Neolabconvergence. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "NJTranscribeEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface NJTranscribeEntity (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *dateTranscribed;
@property (nullable, nonatomic, retain) NSNumber *lngPack;
@property (nullable, nonatomic, retain) NSString *pageText;
@property (nullable, nonatomic, retain) NJPageEntity *pageInfo;

@end

NS_ASSUME_NONNULL_END
