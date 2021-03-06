//
//  MyDeviceListViewController.m
//  BLAPPSDKDemo
//
//  Created by junjie.zhu on 2016/10/20.
//  Copyright © 2016年 BroadLink. All rights reserved.
//

#import "MyDeviceListViewController.h"
#import "OperateViewController.h"
#import "AppDelegate.h"
#import "DeviceDB.h"


@interface MyDeviceListViewController ()

@property (nonatomic, weak)NSTimer *stateTimer;
@property (nonatomic, strong)BLController *blController;
@end

@implementation MyDeviceListViewController{
    BLController *_blController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _MyDeviceTable.delegate = self;
    _MyDeviceTable.dataSource = self;
    _devicearray =  [NSMutableArray arrayWithArray: _myDevices];
    [self setExtraCellLineHidden:_MyDeviceTable];
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.blController = delegate.let.controller;
    [self queryDeviceState:_devicearray];
    
}

- (void)viewDidAppear:(BOOL)animated {
    if (![_stateTimer isValid]) {
        __weak typeof(self) weakSelf = self;
        _stateTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f repeats:YES block:^(NSTimer * _Nonnull timer) {
            for (int i = 0; i < weakSelf.devicearray.count; i ++) {
                BLDNADevice *device = weakSelf.devicearray[i];
                device.state = [weakSelf.blController queryDeviceState:[device getDid]];
                [weakSelf.devicearray replaceObjectAtIndex:i withObject:device];
            }
            [weakSelf.MyDeviceTable reloadData];
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)queryDeviceState:(NSArray<BLDNADevice *> *)tempArray {
    BLQueryDeviceStatusResult *result = [[BLLet sharedLet].controller queryDeviceOnServer:tempArray];
    NSLog(@"statusMaparray array:%@",result.statusMaparray);
    [[BLLet sharedLet].controller queryDeviceRemoteState:tempArray[0].did];
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"OperateView"]) {
        UIViewController *target = segue.destinationViewController;
        if ([target isKindOfClass:[OperateViewController class]]) {
            OperateViewController* opVC = (OperateViewController *)target;
            opVC.device = (BLDNADevice *)sender;
        }
    }
}

#pragma mark - table delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _devicearray.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"MY_DEVICE_LIST_CELL";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    BLDNADevice *device = _devicearray[indexPath.row];
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:101];
    titleLabel.text = [device getName];
    
    UILabel *macLabel = (UILabel *)[cell viewWithTag:102];
    macLabel.text = [NSString stringWithFormat:@"MAC:%@", [device getMac]];
    
    UILabel *typeLabel = (UILabel *)[cell viewWithTag:103];
    typeLabel.text = [NSString stringWithFormat:@"Type:%ld", (long)[device getType]];
    
    UILabel *netstateLabel = (UILabel *)[cell viewWithTag:104];

    netstateLabel.text = [NSString stringWithFormat:@"NetState:%@", [self getstate:[device getState]]];
    return cell;
}

- (NSString *)getstate:(BLDeviceStatusEnum)state{
    NSString *stateString = @"State UnKown";
    switch (state) {
        case BL_DEVICE_STATE_LAN:
            stateString = @"LAN";
            break;
        case BL_DEVICE_STATE_REMOTE:
            stateString = @"REMOTE";
            break;
        case BL_DEVICE_STATE_OFFLINE:
            stateString = @"OFFLINE";
            break;
        default:
            break;
    }
    return stateString;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BLDNADevice *device = _devicearray[indexPath.row];
    [self performSegueWithIdentifier:@"OperateView" sender:device];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    BLDNADevice *device = _devicearray[indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [_blController removeDevice:device];
        [_devicearray removeObjectAtIndex:indexPath.row];
        [[DeviceDB sharedOperateDB] deleteWithinfo:device];
        [_MyDeviceTable deleteRowsAtIndexPaths:@[indexPath]  withRowAnimation:UITableViewRowAnimationNone];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
    }
}
@end
