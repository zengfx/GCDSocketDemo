//
//  ViewController.h
//  GCDSocketDemo
//
//  Created by qian haiyuan on 14-9-1.
//  Copyright (c) 2014年 zengfx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TcpClient.h"
#import "Reachability.h"

@interface ViewController : UIViewController<ITcpClient,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *netcheck_label;

@property (weak, nonatomic) IBOutlet UITextField *sendMsg_label;
@property (weak, nonatomic) IBOutlet UITextView *tfRecived;

- (IBAction)clickToSendMsg:(id)sender;
@end
