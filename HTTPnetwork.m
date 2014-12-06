//
//  HTTPnetwork.m
//  yiyuangou
//
//  Created by xiaoyu on 14/11/25.
//  Copyright (c) 2014年 xiaoyu. All rights reserved.
//

#import "HTTPnetwork.h"

@implementation HTTPnetwork


+ (instancetype)sharedInstance{
    
    static HTTPnetwork *_sharedInstance;
    
    static dispatch_once_t token;
    
    dispatch_once(&token,^{ _sharedInstance = [[HTTPnetwork alloc] init];});
    
    return _sharedInstance;
}
 
+ (NSString *)replaceUnicode:(NSString *)unicodeStr
{
    NSString *tempStr1 = [unicodeStr stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@" \\\""];
    NSString *tempStr3 = [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString* returnStr = [NSPropertyListSerialization propertyListFromData:tempData
                                                           mutabilityOption:NSPropertyListImmutable
                                                                     format:NULL
                                                           errorDescription:NULL];
    return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n"withString:@"\n"];
}

- (id)NetDataPost:(NSURL *)url opt:(NSString *)opt{
     NSParameterAssert(url);
    
    //将NSSrring格式的参数转换格式为NSData，POST提交必须用NSData数据。
    NSData *postData = [opt dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    //计算POST提交数据的长度
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    NSLog(@"postLength=%@",postLength);
    //定义NSMutableURLRequest
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    //设置提交目的url
    [request setURL:url];
    //设置提交方式为 POST
    [request setHTTPMethod:@"POST"];
    //设置http-header:Content-Type
    //这里设置为 application/x-www-form-urlencoded ，如果设置为其它的，比如text/html;charset=utf-8，或者 text/html 等，都会出错。不知道什么原因。
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    //设置http-header:Content-Length
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    //设置需要post提交的内容
    [request setHTTPBody:postData];
    
    //定义
    NSHTTPURLResponse* urlResponse = nil;
    NSError *error = [[NSError alloc] init];
    //同步提交:POST提交并等待返回值（同步），返回值是NSData类型。
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
    //将NSData类型的返回值转换成NSString类型
    
    if (responseData == nil) {
        return  nil;
    }

    NSDictionary *weatherDic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
    
    return weatherDic;
    
    /*
    NSParameterAssert(url);
    
    NSError *error;
    
    NSMutableURLRequest  *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:2.0f];
    
    [request setHTTPMethod:@"POST"];
    
    NSData *data = [opt dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setHTTPBody:data];
    
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    if (received == nil) {
        return  nil;
    }
    
    NSDictionary *weatherDic = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingMutableLeaves error:&error];
    
    return weatherDic;
    */
}

- (id)queryNet:(NSURL *)url{
    
    NSParameterAssert(url);
    
    NSError *error;
    
    NSURLRequest *request  = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    
    if (error) {
        return nil;
    }
    
    id DataDic = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
    
    if (DataDic == nil) {
        return nil;
    }
    
    return DataDic;
}

- (void)NetPostPic:(NSURL *)url val:(NSDictionary *)params delegate:(id)delegate{
 
    
    NSString *TWITTERFON_FORM_BOUNDARY = @"AaB03x";

    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:10];

    NSString *MPboundary=[[NSString alloc]initWithFormat:@"--%@",TWITTERFON_FORM_BOUNDARY];

    NSString *endMPboundary=[[NSString alloc]initWithFormat:@"%@--",MPboundary];
 
    UIImage *img;
    
    if ([params objectForKey:@"image"]) {
        img = [params objectForKey:@"image"];
    }
    
    NSData* data = UIImageJPEGRepresentation(img,1.0);
    
    NSMutableString *body=[[NSMutableString alloc]init];
 
    NSArray *keys= [params allKeys];
    
    for(int i=0;i<[keys count];i++)
    {
        NSString *key=[keys objectAtIndex:i];
        if(![key isEqualToString:@"image"])
        {
            [body appendFormat:@"%@\r\n",MPboundary];
            [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",key];
            [body appendFormat:@"%@\r\n",[params objectForKey:key]];
        }
    }
    
    [body appendFormat:@"%@\r\n",MPboundary];
    
    [body appendFormat:@"Content-Disposition: form-data; name=\"image\"; filename=\"%@.jpg\"\r\n",[self generateTrade]];

    [body appendFormat:@"Content-Type: image/png\r\n\r\n"];
    
    NSString *end=[[NSString alloc]initWithFormat:@"\r\n%@",endMPboundary];

    NSMutableData *myRequestData=[NSMutableData data];

    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];

    [myRequestData appendData:data];

    [myRequestData appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
    

    NSString *content=[[NSString alloc]initWithFormat:@"multipart/form-data; boundary=%@",TWITTERFON_FORM_BOUNDARY];

    [request setValue:content forHTTPHeaderField:@"Content-Type"];

    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[myRequestData length]] forHTTPHeaderField:@"Content-Length"];

    [request setHTTPBody:myRequestData];

    [request setHTTPMethod:@"POST"];
    
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:delegate];
    
    if (conn) {
        
    }
}
/*

- (void)connection:(NSURLConnection *)connection didWriteData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long) expectedTotalBytes{

    NSLog(@"didWriteData");
}

- (void)connectionDidFinishDownloading:(NSURLConnection *)connection destinationURL:(NSURL *) destinationURL{
    NSLog(@"destinationURL");

}

- (void)connection:(NSURLConnection *)connection   didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite{

    NSLog(@"connection %ld ----- %ld ---- %ld",(long)bytesWritten, (long)totalBytesWritten , (long)totalBytesExpectedToWrite);

}

*/
- (NSString *)generateTrade{
    static int kNumber = 15;
    NSString *sourceStr = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    srand((unsigned)time(0));
    for (int i = 0; i < kNumber; i++)
    {
        unsigned index = rand() % [sourceStr length];
        NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
        [resultStr appendString:oneStr];
    }
    return resultStr;
}


@end
