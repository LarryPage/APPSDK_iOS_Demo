//
//  GeneralTimerControlView.m
//  BLAPPSDKDemo
//
//  Created by 白洪坤 on 2018/3/14.
//  Copyright © 2018年 BroadLink. All rights reserved.
//

#import "GeneralTimerControlView.h"
#import "AppDelegate.h"
#import "BLStatusBar.h"

@interface GeneralTimerControlView ()<UITextViewDelegate>{
    BLController *_blController;
    NSMutableArray *_timeArray;
    NSInteger _nextIndex;
}
@property (weak, nonatomic) IBOutlet UITableView *timerList;
@property (nonatomic, weak)NSTimer *stateTimer;
@end

@implementation GeneralTimerControlView

- (void)viewDidLoad {
    [super viewDidLoad];
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    _blController = delegate.let.controller;
    _timeArray = [NSMutableArray arrayWithCapacity:0];
//    if (![_stateTimer isValid]) {
//        __weak typeof(self) weakSelf = self;
//        _stateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f repeats:YES block:^(NSTimer * _Nonnull timer) {
//            [weakSelf gettimerDnaControl];
//        }];
//    }
    [self gettimerDnaControl];
    _nextIndex = -1;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_stateTimer invalidate];
    _stateTimer = nil;
}

- (IBAction)addTimer:(id)sender {
    //新增普通定时
    UIAlertController *actionSheetController = [UIAlertController alertControllerWithTitle:@"Select Timer" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *commTimerAction = [UIAlertAction actionWithTitle:@"Comm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Comm" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = @"0_1_01_*_*_0,1,2,3,4,5_*";
            textField.placeholder = @"time";
        }];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = @"1";
            textField.placeholder = @"val";
        }];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString *timeStr = alertController.textFields.firstObject.text;
            NSInteger val = [alertController.textFields.lastObject.text integerValue];
            [self addCommTimerDnaControl:timeStr val:val];
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }];
    //新增延时定时
    UIAlertAction *delayTimerAction = [UIAlertAction actionWithTitle:@"delay" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"delay" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = @"0_1_01_*_*_0,1,2,3,4,5_*";
            textField.placeholder = @"time";
        }];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = @"1";
            textField.placeholder = @"val";
        }];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString *timeStr = alertController.textFields.firstObject.text;
            NSInteger val = [alertController.textFields.lastObject.text integerValue];
            [self addDelayTimerDnaControl:timeStr val:val];
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }];
    //新增周期定时
    UIAlertAction *periodTimerAction = [UIAlertAction actionWithTitle:@"period" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"period" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = @"0_1_01_*_*_0,1,2,3,4,5_*";
            textField.placeholder = @"time";
        }];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = @"1";
            textField.placeholder = @"val";
        }];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString *timeStr = alertController.textFields.firstObject.text;
            NSInteger val = [alertController.textFields.lastObject.text integerValue];
            [self addPeriodTimerDnaControl:timeStr val:val];
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }];
    //新增循环定时
    UIAlertAction *cycleTimerAction = [UIAlertAction actionWithTitle:@"cycle" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"cycle" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = @"0_1_01_*_*_0,1,2,3,4,5_*";
            textField.placeholder = @"stime";
        }];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = @"0_1_22_*_*_0,1,2,3,4,5_*";
            textField.placeholder = @"etime";
        }];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = @"15";
            textField.placeholder = @"time1";
        }];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = @"15";
            textField.placeholder = @"time2";
        }];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString *stimeStr = alertController.textFields.firstObject.text;
            NSString *etimeStr = alertController.textFields[1].text;
            NSInteger time1Int = [alertController.textFields[2].text integerValue];
            NSInteger time2Int = [alertController.textFields[3].text integerValue];
            [self addCycleTimerDnaControl:stimeStr etime:etimeStr time1:time1Int time2:time2Int];
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }];
    //新增随机定时
    UIAlertAction *randTimerAction = [UIAlertAction actionWithTitle:@"rand" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"rand" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = @"0_1_01_*_*_0,1,2,3,4,5_*";
            textField.placeholder = @"stime";
        }];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = @"0_1_22_*_*_0,1,2,3,4,5_*";
            textField.placeholder = @"etime";
        }];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = @"15";
            textField.placeholder = @"time1";
        }];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = @"15";
            textField.placeholder = @"time2";
        }];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString *stimeStr = alertController.textFields.firstObject.text;
            NSString *etimeStr = alertController.textFields[1].text;
            NSInteger time1Int = [alertController.textFields[2].text integerValue];
            NSInteger time2Int = [alertController.textFields.lastObject.text integerValue];
            [self addRandTimerDnaControl:stimeStr etime:etimeStr time1:time1Int time2:time2Int];
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }];
    //配置日出日落信息
    UIAlertAction *sunriseAction = [UIAlertAction actionWithTitle:@"Sunrise" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sunrise" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = @"2018";
            textField.placeholder = @"year";
        }];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = @"120";
            textField.placeholder = @"longitude";
        }];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = @"30";
            textField.placeholder = @"latitude";
        }];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSInteger year = [alertController.textFields.firstObject.text integerValue];
            double longitude = [alertController.textFields[1].text doubleValue];
            double latitude = [alertController.textFields[2].text doubleValue];
            [self addSunriseTime:year longitude:longitude latitude:latitude];
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
        
    }];
    [actionSheetController addAction:commTimerAction];
    [actionSheetController addAction:delayTimerAction];
    [actionSheetController addAction:periodTimerAction];
    [actionSheetController addAction:cycleTimerAction];
    [actionSheetController addAction:randTimerAction];
    [actionSheetController addAction:sunriseAction];
    [self presentViewController:actionSheetController animated:YES completion:nil];
   
}

