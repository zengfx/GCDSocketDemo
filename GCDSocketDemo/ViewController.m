//
//  ViewController.m
//  GCDSocketDemo
//
//  Created by qian haiyuan on 14-9-1.
//  Copyright (c) 2014年 zengfx. All rights reserved.
//

#import "ViewController.h"

@interface ViewController (){
    TcpClient *tcp;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// 网络检测
    [self netstate];
    
    // 链接远程长链接
    tcp = [TcpClient sharedInstance];
    [tcp setDelegate_ITcpClient:self];
    [tcp openTcpConnection];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)netstate
{
    NSLog(@"开启 %@ 的网络检测",NetUrlCheck);
    Reachability* reach = [Reachability reachabilityWithHostname:NetUrlCheck];
    NSLog(@"-- current status: %@", reach.currentReachabilityString);
    
    // start the notifier which will cause the reachability object to retain itself!
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    [reach startNotifier];
    
}

- (void) reachabilityChanged: (NSNotification*)note {
    Reachability *reach = [note object];
    
    if(![reach isReachable])
    {
        self.tfRecived.text = @"网络不可用";
        self.tfRecived.backgroundColor = [UIColor redColor];
        
        [tcp disConnect];
        
        return;
    }
    
    self.tfRecived.text = @"网络可用";
    self.tfRecived.backgroundColor = [UIColor greenColor];
    
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:
            break;
        case ReachableViaWWAN:{
            self.tfRecived.backgroundColor = [UIColor greenColor];
            self.tfRecived.text = @"当前通过2g or 3g连接";
        }
            break;
        case ReachableViaWiFi:{
            self.tfRecived.backgroundColor = [UIColor greenColor];
            self.tfRecived.text = @"当前通过wifi连接";
        }
            break;
    }
}

#pragma mark --/**收到服务器端发送的数据*/
-(void)OnReciveData:(NSString*)recivedTxt{
    self.tfRecived.text = [NSString stringWithFormat:@"%@\r\n-->recived:%@\r\n",self.tfRecived.text,recivedTxt];
}

#pragma mark -- /**socket连接出现错误*/
-(void)OnConnectionError:(NSError *)err{
    self.tfRecived.text = [NSString stringWithFormat:@"%@\r\n\r\n**** network error! ****\r\n",self.tfRecived.text];
}

/**发送到服务器端的数据*/
-(void)OnSendDataSuccess:(NSString*)sendedTxt{
    self.tfRecived.text = [NSString stringWithFormat:@"%@\r\nsended-->:%@\r\n",self.tfRecived.text,sendedTxt];
}

#pragma mark - 收回键盘
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)clickToSendMsg:(id)sender {
    if(tcp.asyncSocket.isDisconnected)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"网络不通" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }else if(tcp.asyncSocket.isConnected)
    {
        NSString *requestStr = [NSString stringWithFormat:@"%@",self.sendMsg_label.text];
        [tcp writeString:requestStr];
        
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"TCP链接没有建立" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }
}
@end
