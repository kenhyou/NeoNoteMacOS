//
//  NJPenCommManager.h
//  NeoJournal
//
//  Copyright (c) 2014 Neolab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "NJPenCommParser.h"

#define PENCOMM_SERVICE_UUID           @"E20A39F4-73F5-4BC4-A12F-17D1AD07A961"
#define PENCOMM_READ_CHARACTERISTIC_UUID    @"08590F7E-DB05-467E-8757-72F6FAEB13D4"
#define PENCOMM_WRITE_CHARACTERISTIC_UUID    @"C0C0C0C0-DEAD-F154-1319-740381000000"
#define NOTIFY_MTU      20


@protocol NJPenCommManagerNewPeripheral
@optional
- (void) connectionResult:(BOOL)success;
@end

typedef NS_ENUM (NSInteger, NJPenCommManPenConnectionStatus) {
    NJPenCommManPenConnectionStatusNone,
    NJPenCommManPenConnectionStatusScanStarted,
    NJPenCommManPenConnectionStatusConnected,
    NJPenCommManPenConnectionStatusDisconnected
};
typedef enum {
    OFFLINE_DATA_RECEIVE_START,
    OFFLINE_DATA_RECEIVE_PROGRESSING,
    OFFLINE_DATA_RECEIVE_END,
    OFFLINE_DATA_RECEIVE_FAIL
} OFFLINE_DATA_STATUS;

typedef enum {
    FW_UPDATE_DATA_RECEIVE_START,
    FW_UPDATE_DATA_RECEIVE_PROGRESSING,
    FW_UPDATE_DATA_RECEIVE_END,
    FW_UPDATE_DATA_RECEIVE_FAIL
} FW_UPDATE_DATA_STATUS;

@protocol NJOfflineDataDelegate <NSObject>
- (void) offlineDataDidReceiveNoteList:(NSDictionary *)noteListDictionary;
//NISDK
//- (void) parseOfflineDots:(NSData *)penData startAt:(int)position withFileHeader:(OffLineDataFileHeaderStruct *)pFileHeader
//          andStrokeHeader:(OffLineDataStrokeHeaderStruct *)pStrokeHeader;
@optional
- (void) offlineDataReceiveStatus:(OFFLINE_DATA_STATUS)status percent:(float)percent;
- (void) offlineDataDidReceiveNoteListCount:(int)noteCount ForSectionOwnerId:(UInt32)sectionOwnerId;
- (void) offlineDataPathBeforeParsed:(NSString *)path;
@end

@protocol NJPenCalibrationDelegate <NSObject>
@optional
- (void) calibrationResult:(BOOL)result;
@end

@protocol NJFWUpdateDelegate <NSObject>
@optional
- (void) fwUpdateDataReceiveStatus:(FW_UPDATE_DATA_STATUS)status percent:(float)percent;
@end

//NISDK
//@protocol NJPenStatusDelegate <NSObject>
//- (void) penStatusData:(PenStateStruct *)data;
//@end

//@protocol NJPenPasswordDelegate <NSObject>
//- (void) penPasswordRequest:(PenPasswordRequestStruct *)data;
//@end

@class NJPenCommParser;

@interface NJPenCommManager : NSObject
@property (weak, nonatomic) id <NJPenCommManagerNewPeripheral> handleNewPeripheral;

@property (strong, nonatomic) CBCentralManager *centralManager;
//@property (strong, nonatomic) CBPeripheralManager *peripheralManager;
@property (strong, nonatomic) CBMutableCharacteristic   *readCharacteristic;
@property (strong, nonatomic) CBMutableCharacteristic   *writeCharacteristic;
@property (strong, nonatomic) NJPenCommParser *penCommParser;

@property (nonatomic, readwrite) NSInteger sendDataIndex;
@property (strong, nonatomic) NSData *dataToSend;
@property (nonatomic,readwrite) Boolean penDownFlag;
@property (nonatomic,readwrite) unsigned int previous_xy;
@property (strong, nonatomic) NSMutableArray *discoveredPeripherals;
@property (nonatomic) NSInteger selectedIndex;
@property (nonatomic) BOOL writeActiveState;
@property (nonatomic) BOOL cancelFWUpdate;
@property (nonatomic, readwrite) NJPenCommManPenConnectionStatus penConnectionStatus;
@property (nonatomic, readonly) BOOL isPenConnected;
@property (nonatomic, readonly) BOOL isMyscriptEnabled;
@property (nonatomic, readwrite) BOOL hasPenRegistered;
@property (nonatomic, readwrite) BOOL hasPenPassword;
@property (nonatomic, readonly) NSString *regUuid;
@property (nonatomic, readonly) NSString *penName;
@property (nonatomic) BOOL penDisconnectedByPen;
@property (nonatomic) BOOL cancelOfflineSync;
//NISDK
//@property (nonatomic) float startX;
//@property (nonatomic) float startY;
@property (nonatomic, readonly) BOOL isPenSDK2;
@property (nonatomic, readwrite) NSString *deviceName;
@property (nonatomic, readwrite) NSString *fwVerServer;
@property (strong, nonatomic) NSString *penConnectionStatusMsg;
@property (nonatomic) NSMutableArray *macArray;
@property (nonatomic) BOOL initialConnect;
@property (nonatomic) BOOL disConnectedBtnPressed;
@property (nonatomic) BOOL isNoEligiblePen;
@property (nonatomic) BOOL disconnectedByPenBtn;

