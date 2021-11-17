//
//  ViewController.m
//  ZXingSDK
//
//  Created by Jianglun Jin on 2021/11/17.
//

#import "ViewController.h"
#import "ZXingScanCodeManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImage *barcode = [UIImage imageNamed:@"barcode3.jpeg"];
    UIImage *qrcode = [UIImage imageNamed:@"qrcode.png"];
    ZXingScanCodeManager *scanCodeMgr = [ZXingScanCodeManager manager];
    [scanCodeMgr startScanSNCode:qrcode completion:^(NSArray<ZXResult *> * _Nonnull results) {
        [results enumerateObjectsUsingBlock:^(ZXResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSLog(@"扫描到的结果：%@",obj.text);
        }];
    }];
}


@end
