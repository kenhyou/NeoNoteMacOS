//
//  NJNotebookInfo.h
//  NeoJournal
//
//  Created by NamSSan on 10/08/2014.
//  Copyright (c) 2014 Neolab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NJNotebookInfo : NSObject <NSCoding>


@property (nonatomic) NSUInteger notebookId;
@property (nonatomic, strong) NSString *notebookUuid;
@property (nonatomic, strong) NSString *notebookGuid;
@property (nonatomic) NSUInteger totNoPages;
@property (nonatomic, copy) NSString *notebookTitle;
@property (nonatomic, strong) NSDate *lastModifiedDate;
@property (nonatomic, strong) NSDate *createdDate;
@property (nonatomic, strong,readonly) NSDate *timeTitleModifed;
@property (nonatomic, strong) NSDate *archivedDate;
@property (nonatomic, strong) NSImage *coverImage;


@end