- (IBAction)stopTimerType:(id)sender {
    UIAlertController *timerTypeController = [UIAlertController alertControllerWithTitle:@"startOrstopTimerType" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [timerTypeController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = @"1";
        textField.placeholder = @"Commen";
    }];
    [timerTypeController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = @"1";
        textField.placeholder = @"delayen";
    }];
    [timerTypeController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = @"1";
        textField.placeholder = @"perioden";
    }];
    [timerTypeController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = @"1";
        textField.placeholder = @"cycleen";
    }];
    [timerTypeController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = @"1";
        textField.placeholder = @"randen";
    }];
    [timerTypeController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSInteger CommenStr = [timerTypeController.textFields.firstObject.text integerValue];
        NSInteger delayenStr = [timerTypeController.textFields[1].text integerValue];
        NSInteger periodenStr = [timerTypeController.textFields[2].text integerValue];
        NSInteger cycleenStr = [timerTypeController.textFields[3].text integerValue];
        NSInteger randenStr = [timerTypeController.textFields.lastObject.text integerValue];
        [self startOrstopTimerTypeCommen:CommenStr delayen:delayenStr perioden:periodenStr cycleen:cycleenStr randen:randenStr];
    }]];
    [self presentViewController:timerTypeController animated:YES completion:nil];
    
    [self queryTimeType];
}

