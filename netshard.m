//
//  netshard.m
//  yiyuangou
//
//  Created by xiaoyu on 14/11/21.
//  Copyright (c) 2014年 xiaoyu. All rights reserved.
//

#import "netshard.h"

@implementation netshard

@synthesize semaphore,progressBlock,submitBlock;

+ (instancetype)sharedInstance{
    
    static netshard *_sharedInstance;
    
    static dispatch_once_t token;
    
    dispatch_once(&token,^{
        _sharedInstance = [[netshard alloc] init];
        _sharedInstance.semaphore =  dispatch_semaphore_create(1);
    });
    
    return _sharedInstance;
}
 
- (void)refresh:(NSURL *)url  backCall:(queryBlock)block{
    
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            
            id dic = [super queryNet:url];
            
            if (dic) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    block(dic,YES);
                });
                
            }else{
                block(dic,NO);
            }
            
            dispatch_semaphore_signal(semaphore);
            
        });
    
}

- (void)query:(NSURL *)url backCall:(queryBlock)block{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            
            if ([defaults objectForKey:[url resourceSpecifier]]) {
                
                block([defaults objectForKey:[url resourceSpecifier]],YES);
                
            }else{
            
                id dic = [super queryNet:url];
                
                if (dic) {
                    
                    [defaults setObject:dic forKey:[url resourceSpecifier]];
                    
                    [defaults synchronize];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        block(dic,YES);
                    });
                    
                }else{
                    block(dic,NO);
                }
            }
            
            dispatch_semaphore_signal(semaphore);
            
        });
    
}

- (void)POSTquery:(NSURL *)url opt:(NSString *)opt backCall:(queryBlock)block{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
        id dic = [super NetDataPost:url opt:opt];
        
        if (dic) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                block(dic,YES);
            });
            
        }else{
            block(dic,NO);
        }
        
        dispatch_semaphore_signal(semaphore);
        
    });

}

- (void)POSTpic:(NSURL *)url opt:(NSDictionary *)opt ProgressVal:(Progress)progress backCall:(SubmitBlock)block{
 
    progressBlock = progress;
    
    submitBlock = block;
    
    [super NetPostPic:url val:opt delegate:self];

}

- (void)connection:(NSURLConnection *)connection didWriteData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long) expectedTotalBytes{
    
    submitBlock(YES);
    
}

- (void)connectionDidFinishDownloading:(NSURLConnection *)connection destinationURL:(NSURL *) destinationURL{

    NSLog(@"asdasdadsasd");
    
    progressBlock = nil;
    
    submitBlock = nil;

}

- (void)connection:(NSURLConnection *)connection   didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite{
    
     progressBlock(totalBytesWritten,totalBytesExpectedToWrite);
    
}




@end
