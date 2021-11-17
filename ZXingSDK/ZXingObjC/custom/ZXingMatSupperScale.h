//
//  ZXingMatSupperScale.h
//  ZXingSDK
//
//  Created by Jianglun Jin on 2021/11/17.
//

#import <Foundation/Foundation.h>
#import <opencv2/opencv.hpp>

NS_ASSUME_NONNULL_BEGIN

@interface ZXingMatSupperScale : NSObject

@property (nonatomic, assign) NSInteger srMaxSize;

- (cv::Mat)processImageScale:(cv::Mat) src scale:(float)scale;
@end

NS_ASSUME_NONNULL_END
