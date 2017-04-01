//
//  NJSettingStore.h
//  NeoJournal
//
//  Created by NamSSan on 13/08/2014.
//  Copyright (c) 2014 Neolab. All rights reserved.
//

#import <Foundation/Foundation.h>


#define kData_Patch             @"kData_Patch_0915"
#define vData_Patch             NO

#define kData_Transfer             @"kData_Transfer_1111"
#define vData_Transfer             YES

#define kNewPaperInfo_Install             @"kNewPaperInfo_Install_201602"
#define vNewPaperInfo_Install             YES

#define kIsEngineeringModeEnabled           @"kIsEngineeringModeEnabled_2"
#define vIsEngineeringModeEnabled           NO
#define kIsEngineeringModeOn                @"kIsEngineeringModeOn"
#define vIsEngineeringModeOn                YES

#define kSetting_Locale_Locale              @"kSetting_Locale"
#define vSetting_Locale_English             0
#define vSetting_Locale_Korean              1
#define vSetting_Locale_Chinese             2
#define vSetting_Locale_Japanese            3


#define kSetting_Evernote_Sync_Enabled      @"kSetting_Evernote_Sync_Enabled"
#define vSetting_Evernote_Sync_Enabled_Default  NO

#define kSetting_GD_Sync_Enabled      @"kSetting_GD_Sync_Enabled"
#define vSetting_GD_Sync_Enabled_Default      NO

#define kSetting_GD_Export_Enabled      @"kSetting_GD_Export_Enabled"
#define vSetting_GD_Export_Enabled_Default      NO

#define kSetting_Franklin_Enabled           @"kSetting_Franklin_Enabled"
#define vSetting_Franklin_Enabled_Default   YES


#define kSetting_Alarm_Time                 @"kSetting_Alarm_Time"
//#define vSetting_Alarm_Time         14

#define kSetting_Last_Used_Notebook_Uuid    @"kSetting_Last_Used_Notebook_Uuid"


#define kSetting_Registered_Email               @"kSetting_Registered_Email"
#define kSetting_Registered_Email_CC            @"kSetting_Registered_Email_CC"
#define kSetting_Notice_Last_News_Check_Date    @"kSetting_Notice_Last_News_Check_Date"


// pen connection
#define kSetting_Pen_Password_Setup_Ask     @"kSetting_Pen_Password_Setup_Ask"
#define vSetting_Pen_Password_Setup_Ask     YES
#define kSetting_Pen_Thickness              @"kSetting_Storke_Thickness"
#define vSetting_Pen_Thickness_Default      0
#define kSetting_Pen_Color                  @"kSetting_Pen_Color"
#define vSetting_Pen_Color_Default          0x000000
#define kSetting_Pen_Persistence            @"kSetting_Pen_Persistence"
#define vSetting_Pen_Persistence            YES

#define kSetting_First_ColorPicker            @"kSetting_First_ColorPicker"
#define vSetting_First_ColorPicker            YES

// Popup Notices
#define kSetting_PopupNotice_NoteBox     @"kSetting_PopupNotice_NoteBox"
#define vSetting_PopupNotice_NoteBox     YES

// Popup Notice Guide
#define kSetting_PopupNotice_Guide       @"kSetting_PopupNotice_Guide"
#define vSetting_PopupNotice_Guide       NO


// Share Options
#define kSetting_ShareOptions_BG             @"kSetting_ShareOptions_BG"
#define vSetting_ShareOptions_BG             0


// GDExport
#define kGDExport_Wifi_Only             @"kGDExport_Wifi_Only"
#define vGDExport_Wifi_Only             NO

// AutoSaveOption
#define kAutoSaveOption_Wifi_Only       @"kAutoSaveOption_Wifi_Only"
#define vAutoSaveOption_Wifi_Only       NO

//Custom Color
#define kColorPicker_Palette_Color        @"kColorPicker_Palette_Color"

//Color Picker Button Index
#define kColorPicker_Btn_Index              @"kColorPicker_Btn_Index"
#define vColorPicker_Btn_Index_Default      9



