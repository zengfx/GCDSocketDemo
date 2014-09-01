//
//  TcpClient.m
//  hy_iPhone_doc
//
//  Created by qian haiyuan on 14-8-7.
//  Copyright (c) 2014年 yuanqitech. All rights reserved.
//

#import "TcpClient.h"

@implementation TcpClient

@synthesize asyncSocket;

+ (TcpClient *)sharedInstance
{
    static TcpClient *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[TcpClient alloc] init];
    });
    
    return _sharedInstance;
}

-(id)init
{
    self = [super init];
    return self;
}

-(void)setDelegate_ITcpClient:(id<ITcpClient>)_itcpClient
{
    itcpClient = _itcpClient;
}

-(NSError *)openTcpConnection
{
    if (nil == asyncSocket){
        dispatch_queue_t mainQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:mainQueue];
    }
    NSError *error = nil;
    if (![asyncSocket connectToHost:SOCKET_HOST onPort:SOCKET_PORT error:&error])
    {
        NSLog(@"Error connecting: %@", error);
    }
    
    return error;
}

#pragma mark -- 取得连接
-(void)getConnection {
    if (![asyncSocket isConnected]) {
        [self disConnect];
        [self openTcpConnection];
    }
}

#pragma mark -- 是否链接到远程服务端
-(BOOL)isConnected{
    return [asyncSocket isConnected];
}

#pragma mark -- 断开链接
-(void)disConnect {
    [asyncSocket disconnect];
}

#pragma mark -- socket连接成功后的回调代理
-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"链接到Socket地址成功..........IP: %@, port:%i",host,port);
    
    [self listenData];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
	NSLog(@"socketDidDisconnect:%p withError: %@", sock, err);
    dispatch_async(dispatch_get_main_queue(), ^{
        [itcpClient OnConnectionError:err];
    });
}

#pragma mark -- 读到数据后的回调代理
-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSString *fromServer = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [itcpClient OnReciveData:fromServer];
    });
    
    [self listenData];
}

/**
 * Called when a socket has completed writing the requested data. Not called if there is an error.
 **/
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
	NSLog(@"socket:%p didWriteDataWithTag:%ld", sock, tag);
    dispatch_async(dispatch_get_main_queue(), ^{
        [itcpClient OnSendDataSuccess:[NSString stringWithFormat:@"tag:%li",tag]];
    });
}

-(void)socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag {
    NSLog(@"Reading data length of %d",partialLength);
}

#pragma mark -- 发起一个读取的请求，当收到数据时后面的didReadData才能被回调
-(void)listenData {
    [asyncSocket readDataToData:[GCDAsyncSocket LFData] withTimeout:-1 tag:1];
}

-(void)writeString:(NSString*)datastr{
    [self sendMsg2Server:datastr];
}

#pragma mark -- 向服务端发送信息
-(void)sendMsg2Server:(NSString *)msg{
    [self getConnection];
    
    NSString *userinfo = [NSString stringWithFormat:@"%@\n",msg];
    NSData *data = [userinfo dataUsingEncoding:NSUTF8StringEncoding];
    [asyncSocket writeData:data withTimeout:30 tag:1];
}

@end
