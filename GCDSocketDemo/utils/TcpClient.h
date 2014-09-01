//
//  TcpClient.h
//  hy_iPhone_doc
//
//  Created by qian haiyuan on 14-8-7.
//  Copyright (c) 2014年 yuanqitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

@protocol ITcpClient <NSObject>

#pragma mark ITcpClient

/**发送到服务器端的数据*/
-(void)OnSendDataSuccess:(NSString*)sendedTxt;

/**收到服务器端发送的数据*/
-(void)OnReciveData:(NSString*)recivedTxt;

/**socket连接出现错误*/
-(void)OnConnectionError:(NSError *)err;

@end

@interface TcpClient : NSObject{
    id<ITcpClient> itcpClient;
}

@property (nonatomic,strong) GCDAsyncSocket *asyncSocket;

+ (TcpClient *)sharedInstance;

-(void)setDelegate_ITcpClient:(id<ITcpClient>)_itcpClient;

-(NSError *)openTcpConnection;

-(BOOL)isConnected;

-(void)getConnection;

-(void)disConnect;

-(void)writeString:(NSString*)datastr;

@end
