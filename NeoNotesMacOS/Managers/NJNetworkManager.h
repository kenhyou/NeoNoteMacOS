//
//  NJNetworkManager.h
//  NeoJournal
//
//  Created by NamSSan on 13/05/2014.
//  Copyright (c) 2014 Neolab. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface NJNetworkManager : AFHTTPSessionManager


+ (instancetype)sharedManager;


+ (void)requestOpenWeatherWithSuccessBlock:(void (^)(NSDictionary *, NSURLSessionDataTask *))sblock withFailBlock:(void (^)(NSURLSessionDataTask *, NSError *))fblock;
+ (void)checkNewFirmware:(void (^)(NSString *location, NSString *serverVer))sblock withFailBlock:(void (^)(NSURLSessionDataTask *, NSError *))fblock;


@end
