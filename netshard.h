//
//  netshard.h
//  yiyuangou
//
//  Created by xiaoyu on 14/11/21.
//  Copyright (c) 2014年 xiaoyu. All rights reserved.
//

#import "HTTPnetwork.h"

typedef void (^ refreshBlock)(NSDictionary *ret,BOOL success);
typedef void (^ queryBlock)(id ret,BOOL success);
typedef void (^ Progress)(long long totalBytes,long long totalBytesExpected);
typedef void (^ SubmitBlock)(BOOL success);

@interface netshard : HTTPnetwork

+ (instancetype)sharedInstance;

- (void)refresh:(NSURL *)url  backCall:(queryBlock)block;

- (void)query:(NSURL *)url backCall:(queryBlock)block;

- (void)POSTquery:(NSURL *)url opt:(NSString *)opt backCall:(queryBlock)block;

- (void)POSTpic:(NSURL *)url opt:(NSDictionary *)opt ProgressVal:(Progress)progress backCall:(SubmitBlock)block;


@property (nonatomic, copy) Progress progressBlock;
@property (nonatomic, copy) SubmitBlock submitBlock;

@property(nonatomic)dispatch_semaphore_t semaphore;

@end