- (IBAction)next:(id)sender {
    _nextIndex = _nextIndex + 1;
    [self gettimerDnaControl:5 index:_nextIndex];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _timeArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"timeInfoCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    NSDictionary *dic = _timeArray[indexPath.row];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",dic[@"id"]];
    NSString *type = dic[@"type"];
    if ([type isEqualToString:@"comm"] || [type isEqualToString:@"delay"] || [type isEqualToString:@"period"]) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",dic[@"name"],dic[@"time"]];
    }else{
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ %@",dic[@"name"],dic[@"stime"],dic[@"etime"]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSDictionary *dic = _timeArray[indexPath.row];
//    NSString *type = dic[@"type"];
//    NSInteger sid = [dic[@"id"] integerValue];
//    if ([type isEqualToString:@"comm"] || [type isEqualToString:@"delay"] || [type isEqualToString:@"period"]) {
//        NSDictionary *cmd = @{@"params":@[@"pwr"],@"vals":@[@[@{@"val":@0,@"idx":@1}]]};
//
//        NSDictionary *timeInfo = @{
//                                   @"type":type,
//                                   @"id":@(sid),
//                                   @"en":@1,
//                                   @"name":dic[@"name"],
//                                   @"time":@"0_1_22_26_2_*_2018",
//                                   @"cmd":cmd,
//                                   };
//        NSDictionary *stdData = @{
//                                  @"act":@2,
//                                  @"timerlist":@[
//                                          timeInfo
//                                          ]
//                                  };
//        NSString *stdDataStr = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:stdData options:0 error:nil] encoding:NSUTF8StringEncoding];
//
//        NSString *result = [_blController dnaControl:self.device.did subDevDid:nil dataStr:stdDataStr command:@"dev_subdev_timer" scriptPath:nil];
//        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
//        NSLog(@"status%@,did:%@",dic[@"status"],dic[@"did"]);
//    }else{
//        NSDictionary *cmd = @{@"params":@[@"pwr"],@"vals":@[@[@{@"val":@0,@"idx":@1}]]};
//
//        NSDictionary *cycInfo = @{
//                                  @"type":type,
//                                  @"id":@(sid),
//                                  @"en":@1,
//                                  @"name":dic[@"name"],
//                                  @"stime":@"0_1_01_*_*_*_*",
//                                  @"etime":@"0_1_23_*_*_*_*",
//                                  @"time1":@"0_1_05_*_*_*_*",
//                                  @"time2":@"0_1_20_*_*_*_*",
//                                  @"cmd1":cmd,
//                                  @"cmd2":cmd
//                                  };
//        NSDictionary *stdData = @{
//                                  @"act":@2,
//                                  @"timerlist":@[
//                                          cycInfo
//                                          ]
//                                  };
//        NSString *stdDataStr = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:stdData options:0 error:nil] encoding:NSUTF8StringEncoding];
//
//        NSString *result = [_blController dnaControl:self.device.did subDevDid:nil dataStr:stdDataStr command:@"dev_subdev_timer" scriptPath:nil];
//        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
//        NSLog(@"status%@,did:%@",dic[@"status"],dic[@"did"]);
//    }
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSDictionary *dic = _timeArray[indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self deltimerDnaControl:dic[@"type"] sid:[dic[@"id"] integerValue]];
        [_timeArray removeObjectAtIndex:indexPath.row];
        [_timerList deleteRowsAtIndexPaths:@[indexPath]  withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)timerController:(NSString *)time type:(NSString *)type name:(NSString *)name cmd:(NSDictionary *)cmd {
    NSDictionary *timeInfo = @{
                               @"did":self.device.did,
                               @"type":type,
                               @"en":@1,
                               @"name":name,
                               @"time":time,
                               @"cmd":cmd,
                               };
    NSDictionary *stdData = @{
                              @"act":@0,
                              @"timerlist":@[
                                      timeInfo
                                      ]
                              };
    NSString *stdDataStr = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:stdData options:0 error:nil] encoding:NSUTF8StringEncoding];
    
    NSString *result = [_blController dnaControl:self.device.did subDevDid:nil dataStr:stdDataStr command:@"dev_subdev_timer" scriptPath:nil];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    NSLog(@"status%@,did:%@",dic[@"status"],dic[@"did"]);
    [self gettimerDnaControl];
}

