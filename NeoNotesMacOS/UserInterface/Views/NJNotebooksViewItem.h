//
//  NJNotebooksViewItem.h
//  NeoNotesMacOS
//
//  Created by Ken You on 11/12/2016.
//  Copyright © 2016 Neolabconvergence. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NJNotebooksViewItem : NSCollectionViewItem
@property (weak) IBOutlet NSImageView *notebookCoverImageView;
@property (weak) IBOutlet NSTextField *notebookTitleView;
@property (weak) IBOutlet NSTextField *lastModifiedDateView;
@end
