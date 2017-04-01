//
//  NJNetworkManager.m
//  NeoJournal
//
//  Created by NamSSan on 13/05/2014.
//  Copyright (c) 2014 Neolab. All rights reserved.
//

#import "NJNetworkManager.h"

NSString *kURL_OPENWEATHER =         @"http://api.openweathermap.org/data/2.5/weather?";
NSString *kAPI_KEY_OPENWEATHER =     @"a313ec0b889724d054763c96def6d284";
NSString *kURL_NEOLAB_FW =           @"http://one.neolab.kr/resource/fw";
NSString *kURL_NEOLAB_FW_JSON =      @"/f1xx_firmware.json";
NSString *kURL_NEOLAB_FW20 =         @"http://one.neolab.kr/resource/fw20";
NSString *kURL_NEOLAB_FW20_JSON =    @"/protocol2.0_firmware.json";
NSString *kURL_NEOLAB_FW20_F50_JSON =    @"/protocol2.0_firmware_f50.json";


@implementation NJNetworkManager


+ (instancetype)sharedManager
{
    static NJNetworkManager *_sharedManager = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLCache *cache = [[NSURLCache alloc] initWithMemoryCapacity:10 * 1024 * 1024
                                                          diskCapacity:50 * 1024 * 1024
                                                              diskPath:nil];
        [sessionConfiguration setURLCache:cache];
        sessionConfiguration.requestCachePolicy = NSURLRequestReturnCacheDataElseLoad;
        
        _sharedManager = [[NJNetworkManager alloc] initWithBaseURL:[NSURL URLWithString:kURL_NEOLAB_FW] sessionConfiguration:sessionConfiguration];
        
        _sharedManager.responseSerializer = [AFJSONResponseSerializer serializer];
        //_sharedManager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    });
    
    return _sharedManager;
}




+ (void)requestOpenWeatherWithSuccessBlock:(void (^)(NSDictionary *, NSURLSessionDataTask *))sblock withFailBlock:(void (^)(NSURLSessionDataTask *, NSError *))fblock
{

}


+ (void)checkNewFirmware:(void (^)(NSString *location, NSString *serverVer))sblock withFailBlock:(void (^)(NSURLSessionDataTask *, NSError *))fblock
{
    [[NJNetworkManager sharedManager].requestSerializer setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    
    NSString *url;
    if ([NJPenCommManager sharedInstance].isPenSDK2){
        NSString *name = [NJPenCommManager sharedInstance].deviceName;
        if ([name isEqualToString:@"NWP-F50"]) {
            url = [NSString stringWithFormat:@"%@%@",kURL_NEOLAB_FW20,kURL_NEOLAB_FW20_F50_JSON];
        }else{
            url = [NSString stringWithFormat:@"%@%@",kURL_NEOLAB_FW20,kURL_NEOLAB_FW20_JSON];
        }
    }else{
        url = [NSString stringWithFormat:@"%@%@",kURL_NEOLAB_FW,kURL_NEOLAB_FW_JSON];
    }
    
    [[NJNetworkManager sharedManager] GET:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSLog(@"FW SERVER RESPONSE ---> %@",responseObject);
        
        NSDictionary *json = responseObject;
        
        NSString *loc = [json objectForKey:@"location"];
        NSString *ver = [json objectForKey:@"version"];
        
        NSString *fileName = [[loc lastPathComponent] stringByDeletingPathExtension];
        
        NSArray *splitStringArr = [fileName componentsSeparatedByString:@"_"];
        
        if ([splitStringArr count] > 1) {
            NSString *splitString = [splitStringArr objectAtIndex:1];
            [NJPenCommManager sharedInstance].fwVerServer = splitString;
            
        }
        
        sblock(loc,ver);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if(fblock)
            fblock(task,error);
        
    }];
    
    
    
}

+ (void)deleteCookies
{
    
    // delete cookies to renew ssid when login next time
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:kURL_NEOLAB_FW]];
    
    for (NSHTTPCookie *cookie in cookies)
    {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
}


/*
- (void)requestJASONResponseWithParams:(NSDictionary *)params withSuccessBlock:(void (^)(NSDictionary *, NSURLSessionDataTask *))sblock withFailBlock:(void (^)(NSURLSessionDataTask *, NSError *))fblock withPath:(NSString *)spath
{
    if(isEmpty(spath))
        spath = STR_SERVER;
    
    
    
    [[NJNetworkManager sharedManager] POST:spath parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //NSError *error;
        
        NSDictionary *json = responseObject;
        //NSLog(@"Response --> %@",responseObject);
        sblock(json,task);
        
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        
        if(httpResponse.statusCode == 800 ) {
            
            // login timout so we reset loginStatus == FALSE
            NSLog(@"session timeout received");
            
            //[LogInService sharedService].hasAlreadyLoggedIn = NO;
            //[NSPClientStore deleteCookies];
            //[[LogInService sharedService] startService];
            return;
            
        }
        
        if(httpResponse.statusCode == 200) {
            
            // this is OK response therefore just return;
            return;
        }
        
        
        if(httpResponse.statusCode == 403) {
            
            // this is OK response therefore just return;
            //[LogInService sharedService].hasAlreadyLoggedIn = NO;
            //[NSPClientStore deleteCookies];
            NSLog(@"403 Forbbiden");
        }
        
        
        if(httpResponse.statusCode >= 600) {
            // this is user defined error
            // must be considered not just system error
            // so just return;
            fblock(task,error);
            return;
        }
        
        NSLog(@"Fatal Error: %@", error);
        
        fblock(task,error);
        
    }];
}






+ (void)deleteCookies
{
    
    // delete cookies to renew ssid when login next time
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:kBaseURLString]];
    
    for (NSHTTPCookie *cookie in cookies)
    {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
}



+ (void)printCookies
{

    NSHTTPCookie *cookie;
    
    for (cookie in [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies) {
        NSLog(@"%@=%@", cookie.name, cookie.value);
    }
    
    
    
}



+ (void)saveCookies
{
 
    NSHTTPCookie *cookie;
    
    for (cookie in [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies) {
        NSLog(@"%@=%@", cookie.name, cookie.value);
    }
    
    
    
}


+ (void)loadCookies
{
    
    NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData: [[NSUserDefaults standardUserDefaults] objectForKey: @"sessionCookies"]];
    
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    for (NSHTTPCookie *cookie in cookies){
        [cookieStorage setCookie: cookie];
    }
    
    NSHTTPCookie *cookie;
    
    for (cookie in cookieStorage.cookies) {
        NSLog(@"%@=%@", cookie.name, cookie.value);
    }
    
}
*/





@end
