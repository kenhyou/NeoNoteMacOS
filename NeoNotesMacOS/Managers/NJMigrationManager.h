//
//  NJMigrationManager.h
//  NeoNotes
//
//  Created by NamSang on 12/10/2015.
//  Copyright © 2015 Neolabconvergence. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NJMigrationManager;

@protocol NJMigrationManagerDelegate <NSObject>

@optional
- (void)migrationManager:(NJMigrationManager *)migrationManager migrationProgress:(float)migrationProgress;
- (NSArray *)migrationManager:(NJMigrationManager *)migrationManager mappingModelsForSourceModel:(NSManagedObjectModel *)sourceModel;

@end


@interface NJMigrationManager : NSObject

- (BOOL)progressivelyMigrateURL:(NSURL *)sourceStoreURL
                         ofType:(NSString *)type
                        toModel:(NSManagedObjectModel *)finalModel
                          error:(NSError **)error;

@property (nonatomic, weak) id<NJMigrationManagerDelegate> delegate;


@end
