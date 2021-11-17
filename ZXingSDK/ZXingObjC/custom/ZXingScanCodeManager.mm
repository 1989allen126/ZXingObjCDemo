//
//  ZXingScanCodeManager.m
//  ZXingSDK
//
//  Created by Jianglun Jin on 2021/11/17.
//

#include <iostream>
#import <opencv2/imgcodecs/ios.h>
#import "ZXingScanCodeManager.h"
#import "ZXingSNCodeDetector.h"

@interface ZXingScanCodeManager()
@property (nonatomic, copy) dispatch_queue_t scanQueue;
@property (nonatomic, strong) ZXingSNCodeDetector *detector;
@end

@implementation ZXingScanCodeManager

+(instancetype)manager {
    static ZXingScanCodeManager * _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[ZXingScanCodeManager alloc] initParam];
    });
    
    return _instance;
}

- (instancetype)initParam {
    self = [super init];
    if(self) {
        _scanQueue = dispatch_queue_create("www.zxing.scan_sn_code",DISPATCH_QUEUE_CONCURRENT);
        _detector = [[ZXingSNCodeDetector alloc] init];
    }
    return self;
}

///扫描sn码
- (void)startScanSNCode:(UIImage*)image completion:(ZXingScanCodeResultBlock) complete {
    dispatch_async(_scanQueue, ^{
        if(image == nil) {
            [self finishScanWithResult:@[] completion:complete];
            return;
        }
        
        bool found = false;
        @autoreleasepool {
            cv::Mat src;
            UIImageToMat(image,src);
            std::vector<cv::Mat> images = [self->_detector clippedSourceMat:src];
            for(auto iter_img = images.begin();iter_img != images.end();++iter_img) {
                cv::Mat detect_image = *iter_img;
                ZXResult *result = [self->_detector detect:detect_image];
                if(result) {
                    if(found) {
                        return;
                    }
                    
                    [self finishScanWithResult:@[result] completion:complete];
                    found = true;
                    break;
                }
            }
        }
        if(!found) {
            [self finishScanWithResult:@[] completion:complete];
        }
    });
}

- (void) finishScanWithResult:(NSArray<ZXResult *> *) results completion:(ZXingScanCodeResultBlock) complete {
    if(!complete) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        complete(results);
    });
}

@end