//新增普通定时
- (void)addCommTimerDnaControl:(NSString *)time val:(NSInteger)val {
    NSDictionary *cmd = @{@"params":@[@"pwr"],@"vals":@[@[@{@"val":@(val),@"idx":@1}]]};
    [self timerController:time type:@"comm" name:@"普通定时" cmd:cmd];
}
//新增延时定时
- (void)addDelayTimerDnaControl:(NSString *)time val:(NSInteger)val {
    NSDictionary *cmd = @{@"params":@[@"pwr"],@"vals":@[@[@{@"val":@(val),@"idx":@1}]]};
    [self timerController:time type:@"delay" name:@"延时定时" cmd:cmd];
}
//新增周期定时
- (void)addPeriodTimerDnaControl:(NSString *)time val:(NSInteger)val{
    NSDictionary *cmd = @{@"params":@[@"pwr"],@"vals":@[@[@{@"val":@(val),@"idx":@1}]]};
    [self timerController:time type:@"period" name:@"周期定时" cmd:cmd];
}
//新增随机定时
- (void)addRandTimerDnaControl:(NSString *)stime etime:(NSString *)etime time1:(NSInteger)time1 time2:(NSInteger)time2 {
    NSDictionary *cmd = @{@"params":@[@"pwr"],@"vals":@[@[@{@"val":@1,@"idx":@1}]]};
    NSDictionary *cmd1 = @{@"params":@[@"pwr"],@"vals":@[@[@{@"val":@0,@"idx":@1}]]};
    
    NSDictionary *cycInfo = @{
                              @"type":@"rand",
                              @"en":@1,
                              @"name":@"随机定时",
                              @"stime":stime,
                              @"etime":etime,
                              @"time1":@(time1),
                              @"time2":@(time2),
                              @"cmd1":cmd,
                              @"cmd2":cmd1
                              };
    NSDictionary *stdData = @{
                              @"act":@0,
                              @"timerlist":@[
                                      cycInfo
                                      ]
                              };
    NSString *stdDataStr = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:stdData options:0 error:nil] encoding:NSUTF8StringEncoding];
    
    NSString *result = [_blController dnaControl:self.device.did subDevDid:nil dataStr:stdDataStr command:@"dev_subdev_timer" scriptPath:nil];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    NSLog(@"status%@,did:%@",dic[@"status"],dic[@"did"]);
    [self gettimerDnaControl];
}
//新增循环定时
- (void)addCycleTimerDnaControl:(NSString *)stime etime:(NSString *)etime time1:(NSInteger)time1 time2:(NSInteger)time2 {
    NSDictionary *cmd = @{@"params":@[@"pwr"],@"vals":@[@[@{@"val":@1,@"idx":@1}]]};
    NSDictionary *cmd1 = @{@"params":@[@"pwr"],@"vals":@[@[@{@"val":@0,@"idx":@1}]]};

    NSDictionary *cycInfo = @{
                              @"type":@"cycle",
                              @"en":@1,
                              @"name":@"循环定时",
                              @"stime":stime,
                              @"etime":etime,
                              @"time1":@(time1),
                              @"time2":@(time2),
                              @"cmd1":cmd,
                              @"cmd2":cmd1
                              };
    NSDictionary *stdData = @{
                              @"act":@0,
                              @"timerlist":@[
                                      cycInfo
                                      ]
                              };
    NSString *stdDataStr = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:stdData options:0 error:nil] encoding:NSUTF8StringEncoding];
    
    NSString *result = [_blController dnaControl:self.device.did subDevDid:nil dataStr:stdDataStr command:@"dev_subdev_timer" scriptPath:nil];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    NSLog(@"status%@,did:%@",dic[@"status"],dic[@"did"]);
    [self gettimerDnaControl];
}
//删除定时
- (void)deltimerDnaControl:(NSString *)type sid:(NSInteger)sid {
    NSDictionary *timeInfo = @{
                               @"type":type,
                               @"id":@(sid)
                               };
    NSDictionary *stdData = @{
                              @"act":@1,
                              @"timerlist":@[
                                      timeInfo
                                      ]
                              };
    NSString *stdDataStr = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:stdData options:0 error:nil] encoding:NSUTF8StringEncoding];
    
    NSString *result = [_blController dnaControl:self.device.did subDevDid:nil dataStr:stdDataStr command:@"dev_subdev_timer" scriptPath:nil];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    NSLog(@"status%@,did:%@",dic[@"status"],dic[@"did"]);
//    [self gettimerDnaControl];
}

//获取定时列表
- (void)gettimerDnaControl:(NSInteger)count index:(NSInteger)index {
    NSDictionary *stdData = @{
                              @"act":@3,
                              @"type":@"all",
                              @"count":@(count),
                              @"index":@(index)
                              };
    NSString *stdDataStr = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:stdData options:0 error:nil] encoding:NSUTF8StringEncoding];
    
    NSString *result = [_blController dnaControl:self.device.did subDevDid:nil dataStr:stdDataStr command:@"dev_subdev_timer" scriptPath:nil];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
//    NSLog(@"dic%@",dic[@"data"][@"timerlist"]);
    _timeArray = dic[@"data"][@"timerlist"];
    [self.timerList reloadData];
}

- (void)gettimerDnaControl {
    [self gettimerDnaControl:10 index:0];
}

//开启或者禁用某种定时
- (void)startOrstopTimerTypeCommen:(NSInteger)commen delayen:(NSInteger)delayen perioden:(NSInteger)perioden cycleen:(NSInteger)cycleen randen:(NSInteger)randen  {
    NSDictionary *stdData = @{
                              @"did":self.device.did,
                              @"act":@4,
                              @"comm_en":@(commen),
                              @"delay_en":@(delayen),
                              @"period_en":@(perioden),
                              @"cycle_en":@(cycleen),
                              @"rand_en":@(randen)
                              };
    NSString *stdDataStr = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:stdData options:0 error:nil] encoding:NSUTF8StringEncoding];
    
    NSString *result = [_blController dnaControl:self.device.did subDevDid:nil dataStr:stdDataStr command:@"dev_subdev_timer" scriptPath:nil];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    NSLog(@"status%@,did:%@",dic[@"status"],dic[@"did"]);
}

