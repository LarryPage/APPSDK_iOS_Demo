//
//  TVControllTableViewController.m
//  BLAPPSDKDemo
//
//  Created by 白洪坤 on 2017/8/15.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import "TVControllTableViewController.h"
#import "AppDelegate.h"
#import "BLStatusBar.h"
@interface TVControllTableViewController ()
@property (nonatomic, strong) BLController *blcontroller;
@property (nonatomic, strong) BLIRCode *blircode;
@end

@implementation TVControllTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%@",self.tvList);
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.blcontroller = delegate.let.controller;
    self.blircode = [BLIRCode sharedIrdaCode];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _tvList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"TVControllCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    cell.textLabel.text = _tvList[indexPath.row];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //获取的ircode使用RM发射接口发射
    NSString *ircode = [self queryTVIRCodeDataWithScript:self.savePath funcname:self.tvList[indexPath.row]];
    NSLog(@"ircode----%@",ircode);
    [BLStatusBar showTipMessageWithStatus:ircode];
    
    
}

- (NSString *)queryTVIRCodeDataWithScript:(NSString *_Nonnull)savePath funcname:(NSString *_Nonnull)funcname {
    NSDictionary *infomation =[NSJSONSerialization JSONObjectWithData:[[NSString stringWithContentsOfFile:savePath usedEncoding:nil error:nil] dataUsingEncoding:NSUTF8StringEncoding] options:NSUTF8StringEncoding error:nil] ;
    NSArray *infoList = [infomation objectForKey:@"functionList"];

    for (NSDictionary *info in infoList) {
        if (funcname == info[@"function"]) {
            NSArray *dataArray = [info objectForKey:@"code"];
            if (![BLCommonTools isEmptyArray:dataArray]) {
                char *ircodeByte = NULL;
                NSUInteger dataLen = dataArray.count;
                ircodeByte = (char *)malloc(sizeof(char) * (2 * dataLen));
                if (ircodeByte == NULL) {
                    BLLogError(@"ircode data malloc failed!");
                } else {
                    for (int i = 0; i < dataLen; i++) {
                        ircodeByte[i] = [dataArray[i] charValue];
                    }
                    
                    NSData *irdata = [NSData dataWithBytes:ircodeByte length:dataLen];
                    return  [BLCommonTools data2hexString:irdata];
                }
                if (ircodeByte) {
                    free(ircodeByte);
                }
            }
        }
        
    }
    
    return nil;
}

@end