// Transcribe No confirm
#define kTranscribe_No_Highlight_Confirm        @"kTranscribe_No_Highlight_Confirm"
#define vTranscribe_No_Highlight_Confirm        NO
#define kEditVCpenDisconnectionConfirm          @"kEditVCpenDisconnectionConfirm"
#define vEditVCpenDisconnectionConfirm          NO
#define kFKAlarmChanageConfirm                  @"kFKAlarmChanageConfirm"
#define vFKAlarmChanageConfirm                  NO


// Guides
#define kGDExport_Guide_Show            @"kGDExport_Guide_Show"
#define vGDExport_Guide_Show            YES
#define kGDExport_Guide_Show_InMain     @"kGDExport_Guide_Show_InMain"
#define vGDExport_Guide_Show_InMain     YES
#define kGuide_Edit_Show_InMain         @"kGuide_Edit_Show_InMain"
#define vGuide_Edit_Show_InMain         YES


// Tutorials
#define kTut_Edit_Show                  @"kTut_Edit_Show"
#define vTut_Edit_Show                  YES
#define kTut_Page_Show                  @"kTut_Page_Show"
#define vTut_Page_Show                  YES

#define kSetting_Is_Pen_Password_Setup     @"kSetting_Is_Pen_Password_Setup"
#define vSetting_Is_Pen_Password_Setup     NO

#define kSetting_Pen_FWVersion               @"kSetting_Pen_FWVersion"

#define kSetting_Location_Country            @"kSetting_Location_Country"


@interface NJSettingStore : NSObject

@property (nonatomic) BOOL shouldDataPatch;
@property (nonatomic) BOOL shouldDataTransfer;
@property (nonatomic) BOOL newPaperInstall;
@property (nonatomic) BOOL isEngineeringModeEnabled;
@property (nonatomic) BOOL isEngineeringModeOn;
@property (nonatomic) BOOL penSettingPersistence;
@property (nonatomic) BOOL firstColorPickerEntry;
@property (nonatomic, strong) NSColor *penColor;
@property (nonatomic) NSUInteger penThickness;
@property (nonatomic, strong) NSColor *penColor2;
@property (nonatomic) NSUInteger penThickness2;
@property (nonatomic) BOOL evernoteSyncEnabled;
@property (nonatomic) BOOL GDSyncEnabled;
@property (nonatomic) BOOL GDExportEnabled;
@property (nonatomic) NSUInteger shareWithBGOption;   // 0~2 --> 0: with pdf bg / 1: white / 2: transparent
@property (nonatomic) BOOL franklinEnabled;
@property (nonatomic) NSDate *alarmTime;
@property (nonatomic, strong) NSString *lastUsedNotebookUuid;
@property (nonatomic, strong) NSString *registeredEmail;
@property (nonatomic, strong) NSString *registeredEmailCC;
@property (nonatomic, strong) NSDate *lastNewsCheckedDate;


@property (nonatomic) BOOL transcribeNoHighlightConfirm;
@property (nonatomic) BOOL editVCpenDisconnectionConfirm;
@property (nonatomic) BOOL franklinAlarmChangeConfirm;
@property (nonatomic) BOOL askPasswdSetup;


// Popup Notices
@property (nonatomic) BOOL popupNoticeNoteBox;

// Popup Notice Guide
@property (nonatomic) BOOL popupNoticeGuide;


// GD Export
@property (nonatomic) BOOL gdGuideViewShow;
@property (nonatomic) BOOL gdGuideViewShowInMain;
@property (nonatomic) BOOL gdWifiOnly;

// Auto Save Option
@property (nonatomic) BOOL autoSaveWifiOnly;

// Guides
@property (nonatomic) BOOL guidEditShowInMain;


// Tutorials
@property (nonatomic) BOOL tutEditShow;
@property (nonatomic) BOOL tutPageShow;

@property (nonatomic) BOOL isPasswdSetup;
@property (nonatomic, strong) NSString *penFWVersion;
@property (nonatomic, strong) NSString *locationCountry;


+ (NJSettingStore *)sharedStore;



@end
