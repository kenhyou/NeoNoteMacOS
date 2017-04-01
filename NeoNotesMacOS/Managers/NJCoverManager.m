//
//  NJCoverManager.m
//  NeoJournal
//
//  Copyright (c) 2014년 Neolab. All rights reserved.
//

#import "NJCoverManager.h"
#import "NJNotebookIdStore.h"
#import "NPPaperManager.h"

@implementation NJCoverManager



+ (NSString *) getCoverName:(NSUInteger)notebookId shouldCreateUniqTitle:(BOOL)shouldUniq
{
    NSString *notebookTitle = @"Unknown Note";
    
    //NSInteger type = [notebookId integerValue];
    int indx;
    NSString *str;
    
    switch(notebookId){
            
        case 2:
            notebookTitle = @"Mscribe";
            break;
        case 551:
            notebookTitle = @"N Toaster A";
            break;
        case 552:
            notebookTitle = @"N Toaster B";
            break;
        case 553:
            notebookTitle = @"N Toaster C";
            break;
        case 554:
            notebookTitle = @"N Toaster D";
            break;
        case 555:
            notebookTitle = @"N Toaster E";
            break;
        case 556:
            notebookTitle = @"N Toaster Print Test";
            break;
        case 557:
            notebookTitle = @"N Toaster SS";
            break;
        case 601:
            notebookTitle = @"Pocket Note";
            break;
        case 602:
            notebookTitle = @"Memo Note";
            break;
        case 603:
            notebookTitle = @"Ring Note";
            break;
        case 604:
            notebookTitle = @"Plain Note 01";
            break;
        case 605:
            notebookTitle = @"FP Memo Pad";
            break;
        case 606:
            notebookTitle = @"FP Original CEO";
            break;
        case 608:
            notebookTitle = @"Casual Planner";
            break;
        case 609:
            notebookTitle = @"Idea Pad";
            break;
        case 610:
            notebookTitle = @"Plain Note 02";
            break;
        case 611:
            notebookTitle = @"Plain Note 03";
            break;
        case 612:
            notebookTitle = @"Plain Note 04";
            break;
        case 613:
            notebookTitle = @"Plain Note 05";
            break;
        case 614:
            notebookTitle = @"N A4";
            break;
        case 615:
            notebookTitle = @"Professional Note";
            break;
        case 616:
            notebookTitle = @"Professional Mini";
            break;
        case 617:
            notebookTitle = @"College Note 01";
            break;
        case 618:
            notebookTitle = @"College Note 02";
            break;
        case 619:
            notebookTitle = @"College Note 03";
            break;
        case 620:
            notebookTitle = @"Idea Pad Mini";
            break;
        case 621:
            notebookTitle = @"FP CEO 2016";
            break;
        case 622:
            notebookTitle = @"FP CO 2016";
            break;
        case 623:
            notebookTitle = @"FP Casual32 2016";
            break;
        case 624:
            notebookTitle = @"FP Casual25 2016";
            break;
        case 625:
            notebookTitle = @"N Blank Planner";
            break;
        case 114:
            notebookTitle = @"Oree Stylograph Journal";
            break;
        case 700:
            notebookTitle = @"N Moleskine classic";
            break;
        case 701:
            notebookTitle = @"Paper Tablet 01";
            break;
        case 702:
            notebookTitle = @"Paper Tablet 02";
            break;
        case 800:
            notebookTitle = @"김정기 에디션";
            break;
        case 898:
            notebookTitle = @"So So Diary";
            break;
        case 899:
            notebookTitle = @"Smart Pen 102";
            break;
            
        default:
            notebookTitle = @"Unknown Note";
            
    }
    
    if ([notebookTitle isEqualToString:@"Unknown Note"]) {
        NSUInteger section, owner;
        [NPPaperManager section:&section owner:&owner fromNotebookId:notebookId];
        NSString *keyNameDB = [NPPaperManager keyNameForNotebookId:notebookId section:section owner:owner];
        
        if([[NPPaperManager sharedInstance] hasPaperInfoForKeyName:keyNameDB]){
            NPNotebookInfo *notebookInfoDB = [[NPPaperManager sharedInstance] getNotebookInfoForNotebookId:notebookId section:section owner:owner];
            notebookTitle = notebookInfoDB.title;
        }
    }
    
    if(notebookId >= kNOTEBOOK_ID_START_DIGITAL) {
        // this is for digital note name
        indx = (notebookId % NUM_OF_AVAILABLE_DIGITAL_NOTE_NAME)+1;
        str = [NSString stringWithFormat:@"NC_DITAL_BOOK_NAME_%02d",indx];
        notebookTitle =  NSLocalizedString(str, nil);
    }
    
    NSString *newTitle = notebookTitle;
    
    if(shouldUniq && notebookId != 898)
        return [notebookTitle stringByAppendingString:[NJCoverManager createUniqNumber:notebookId]];
    
    return newTitle;
}

+ (NSString *)createUniqNumber:(NSUInteger)noteType
{
    NSString *uniq = @"";
    
    
    BOOL isDigitalNotebook = (noteType >= kNOTEBOOK_ID_START_DIGITAL);
    
    NSInteger count = 0;
    if(isDigitalNotebook) {
        
        NSArray *noteList = [[NJNotebookReaderManager sharedInstance] digitalNotebookList];
        for(NSString *notebookUuid in noteList) {
            
            if(([NJNotebookIdStore noteIdFromUuid:notebookUuid] % NUM_OF_AVAILABLE_DIGITAL_NOTE_NAME)  == (noteType % NUM_OF_AVAILABLE_DIGITAL_NOTE_NAME))
                count++;
        }
        
    } else {
        
        NSArray *noteList = [[NJNotebookReaderManager sharedInstance] realNotebookList];
        for(NSString *notebookUuid in noteList) {
            
            if([NJNotebookIdStore noteIdFromUuid:notebookUuid] == noteType)
                count++;
        
        }
        count--; // decrease by 1 to exclude myself
    }
    
    //BOOL upper = (((arc4random() * 10) %2) == 0);
    //char startChar = (upper)? 'A' : 'a';
    //char randChar = 'a' + ((arc4random() * 100) % 24);
    //uniq = [NSString stringWithFormat:@" %02lu%c",(unsigned long)count,randChar];
    //count--; // decrease by 1 to exclude myself
    if(count > 0)
        uniq = [NSString stringWithFormat:@"_%03td",count];

    return uniq;
}