+ (NJPenCommManager *) sharedInstance;
- (void)setPenCommParserStrokeHandler:(id<NJPenCommParserStrokeHandler>)strokeHandler;
- (void)setPenCommParserCommandHandler:(id<NJPenCommParserCommandHandler>)commandHandler;
- (void)setPenCommParserPasswordDelegate:(id<NJPenCommParserPasswordDelegate>)delegate;
- (void)setPenCommParserDocumentHandler:(id<NJCommParserDocumentHandler>)documentHandler;
//NISDK
//- (void) setPenCommParserStartDelegate:(id<NJPenCommParserStartDelegate>)delegate;
- (void)setOfflineDataDelegate:(id)offlineDataDelegate;
- (void)setPenCalibrationDelegate:(id)penCalibrationDelegate;
- (void)setFWUpdateDelegate:(id)fwUpdateDelegate;
//NISDK
//- (void) setPenStatusDelegate:(id)penStatusDelegate;
//- (void) setPenPasswordDelegate:(id)penPasswordDelegate;

- (NSInteger) btStart;
- (NSInteger) btStartForPeripheralsList;
- (void) btStop;
- (void)disConnect;
- (void) setPenState;
//- (void) setNoteIdList;
- (void)setNoteIdListFromPList;
- (void)setAllNoteIdList;

/* requestOfflineNote 
 * return : YES - request successful
 *          NO - already in progress
 */
- (BOOL)requestOfflineNote;
- (void)setPenStateWithRGB:(UInt32)color;
- (void)setPenThickness:(NSUInteger)thickness;
- (void)setPenStateWithPenPressure:(UInt16)penPressure;
- (void)setPenStateWithAutoPwrOffTime:(UInt16)autoPwrOff;
- (void)setPenStateAutoPower:(unsigned char)autoPower Sound:(unsigned char)sound;
//SDK2.0
- (void)setVersionInfo;
- (void)setRequestPenState;
//NISDK
- (void)setPenStateWithTimeTick;
- (unsigned char)getPenStateWithBatteryLevel;
- (unsigned char)getPenStateWithMemoryUsed;
- (NSString *)getFWVersion;
- (BOOL) requestOfflineDataWithOwnerId:(UInt32)ownerId noteId:(UInt32)noteId;
- (BOOL)getOfflineDataWithOwnerId:(UInt32)ownerId noteId:(UInt32)noteId;
- (void) setPassword:(NSString *)pinNumber;
- (void) changePasswordFrom:(NSString *)curNumber To:(NSString *)pinNumber;
- (void) setBTComparePassword:(NSString *)pinNumber;
- (void) sendUpdateFileInfoAtUrlToPen:(NSURL *)fileUrl;
- (NSString *)getOfflineSyncGAData;
//NISDK
//- (float) processPressure:(float)pressure;
- (void)requestWritingStartNotification;
- (void)cancelWritingStartNotification;
- (void)resetPenRegistration;
- (void)writeData:(NSData *)data to:(CBCharacteristic *)characteristic;
- (void)writePen2SetData:(NSData *)data;
- (void)writeSetPenState:(NSData *)data;
- (void)writeNoteIdList:(NSData *)data;
- (void)writeReadyExchangeData:(NSData *)data;
- (void)writePenPasswordResponseData:(NSData *)data;
- (void)writeSetPasswordData:(NSData *)data;
- (void)writeRequestOfflineFileList:(NSData *)data;
- (void)writeRequestOfflineFile:(NSData *)data;
- (void)writeRequestDelOfflineFile:(NSData *)data;
- (void)writeOfflineFileAck:(NSData *)data;
- (void)writeUpdateFileData:(NSData *)data;
- (void)writeUpdateFileInfo:(NSData *)data;

- (void)connectPeripheralAt:(NSInteger)index;
- (CBPeripheral *)peripheralAt:(NSInteger)index;
- (void) getPenBattLevelAndMemoryUsedSize:(void (^)(unsigned char remainedBattery, unsigned char usedMemory))completionBlock;

@end
