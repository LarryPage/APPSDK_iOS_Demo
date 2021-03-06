//
//  RecoginzeIRCodeViewController.m
//  BLAPPSDKDemo
//
//  Created by 白洪坤 on 2017/8/14.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import "RecoginzeIRCodeViewController.h"
#import "AppDelegate.h"
#import "ControlViewController.h"
#import "TVControllTableViewController.h"

@interface RecoginzeIRCodeViewController ()
@property (weak, nonatomic) IBOutlet UILabel *ResultTxt;
@property (nonatomic, strong) BLController *blcontroller;
@property (nonatomic, strong) BLIRCode *blircode;
@property (nonatomic, strong) NSArray *tvList;
@end

@implementation RecoginzeIRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.blcontroller = delegate.let.controller;
    self.blircode = [BLIRCode sharedIrdaCode];
    self.tvList = [NSArray array];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)downLoadIRCodeScript:(id)sender {
    if (_downloadinfo.devtype == BL_IRCODE_DEVICE_AC){
        _downloadinfo.savePath = [self.blcontroller.queryIRCodeScriptPath stringByAppendingPathComponent:_downloadinfo.name];
        [self downloadIRCodeScript:_downloadinfo.downloadUrl savePath:_downloadinfo.savePath randkey:_downloadinfo.fixkey];
    }else if (_downloadinfo.devtype == BL_IRCODE_DEVICE_TV_BOX || _downloadinfo.devtype == BL_IRCODE_DEVICE_TV){
        _downloadinfo.savePath = [self.blcontroller.queryIRCodeScriptPath stringByAppendingPathComponent:_downloadinfo.name];
        [self downloadIRCodeScript:_downloadinfo.downloadUrl savePath:_downloadinfo.savePath randkey:_downloadinfo.randkey];
    }
}

- (IBAction)getIRCodeBaseInfo:(id)sender {
    if (_downloadinfo.devtype == BL_IRCODE_DEVICE_AC) {
        [self queryIRCodeScriptInfoSavePath:_downloadinfo.savePath randkey:nil deviceType:BL_IRCODE_DEVICE_AC];
    }else if (_downloadinfo.devtype == BL_IRCODE_DEVICE_TV || _downloadinfo.devtype == BL_IRCODE_DEVICE_TV_BOX){
        [self queryCloudCodeScriptInfoSavePath:_downloadinfo.savePath randkey:nil deviceType:BL_IRCODE_DEVICE_TV];
    }
}

- (IBAction)getIRCodeData:(id)sender {
    if (_downloadinfo.devtype == BL_IRCODE_DEVICE_AC) {
        [self performSegueWithIdentifier:@"controllerView" sender:_downloadinfo.savePath];
    }else if (_downloadinfo.devtype == BL_IRCODE_DEVICE_TV || _downloadinfo.devtype == BL_IRCODE_DEVICE_TV_BOX){
        [self performSegueWithIdentifier:@"TVcontrollerView" sender:_downloadinfo.savePath];
    }
    
}


- (void)downloadIRCodeScript:(NSString *_Nonnull)urlString savePath:(NSString *_Nonnull)path randkey:(NSString *_Nullable)randkey {
    [self.blircode downloadIRCodeScriptWithUrl:urlString savePath:path randkey:randkey completionHandler:^(BLDownloadResult * _Nonnull result) {
        NSLog(@"statue:%ld msg:%@", (long)result.error, result.msg);
        if ([result succeed]) {
            NSLog(@"savepath:%@", result.savePath);
            dispatch_async(dispatch_get_main_queue(), ^{
                self->_ResultTxt.text = result.savePath;
            });
            
        }
    }];
}

- (void)queryIRCodeScriptInfoSavePath:(NSString *)savePath randkey:(NSString *)randkey deviceType:(NSInteger)devicetype {
    BLIRCodeInfoResult *result = [self.blircode queryIRCodeInfomationWithScript:savePath deviceType:devicetype];
    NSLog(@"statue:%ld msg:%@", (long)result.error, result.msg);
    if ([result succeed]) {
        NSLog(@"info:%@", result.infomation);
        dispatch_async(dispatch_get_main_queue(), ^{
            self->_ResultTxt.text = result.infomation;
        });
        
    }
}

- (void)queryCloudCodeScriptInfoSavePath:(NSString *)savePath randkey:(NSString *)randkey deviceType:(NSInteger)devicetype {
    NSDictionary *infomation =[NSJSONSerialization JSONObjectWithData:[[NSString stringWithContentsOfFile:savePath usedEncoding:nil error:nil] dataUsingEncoding:NSUTF8StringEncoding] options:NSUTF8StringEncoding error:nil] ;
    NSArray *infoList = [infomation objectForKey:@"functionList"];
    NSString *function = @"";
    for (NSDictionary *dic in infoList) {
        function = [function stringByAppendingString:[NSString stringWithFormat:@"%@,",dic[@"function"]]];
    }
    self.tvList = [self matchString:function toRegexString:@"\\w+"];
    dispatch_async(dispatch_get_main_queue(), ^{
        self->_ResultTxt.text = function;
    });
}




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"controllerView"]) {
        UIViewController *target = segue.destinationViewController;
        if ([target isKindOfClass:[ControlViewController class]]) {
            ControlViewController* opVC = (ControlViewController *)target;
            opVC.savePath = (NSString *)sender;
        }
    }else if ([segue.identifier isEqualToString:@"TVcontrollerView"]){
        UIViewController *target = segue.destinationViewController;
        if ([target isKindOfClass:[TVControllTableViewController class]]) {
            TVControllTableViewController* opVC = (TVControllTableViewController *)target;
            opVC.savePath = (NSString *)sender;
            opVC.tvList = self.tvList;
            opVC.devtype = _downloadinfo.devtype;
        }
    }
}


/**
 *  正则匹配返回符合要求的字符串 数组
 *
 *  @param string   需要匹配的字符串
 *  @param regexStr 正则表达式
 *
 *  @return 符合要求的字符串 数组 (按(),分级,正常0)
 */
- (NSArray *)matchString:(NSString *)string toRegexString:(NSString *)regexStr
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexStr options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray * matches = [regex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
    //match: 所有匹配到的字符,根据() 包含级
    NSMutableArray *array = [NSMutableArray array];
    for (NSTextCheckingResult *match in matches) {
        for (int i = 0; i < [match numberOfRanges]; i++) {
            //以正则中的(),划分成不同的匹配部分
            NSString *component = [string substringWithRange:[match rangeAtIndex:i]];
            [array addObject:component];
        }
    }
    return array;
}

@end
