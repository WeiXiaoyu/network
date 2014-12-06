//
//  HTTPnetwork.h
//  yiyuangou
//
//  Created by xiaoyu on 14/11/25.
//  Copyright (c) 2014年 xiaoyu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, HTTPnetworkType) {
    
    networkqueryerror,
    
    patherror,
    
    time_out
};

@interface HTTPnetwork : NSObject<NSURLConnectionDownloadDelegate,NSURLConnectionDelegate,NSURLConnectionDataDelegate>

+ (instancetype)sharedInstance;

+ (NSString *)replaceUnicode:(NSString *)unicodeStr;

- (id)NetDataPost:(NSURL *)url opt:(NSString *)opt;

- (id)queryNet:(NSURL *)url;

- (void)NetPostPic:(NSURL *)url val:(NSDictionary *)params delegate:(id)delegate;

@property(nonatomic,assign) HTTPnetworkType state;

@end