//查询定时限制信息
- (void)queryTimeType {
    NSDictionary *stdData = @{
                              @"did":self.device.did,
                              @"act":@5,
                              @"type":@""
                              };
    NSString *stdDataStr = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:stdData options:0 error:nil] encoding:NSUTF8StringEncoding];
    
    NSString *result = [_blController dnaControl:self.device.did subDevDid:nil dataStr:stdDataStr command:@"dev_subdev_timer" scriptPath:nil];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    NSLog(@"status%@,did:%@",dic[@"status"],dic[@"did"]);
}

- (int)setHour:(int)hour {
    int endHuor = hour + 8;
    if (endHuor > 24) {
        endHuor = endHuor - 24;
    }
    
    return endHuor;
}

//配置日出日落信息
- (void)addSunriseTime:(NSInteger)year longitude:(double)longitude latitude:(double)latitude  {
    
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"tableList" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    for (int i = 1; i <= 12; i++) {
        NSMutableArray *tableList = [NSMutableArray array];
        BLSunriseResult *sunriseResult = [_blController calulateSunriseTimeWithData:[NSString stringWithFormat:@"%ld-%d-01",(long)year,i] longitude:longitude latitude:latitude];
        NSString *sunrise = sunriseResult.sunrise;  //01:04:11(UTC)
        NSString *sunset = sunriseResult.sunset;    //19:01:29(UTC)
        
        int sunrise_hour = [[sunrise substringWithRange:NSMakeRange(0,2)] intValue];
        int sunrise_min = [[sunrise substringWithRange:NSMakeRange(3,2)] intValue];
        int sunrise_sec = [[sunrise substringWithRange:NSMakeRange(6,2)] intValue];
        
        int sunset_hour = [[sunset substringWithRange:NSMakeRange(0,2)] intValue];
        int sunset_min = [[sunset substringWithRange:NSMakeRange(3,2)] intValue];
        int sunset_sec = [[sunset substringWithRange:NSMakeRange(6,2)] intValue];
        
        sunrise_hour = [self setHour:sunrise_hour];
        sunset_hour = [self setHour:sunset_hour];
        
        [tableList addObject:@(i)];
        [tableList addObject:@1];
        [tableList addObject:@(sunrise_hour)];
        [tableList addObject:@(sunrise_min)];
        [tableList addObject:@(sunrise_sec)];
        [tableList addObject:@(sunset_hour)];
        [tableList addObject:@(sunset_min)];
        [tableList addObject:@(sunset_sec)];
        
        NSString *tableListString = [tableList componentsJoinedByString:@","];
        
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = tableListString;
            textField.placeholder = @"mon,day,sunrise_hour,sunrise_min,sunrise_sec,sunset_hour,sunset_min,sunset_sec";
        }];
    }
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSMutableArray  *tableListArray = [NSMutableArray array];
        for (int i = 0; i < 12; i ++) {
            NSString *table = alertController.textFields[i].text;
            NSArray  *tableList = [table componentsSeparatedByString:@","];
            [tableListArray addObjectsFromArray:tableList];
        }

        NSMutableArray *tableList = [NSMutableArray array];
        for (NSString *table in tableListArray) {
            [tableList addObject:@([table intValue])];
        }
        [self addSunriseTime:year longitude:longitude latitude:latitude table:tableList];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}


- (void)addSunriseTime:(NSInteger)year longitude:(double)longitude latitude:(double)latitude table:(NSArray *)tableList {
    NSDictionary *stdData = @{
                              @"did":self.device.did,
                              @"act":@6,
                              @"year":@(year),
                              @"longitude":[NSString stringWithFormat:@"%f",longitude],
                              @"latitude":[NSString stringWithFormat:@"%f",latitude],
                              @"fmt" :@0,
                              @"table":tableList
                              };
    NSString *stdDataStr = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:stdData options:0 error:nil] encoding:NSUTF8StringEncoding];
    
    NSString *result = [_blController dnaControl:self.device.did subDevDid:nil dataStr:stdDataStr command:@"dev_subdev_timer" scriptPath:nil];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    NSLog(@"status%@,did:%@",dic[@"status"],dic[@"did"]);
}

@end
