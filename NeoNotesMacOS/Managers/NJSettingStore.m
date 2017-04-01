//
//  NJSettingStore.m
//  NeoJournal
//
//  Created by NamSSan on 13/08/2014.
//  Copyright (c) 2014 Neolab. All rights reserved.
//

#import "NJSettingStore.h"
#import "NPPaperManager.h"
#import "NJNetworkManager.h"


@implementation NJSettingStore



+ (NJSettingStore *)sharedStore
{
    static NJSettingStore *sharedStore = nil;
    
    @synchronized(self) {
        
        if(!sharedStore) {
            sharedStore = [[super allocWithZone:nil] init];
        }
    }
    
    return sharedStore;
}




- (id)init
{
    self = [super init];
    
    if(self) {
        
        //initially read default setting
        [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Defaults" ofType:@"plist"]]];
        _penThickness2 = vSetting_Pen_Thickness_Default;
        _penColor2 = NSColorFromRGB(vSetting_Pen_Color_Default);
    }
    
    return self;
}


- (NSDate *)alarmTime
{
    if(![[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:kSetting_Alarm_Time]){
        
        //NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *comps = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:[NSDate date]];
        comps.minute = 0;
        comps.hour = 8; // am 8:00 is default time
        NSDate * alarmTime = [calendar dateFromComponents:comps];
        
        return alarmTime;
    }
    
    return [[NSUserDefaults standardUserDefaults] objectForKey:kSetting_Alarm_Time];
}



- (void)setShouldDataPatch:(BOOL)shouldDataPatch
{
    
    [[NSUserDefaults standardUserDefaults] setBool:shouldDataPatch forKey:kData_Patch];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)shouldDataPatch
{
    if(![[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:kData_Patch])
        return vData_Patch;
    
    return [[NSUserDefaults standardUserDefaults] boolForKey:kData_Patch];
}
- (void)setShouldDataTransfer:(BOOL)shouldDataTransfer
{
    
    [[NSUserDefaults standardUserDefaults] setBool:shouldDataTransfer forKey:kData_Transfer];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)shouldDataTransfer
{
    if(![[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:kData_Transfer])
        return vData_Transfer;
    
    return [[NSUserDefaults standardUserDefaults] boolForKey:kData_Transfer];
}

- (void)setNewPaperInstall:(BOOL)newPaperInstall
{
    [[NSUserDefaults standardUserDefaults] setBool:newPaperInstall forKey:kNewPaperInfo_Install];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (BOOL)newPaperInstall
{
    if(![[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:kNewPaperInfo_Install])
        return vNewPaperInfo_Install;
    
    return [[NSUserDefaults standardUserDefaults] boolForKey:kNewPaperInfo_Install];
}

- (void)setIsEngineeringModeEnabled:(BOOL)isEngineeringModeEnabled
{
    [NPPaperManager sharedInstance].isDeveloperMode = (isEngineeringModeEnabled && self.isEngineeringModeOn);
    [[NSUserDefaults standardUserDefaults] setBool:isEngineeringModeEnabled forKey:kIsEngineeringModeEnabled];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (BOOL)isEngineeringModeEnabled
{
    if(![[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:kIsEngineeringModeEnabled])
        return vIsEngineeringModeEnabled;
    
    return [[NSUserDefaults standardUserDefaults] boolForKey:kIsEngineeringModeEnabled];
}
- (void)setIsEngineeringModeOn:(BOOL)isEngineeringModeOn
{
    [NPPaperManager sharedInstance].isDeveloperMode = (self.isEngineeringModeEnabled && isEngineeringModeOn);
    [[NSUserDefaults standardUserDefaults] setBool:isEngineeringModeOn forKey:kIsEngineeringModeOn];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (BOOL)isEngineeringModeOn
{
    if(![[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:kIsEngineeringModeOn])
        return vIsEngineeringModeOn;
    
    return [[NSUserDefaults standardUserDefaults] boolForKey:kIsEngineeringModeOn];
}
- (void)setAlarmTime:(NSDate *)alarmTime
{
    
    [[NSUserDefaults standardUserDefaults] setObject:alarmTime forKey:kSetting_Alarm_Time];
}
- (NSDate *)lastNewsCheckedDate
{
    if(![[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:kSetting_Notice_Last_News_Check_Date]){
        //@"yyyy-MM-dd HH:mm:ss"
        return [NJUtilities convertDateFromString:@"1979-02-23 03:33:33"];
    }
    //return [MyFunctions convertDateFromString:@"2015-02-13 03:33:33"];
    return [[NSUserDefaults standardUserDefaults] objectForKey:kSetting_Notice_Last_News_Check_Date];
}
- (void)setLastNewsCheckedDate:(NSDate *)lastNewsCheckedDate
{
    [[NSUserDefaults standardUserDefaults] setObject:lastNewsCheckedDate forKey:kSetting_Notice_Last_News_Check_Date];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)evernoteSyncEnabled
{
    if(![[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:kSetting_Evernote_Sync_Enabled]){
        
        return vSetting_Evernote_Sync_Enabled_Default;
    }
    
    return [[NSUserDefaults standardUserDefaults] boolForKey:kSetting_Evernote_Sync_Enabled];
}

- (void)setEvernoteSyncEnabled:(BOOL)evernoteSyncEnabled
{
}

- (BOOL)GDSyncEnabled
{
    if(![[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:kSetting_GD_Sync_Enabled]){
        
        return vSetting_GD_Sync_Enabled_Default;
    }
    
    return [[NSUserDefaults standardUserDefaults] boolForKey:kSetting_GD_Sync_Enabled];
}

- (void)setGDSyncEnabled:(BOOL)GDSyncEnabled
{
}

- (BOOL)GDExportEnabled
{
    if(![[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:kSetting_GD_Export_Enabled]){
        
        return vSetting_GD_Export_Enabled_Default;
    }
    
    return [[NSUserDefaults standardUserDefaults] boolForKey:kSetting_GD_Export_Enabled];
}

- (void)setGDExportEnabled:(BOOL)GDExportEnabled
{
    
    [[NSUserDefaults standardUserDefaults] setBool:GDExportEnabled forKey:kSetting_GD_Export_Enabled];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)franklinEnabled
{
    if(![[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:kSetting_Franklin_Enabled]){
        
        return vSetting_Franklin_Enabled_Default;
    }
    
    return [[NSUserDefaults standardUserDefaults] boolForKey:kSetting_Franklin_Enabled];
}

- (void)setFranklinEnabled:(BOOL)franklinEnabled
{
    
    [[NSUserDefaults standardUserDefaults] setBool:franklinEnabled forKey:kSetting_Franklin_Enabled];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (NSString *)lastUsedNotebookUuid
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kSetting_Last_Used_Notebook_Uuid];
}
- (void)setLastUsedNotebookUuid:(NSString *)lastUsedNotebookUuid
{
    [[NSUserDefaults standardUserDefaults] setObject:lastUsedNotebookUuid forKey:kSetting_Last_Used_Notebook_Uuid];
}



- (NSString *)registeredEmail
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kSetting_Registered_Email];
}
- (void)setRegisteredEmail:(NSString *)registeredEmail
{
    [[NSUserDefaults standardUserDefaults] setObject:registeredEmail forKey:kSetting_Registered_Email];
}
- (NSString *)registeredEmailCC
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kSetting_Registered_Email_CC];
}
- (void)setRegisteredEmailCC:(NSString *)registeredEmail
{
    [[NSUserDefaults standardUserDefaults] setObject:registeredEmail forKey:kSetting_Registered_Email_CC];
}



- (BOOL)askPasswdSetup
{
    if(![[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:kSetting_Pen_Password_Setup_Ask])
        return vSetting_Pen_Password_Setup_Ask;
        
    return [[NSUserDefaults standardUserDefaults] boolForKey:kSetting_Pen_Password_Setup_Ask];
}
- (void)setAskPasswdSetup:(BOOL)askPasswdSetup
{
    [[NSUserDefaults standardUserDefaults] setBool:askPasswdSetup forKey:kSetting_Pen_Password_Setup_Ask];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)setTranscribeNoHighlightConfirm:(BOOL)transcribeNoHighlightConfirm
{
    
    [[NSUserDefaults standardUserDefaults] setBool:transcribeNoHighlightConfirm forKey:kTranscribe_No_Highlight_Confirm];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)transcribeNoHighlightConfirm
{
    if(![[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:kTranscribe_No_Highlight_Confirm])
        return vTranscribe_No_Highlight_Confirm;
    
    return [[NSUserDefaults standardUserDefaults] boolForKey:kTranscribe_No_Highlight_Confirm];
}
- (void)setEditVCpenDisconnectionConfirm:(BOOL)editVCpenDisconnectionConfirm
{
    
    [[NSUserDefaults standardUserDefaults] setBool:editVCpenDisconnectionConfirm forKey:kEditVCpenDisconnectionConfirm];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (BOOL)editVCpenDisconnectionConfirm
{
    if(![[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:kEditVCpenDisconnectionConfirm])
        return vEditVCpenDisconnectionConfirm;
    
    return [[NSUserDefaults standardUserDefaults] boolForKey:kEditVCpenDisconnectionConfirm];
}
- (void)setFranklinAlarmChangeConfirm:(BOOL)franklinAlarmChangeConfirm
{
    
    [[NSUserDefaults standardUserDefaults] setBool:franklinAlarmChangeConfirm forKey:kFKAlarmChanageConfirm];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (BOOL)franklinAlarmChangeConfirm
{
    if(![[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:kFKAlarmChanageConfirm])
        return vFKAlarmChanageConfirm;
    
    return [[NSUserDefaults standardUserDefaults] boolForKey:kFKAlarmChanageConfirm];
}



- (BOOL)penSettingPersistence
{
    
    if(![[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:kSetting_Pen_Persistence])
        return vSetting_Pen_Persistence;
    
    return [[NSUserDefaults standardUserDefaults] boolForKey:kSetting_Pen_Persistence];
}
- (void)setPenSettingPersistence:(BOOL)penSettingPersistence
{
    if(!penSettingPersistence) {
        
        if([NJPenCommManager sharedInstance].isPenConnected) {
            _penColor2 = self.penColor;
            _penThickness2 = self.penThickness;
        } else {
            self.penColor = NSColorFromRGB(vSetting_Pen_Color_Default);
            self.penThickness = vSetting_Pen_Thickness_Default;
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:penSettingPersistence forKey:kSetting_Pen_Persistence];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // transfer colors & thickness
    if(penSettingPersistence) {
        // tanfer from non-persistence to persistence
        self.penColor = _penColor2;
        self.penThickness = _penThickness2;
    }
    
}

- (BOOL)firstColorPickerEntry
{
    
    if(![[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:kSetting_First_ColorPicker])
        return vSetting_First_ColorPicker;
    
    return [[NSUserDefaults standardUserDefaults] boolForKey:kSetting_First_ColorPicker];
}
- (void)setFirstColorPickerEntry:(BOOL)firstColorPickerEntry
{
    
    [[NSUserDefaults standardUserDefaults] setBool:firstColorPickerEntry forKey:kSetting_First_ColorPicker];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (NSUInteger)penThickness
{
    if(!self.penSettingPersistence)
        return _penThickness2;
    
     if(![[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:kSetting_Pen_Thickness]){
         return vSetting_Pen_Thickness_Default;
     }
     return [[NSUserDefaults standardUserDefaults] integerForKey:kSetting_Pen_Thickness];
}
- (void)setPenThickness:(NSUInteger)penThickness
{
    if(!self.penSettingPersistence) {
        _penThickness2 = penThickness;
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setInteger:penThickness forKey:kSetting_Pen_Thickness];
    
}
- (NSColor *)penColor
{
    if(!self.penSettingPersistence)
        return _penColor2;
    
     if(![[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:kSetting_Pen_Color]){
     
     return NSColorFromRGB(vSetting_Pen_Color_Default);
     }
     
     //return [[NSUserDefaults standardUserDefaults] objectForKey:kSetting_Pen_Color];
     NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:kSetting_Pen_Color];
     return [NSKeyedUnarchiver unarchiveObjectWithData:colorData];

}
- (void)setPenColor:(NSColor *)penColor
{
    if(!self.penSettingPersistence) {
        _penColor2 = penColor;
        return;
    }
     //[[NSUserDefaults standardUserDefaults] setObject:penColor forKey:kSetting_Pen_Color];
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:penColor];
    [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:kSetting_Pen_Color];
    
}


- (BOOL)popupNoticeNoteBox
{
    if(![[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:kSetting_PopupNotice_NoteBox])
        return vSetting_PopupNotice_NoteBox;
    
    return [[NSUserDefaults standardUserDefaults] boolForKey:kSetting_PopupNotice_NoteBox];
}
- (void)setPopupNoticeNoteBox:(BOOL)popupNoticeNoteBox
{
    [[NSUserDefaults standardUserDefaults] setBool:popupNoticeNoteBox forKey:kSetting_PopupNotice_NoteBox];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)popupNoticeGuide
{
    if(![[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:kSetting_PopupNotice_Guide])
        return vSetting_PopupNotice_Guide;
    
    return [[NSUserDefaults standardUserDefaults] boolForKey:kSetting_PopupNotice_Guide];
}
- (void)setPopupNoticeGuide:(BOOL)popupNoticeGuide
{
    [[NSUserDefaults standardUserDefaults] setBool:popupNoticeGuide forKey:kSetting_PopupNotice_Guide];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (NSUInteger)shareWithBGOption
{
    if(![[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:kSetting_ShareOptions_BG])
        return vSetting_ShareOptions_BG;
    
    return [[NSUserDefaults standardUserDefaults] integerForKey:kSetting_ShareOptions_BG];
}
- (void)setShareWithBGOption:(NSUInteger)shareWithBGOption
{
    [[NSUserDefaults standardUserDefaults] setInteger:shareWithBGOption forKey:kSetting_ShareOptions_BG];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (BOOL)gdGuideViewShow
{
    if(![[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:kGDExport_Guide_Show])
        return vGDExport_Guide_Show;
    return [[NSUserDefaults standardUserDefaults] boolForKey:kGDExport_Guide_Show];
}
- (void)setGdGuideViewShow:(BOOL)gdGuideViewShow
{
    [[NSUserDefaults standardUserDefaults] setBool:gdGuideViewShow forKey:kGDExport_Guide_Show];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (BOOL)gdGuideViewShowInMain
{
    if(![[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:kGDExport_Guide_Show_InMain])
        return vGDExport_Guide_Show_InMain;
    return [[NSUserDefaults standardUserDefaults] boolForKey:kGDExport_Guide_Show_InMain];
}
- (void)setGdGuideViewShowInMain:(BOOL)gdGuideViewShowInMain
{
    [[NSUserDefaults standardUserDefaults] setBool:gdGuideViewShowInMain forKey:kGDExport_Guide_Show_InMain];
    [[NSUserDefaults standardUserDefaults] synchronize];
}



- (BOOL)gdWifiOnly
{
    if(![[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:kGDExport_Wifi_Only])
        return vGDExport_Wifi_Only;
    return [[NSUserDefaults standardUserDefaults] boolForKey:kGDExport_Wifi_Only];
}

- (void)setGdWifiOnly:(BOOL)gdWifiOnly
{
    [[NSUserDefaults standardUserDefaults] setBool:gdWifiOnly forKey:kGDExport_Wifi_Only];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)autoSaveWifiOnly
{
    if(![[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:kAutoSaveOption_Wifi_Only])
        return vAutoSaveOption_Wifi_Only;
    return [[NSUserDefaults standardUserDefaults] boolForKey:kAutoSaveOption_Wifi_Only];
}

- (void)setAutoSaveWifiOnly:(BOOL)autoSaveWifiOnly
{
    [[NSUserDefaults standardUserDefaults] setBool:autoSaveWifiOnly forKey:kAutoSaveOption_Wifi_Only];
    [[NSUserDefaults standardUserDefaults] synchronize];
}




- (BOOL)guidEditShowInMain
{
    if(![[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:kGuide_Edit_Show_InMain])
        return vGuide_Edit_Show_InMain;
    return [[NSUserDefaults standardUserDefaults] boolForKey:kGuide_Edit_Show_InMain];
}
- (void)setGuidEditShowInMain:(BOOL)guidEditShowInMain
{
    [[NSUserDefaults standardUserDefaults] setBool:guidEditShowInMain forKey:kGuide_Edit_Show_InMain];
    [[NSUserDefaults standardUserDefaults] synchronize];
}





- (BOOL)tutEditShow
{
    if(![[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:kTut_Edit_Show])
        return vTut_Edit_Show;
    return [[NSUserDefaults standardUserDefaults] boolForKey:kTut_Edit_Show];
}
- (void)setTutEditShow:(BOOL)tutEditShow
{
    [[NSUserDefaults standardUserDefaults] setBool:tutEditShow forKey:kTut_Edit_Show];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)tutPageShow
{
    if(![[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:kTut_Page_Show])
        return vTut_Page_Show;
    return [[NSUserDefaults standardUserDefaults] boolForKey:kTut_Page_Show];
}
- (void)setTutPageShow:(BOOL)tutPageShow
{
    [[NSUserDefaults standardUserDefaults] setBool:tutPageShow forKey:kTut_Page_Show];
    [[NSUserDefaults standardUserDefaults] synchronize];
}




- (BOOL)isPasswdSetup
{
    if(![[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:kSetting_Is_Pen_Password_Setup])
        return vSetting_Is_Pen_Password_Setup;
    
    return [[NSUserDefaults standardUserDefaults] boolForKey:kSetting_Is_Pen_Password_Setup];
}
- (void)setIsPasswdSetup:(BOOL)passwdSetup
{
    [[NSUserDefaults standardUserDefaults] setBool:passwdSetup forKey:kSetting_Is_Pen_Password_Setup];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)penFWVersion
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kSetting_Pen_FWVersion];
}
- (void)setPenFWVersion:(NSString *)penFWVersion
{
    [[NSUserDefaults standardUserDefaults] setObject:penFWVersion forKey:kSetting_Pen_FWVersion];
}

- (NSString *)locationCountry
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kSetting_Location_Country];
}
- (void)setLocationCountry:(NSString *)locationCountry
{
    [[NSUserDefaults standardUserDefaults] setObject:locationCountry forKey:kSetting_Location_Country];
}

@end
