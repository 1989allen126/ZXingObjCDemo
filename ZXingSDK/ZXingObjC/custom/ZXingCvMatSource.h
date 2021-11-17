//
//  ZXingCvMatSource.h
//  ZXingSDK
//
//  Created by Jianglun Jin on 2021/11/17.
//

#import <Foundation/Foundation.h>
#import <opencv2/opencv.hpp>
#import "ZXLuminanceSource.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZXingCvMatSource : ZXLuminanceSource

/** 快速创建LuminanceSource
 *
 * @image 待扫码的图片
 * @complete 实例
 */
+ (ZXingCvMatSource*) create:(cv::Mat)cvImage;

/** 初始化
 *
 * @image 待扫码的图片
 * @complete 实例
 */
- (instancetype)initWithCvImage:(cv::Mat)cvImage;

- (ZXByteArray *)rowAtY:(int)y row:(ZXByteArray *)row;
- (ZXByteArray *)matrix;
@end

NS_ASSUME_NONNULL_END