+ (NSString *) getCoverResourceImageName:(NSUInteger)notebookId
{
    NSString *coverImageName = nil;
    
    //NSInteger type = [notebookId integerValue];
    
    switch(notebookId){
        case 2:
            coverImageName = @"book cover_D15.png";
            break;
        case 550:
            coverImageName = @"bookcover_550_neopdfpaper.png";
            break;
        case 551:
            coverImageName = @"bookcover_ntoaster_a.png";
            break;
        case 552:
            coverImageName = @"bookcover_ntoaster_b.png";
            break;
        case 553:
            coverImageName = @"bookcover_ntoaster_c.png";
            break;
        case 554:
            coverImageName = @"bookcover_ntoaster_d.png";
            break;
        case 555:
            coverImageName = @"bookcover_ntoaster_e.png";
            break;
        case 556:
            coverImageName = @"bookcover_ntoaster_printtest.png";
            break;
        case 557:
            coverImageName = @"bookcover_ntoaster_ss.png";
            break;
        case 601:
            coverImageName = @"bookcover_pocket.png";
            break;
        case 602:
            coverImageName = @"bookcover_memo.png";
            break;
        case 603:
            coverImageName = @"bookcover_ring.png";
            break;
        case 604:
            coverImageName = @"bookcover_604_plain01.png";
            break;
        case 605:
            coverImageName = @"bookcover_fpmemopad.png";
            break;
        case 606:
            coverImageName = @"bookcover_fpceo.png";
            break;
        case 608:
            coverImageName = @"bookcover_fpcasual.png";
            break;
        case 609:
            coverImageName = @"bookcover_609_ideapad.png";
            break;
        case 610:
            coverImageName = @"bookcover_610_plain02.png";
            break;
        case 611:
            coverImageName = @"bookcover_611_plain03.png";
            break;
        case 612:
            coverImageName = @"bookcover_612_plain04.png";
            break;
        case 613:
            coverImageName = @"bookcover_613_plain05.png";
            break;
        case 614:
            coverImageName = @"bookcover_614_na4.png";
            break;
        case 615:
            coverImageName = @"bookcover_615_professional.png";
            break;
        case 616:
            coverImageName = @"bookcover_616_professionalmini.png";
            break;
        case 617:
            coverImageName = @"bookcover_617_college1.png";
            break;
        case 618:
            coverImageName = @"bookcover_618_college2.png";
            break;
        case 619:
            coverImageName = @"bookcover_619_college3.png";
            break;
        case 620:
            coverImageName = @"bookcover_620_ideapadmini.png";
            break;
        case 621:
            coverImageName = @"bookcover_fpceo2016.png";
            break;
        case 622:
            coverImageName = @"bookcover_fpcompact2016.png";
            break;
        case 623:
            coverImageName = @"bookcover_fpcasual2016_32.png";
            break;
        case 624:
            coverImageName = @"bookcover_fpcasual2016_25.png";
            break;
        case 625:
            coverImageName = @"bookcover_nblankplanner_625.png";
            break;
        case 114:
            coverImageName = @"bookcover_oreestylographjournal.png";
            break;
        case 700:
            coverImageName = @"bookcover_moleskine_neolab.png";
            break;
        case 701:
            coverImageName = @"bookcover_moleskine_mbook_papertablet1.png";
            break;
        case 702:
            coverImageName = @"bookcover_moleskine_mbook_papertablet2.png";
            break;
        case 800:
            coverImageName = @"bookcover_JungGi.png";
            break;
        case 898:
            coverImageName = @"bookcover_sosodiary.png";
            break;
        case 899:
            coverImageName = @"book cover_D07.png";
            break;

        default:
            //coverImageName = [NSString stringWithFormat:@"book cover_D%02d.png",(int)type % 920];
            //coverImageName = @"book cover_unknown.png";
            break;
    }
    
    if(notebookId >= kNOTEBOOK_ID_START_DIGITAL)
        coverImageName = [NSString stringWithFormat:@"book cover_D%02d.png",((int)notebookId % NUM_OF_AVAILABLE_DIGITAL_NOTE_IMAGE +1)];
    
    return coverImageName;
}




+ (NSImage *) getCoverResourceImage:(NSUInteger)notebookId
{
    NSImage *coverImage = [NSImage imageNamed:[NJCoverManager getCoverResourceImageName:notebookId]];
    
    if (isEmpty(coverImage)) {
        NSUInteger section, owner;
        [NPPaperManager section:&section owner:&owner fromNotebookId:notebookId];
        NSString *keyNameDB = [NPPaperManager keyNameForNotebookId:notebookId section:section owner:owner];
        
        if([[NPPaperManager sharedInstance] hasPaperInfoForKeyName:keyNameDB]){
            coverImage = [[NPPaperManager sharedInstance] getDefaultCoverImageForNotebookId:notebookId section:section owner:owner];
        } else {
            coverImage = [NSImage imageNamed:@"book cover_unknown.png"];
        }
    }
    return coverImage;
}



@end
