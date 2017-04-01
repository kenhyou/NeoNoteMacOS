//
//  NJCoverManager.h
//  NeoJournal
//
//

#import <Foundation/Foundation.h>

#define NUM_OF_AVAILABLE_DIGITAL_NOTE_NAME 10
#define NUM_OF_AVAILABLE_DIGITAL_NOTE_IMAGE 20

@interface NJCoverManager : NSObject

+ (NSImage *) getCoverResourceImage:(NSUInteger)notebookId;
+ (NSString *) getCoverName:(NSUInteger)notebookId shouldCreateUniqTitle:(BOOL)shouldUniq;
+ (NSString *) getCoverResourceImageName:(NSUInteger)notebookId;

@end
