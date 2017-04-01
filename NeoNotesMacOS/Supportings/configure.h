//
//  configure.h
//  NeoJournal
//
//  Created by NamSSan on 12/05/2014.
//  Copyright (c) 2014 Neolab. All rights reserved.
//

#ifndef NeoJournal_configure_h
#define NeoJournal_configure_h


// Convenience function to show a UIAlertView
void ShowPopupMessage(NSString *title,NSString *msg);

static inline BOOL isEmpty(id thing) {
    return (thing == nil  || [thing isKindOfClass:[NSNull class]] || ([thing respondsToSelector:@selector(length)] && [(NSData *)thing length] == 0) || ([thing respondsToSelector:@selector(count)] && [(NSArray *)thing count] == 0) || ([thing isKindOfClass:[NSString class]] && ([thing isEqualToString:@"null"] || [thing isEqualToString:@"NULL"])));
}



#define NSLocalizedFormatString(fmt, ...) [NSString stringWithFormat:NSLocalizedString(fmt, nil), __VA_ARGS__]
#define NSColorFromRGB(rgbValue) [NSColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPOD ([[[UIDevice currentDevice] model] isEqualToString:@"iPod touch"])

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH <= 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)
#define IS_IPAD_PRO_1366 (IS_IPAD && SCREEN_MAX_LENGTH == 1366.0)


#define kNOTEBOOK_ID_START_DIGITAL  90000
#define kNOTEBOOK_ID_START_REAL     00000
#define kNOTEBOOK_MAX_PAGE_NUM      100000


#define kAlertViewPenRegDisconnectPen                       1000
#define kAlertViewSlidingMenu_OfflineSync                   2000
#define kAlertViewSlidingMenu_PasswordSetup                 2001
#define kAlertViewSlidingMenu_EvernoteManualSyncConfirm     2002
#define kAlertViewFWUpdateCancel                            0100
#define kNJNotebookVC_AlertViewPen              0200
#define kNJNotebookVC_AlertViewArchives         0201
#define kNJNotebookVC_AlertViewShare            0202
#define kNJNotebookVC_AlertViewDelete           0203
#define kAlertViewPenInfo                       0300
#define kAlertViewSettingEvernote               0400
#define kAlertViewSettingGoogleDrive            0410
#define kAlertViewSettingGoogleCalendar         0420
#define kAlertViewSettingFranklin               0500
#define kAlertViewArchiveVC_optionDelete        0601
#define kAlertViewArchiveVC_optionShare         0602
#define kAlertViewArchiveVC_optionUnarchive     0603
#define kAlertViewGDExport_errorOccur           0700
#define kAlertViewEditView_Confirm_Saving       0710
#define kAlertViewSetting_LngPack_removeLng     9400

#define STROKE_NUMBER_MAGNITUDE 4
// event log types
typedef enum {
    
    LOGTYPE_LASTSTROKE,
    LOGTYPE_WEATHER,
    LOGTYPE_SYNC,
    LOGTYPE_SHARE,
    LOGTYPE_CREATE,
    LOGTYPE_COPY,
    LOGTYPE_DELETE,
    LOGTYPE_ALARM,
    LOGTYPE_VM,
    LOGTYPE_DUMMY
    
} kEVENT_LOGTYPE;


// event action modes
typedef enum {
    
    ACTIONMODE_REALTIME,
    ACTIONMODE_OFFLINE,
    ACTIONMODE_OPERATION
    
} kEVENT_ACTIONMODE;



// event action modes
typedef enum {
    
    SHARE_FACEBOOK,
    SHARE_TWITTER,
    SHARE_KAKAO,
    SHARE_FLICKR,
    SHARE_EMAIL,
    SHARE_MESSAGE
    
} kEVENT_SHARE;


// event action modes
typedef enum {
    
    APP_STATUS_NORMAL,
    APP_STATUS_DELETING,
    APP_DB_TRANSFERING
    
} kNJAPP_STATUS;




static unsigned kCalUnits = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday;




/*
 static unsigned int const kEVENT_ACTION_LASTSTROKE =    0;
 static unsigned int const kEVENT_ACTION_WEATHER =       1;
 static unsigned int const kEVENT_ACTION_SYNC =          2;
 static unsigned int const kEVENT_ACTION_SHARE =         3;
 static unsigned int const kEVENT_ACTION_CREATE =        4;
 static unsigned int const kEVENT_ACTION_COPY =          5;
 static unsigned int const kEVENT_ACTION_DELETE =        6;
 
 
 static unsigned int const kEVENT_ACTIONMODE_REALTIME =     0;
 static unsigned int const kEVENT_ACTIONMODE_OFFLINE =      1;
 static unsigned int const kEVENT_ACTIONMODE_OPERATION =    2;
 */

static unsigned int const kWEATHER_CODE_SKYCLEAR =          0;
static unsigned int const kWEATHER_CODE_FEWCLOUDS =         1;
static unsigned int const kWEATHER_CODE_SCATTEREDCLOUDS =   2;
static unsigned int const kWEATHER_CODE_BROKENCLOUDS =      3;
static unsigned int const kWEATHER_CODE_SHOWERRAIN =        4;
static unsigned int const kWEATHER_CODE_RAIN =              5;
static unsigned int const kWEATHER_CODE_THUNDERSTORM =      6;
static unsigned int const kWEATHER_CODE_SNOW =              7;
static unsigned int const kWEATHER_CODE_MIST =              8;







//Notifications
//static NSString * const NJPageListRequestNotification = @"NJPageListRequestNotification";
//static NSString * const NJNotebookTitleChangedNotification = @"NJNotebookTitleChangedNotification";
//static NSString * const NJNotebookViewCancelArchivesNotification = @"NJNotebookViewCancelArchivesNotification";
//static NSString * const NJPageListTapGestureNotification = @"NJPageListTapGestureNotification";

static NSString * const NJSlidingOfflineSyncNotebookCompleteNotification = @"NJSlidingOfflineSyncNotebookCompleteNotification";

#endif
