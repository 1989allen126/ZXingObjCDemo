//
//  ZXingSNCodeDetector.h
//  ZXingSDK
//
//  Created by Jianglun Jin on 2021/11/17.
//

#import <Foundation/Foundation.h>
#import <opencv2/opencv.hpp>
#include <iostream>
#import "ZXResult.h"
#import "ZXMultiFormatReader.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZXingSNCodeDetector : NSObject

/**
 * @brief 获取图片的缩放列表
 * 根据图片width、height
 *
 * @param width 输入的图片宽
 * @param height 输入的图片高
 */
- (std::vector<float>) getScaleList:(int)width height:(int)height;

/**
 * @brief 获取图片的裁切区域列表
 * 根据图片width、height
 *
 * @param width 输入的图片宽
 * @param height 输入的图片高
 */
-(std::vector<cv::Rect>) getCropAreaList:(int)width height:(int)height;

/**
 * @brief 切割输入的图像
 * 图像切割
 *
 * @param inputMat 图像
 */
-(std::vector<cv::Mat>) clippedSourceMat:(cv::Mat)inputMat;

/**
 * @brief 检测图像
 *
 * @param imageMat 图像
 */
-(ZXResult*)detect:(cv::Mat)imageMat;
@end

NS_ASSUME_NONNULL_END
