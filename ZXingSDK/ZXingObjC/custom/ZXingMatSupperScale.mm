//
//  ZXingMatSupperScale.m
//  ZXingSDK
//
//  Created by Jianglun Jin on 2021/11/17.
//

#import "ZXingMatSupperScale.h"
#import <opencv2/imgproc.hpp>

constexpr static float MAX_SCALE = 4.0f;

@implementation ZXingMatSupperScale

- (instancetype)init {
    self = [super init];
    if(self) {
        _srMaxSize = 160;
    }
    
    return self;
}

- (cv::Mat)processImageScale:(cv::Mat) src scale:(float)scale {
    cv::Mat dst;
    scale = MIN(scale, MAX_SCALE);
    if (scale > .0 && scale < 1.0)
    {  // down sample
        cv::resize(src, dst, cv::Size(), scale, scale, cv::INTER_AREA);
    }
    else if (scale > 1.5 && scale < 2.0)
    {
        cv::resize(src, dst, cv::Size(), scale, scale, cv::INTER_CUBIC);
    }
    else if (scale >= 2.0)
    {
        cv::resize(src, dst, cv::Size(), scale, scale, cv::INTER_CUBIC);
    } else {
        dst = src.clone();
    }
    return dst;
}
@end
