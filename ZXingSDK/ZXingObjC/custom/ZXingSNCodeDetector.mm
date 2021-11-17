//
//  ZXingSNCodeDetector.m
//  ZXingSDK
//
//  Created by Jianglun Jin on 2021/11/17.
//

#import <cmath>
#import <opencv2/opencv.hpp>
#import <opencv2/imgproc/types_c.h>
#import <opencv2/objdetect/objdetect.hpp>
#import <opencv2/imgproc/imgproc_c.h>
#import <opencv2/highgui.hpp>
#import <opencv2/core/types_c.h>
#import "ZXingSNCodeDetector.h"
#import "ZXingMatSupperScale.h"
#import "ZXDecodeHints.h"
#import "ZXBinaryBitmap.h"
#import "ZXGlobalHistogramBinarizer.h"
#import "ZXingCvMatSource.h"

///自动转化输入的图片为灰度图
inline bool safeBGR2GrayImage(cv::InputArray img, cv::Mat &gray)
{
    if (img.empty() || img.cols() <= 20 || img.rows() <= 20)
    {
        return false;
    }

    int incnt = img.channels();
    if (incnt == 3 || incnt == 4)
    {
        cvtColor(img, gray,cv::COLOR_BGR2GRAY);
    }
    else
    {
        gray = img.getMat();
    }
    return true;
}

// 二阈值测试
bool thresholdScanSNImage(cv::Mat &input_mat,cv::Mat &output_mat,const int black = 100,const int white = 255) {
    if(!input_mat.data || input_mat.empty()) {
        return false;
    }

    //将UIImage转换成Mat
    cv::Mat resultImage = input_mat.clone();

    //转化为灰度图
    cv::Mat gray_mat;
    bool res = safeBGR2GrayImage(input_mat,gray_mat);
    if(!res) {
        return false;
    }

    //利用阈值二值化
    cv::threshold(resultImage, resultImage, black, white, CV_THRESH_BINARY);

    //腐蚀，填充（腐蚀是让黑色点变大）
    cv::Mat erodeElement = getStructuringElement(cv::MORPH_RECT, cv::Size(25,25)); //3535
    cv::erode(resultImage, resultImage, erodeElement);

    // 轮廊检测
    std::vector<std::vector<cv::Point>> contours;
    cv::findContours(resultImage, contours, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, cvPoint(0, 0));
    if(contours.empty()) {
        return false;
    }

    std::vector<cv::Rect> rects;
    cv::Rect snRect = cv::Rect(0,0,0,0);
    double maxArea = 0.0;
    for (auto itContours = contours.begin(); itContours != contours.end(); ++itContours) {
        cv::Rect rect = cv::boundingRect(*itContours);

        ///这里获取的最大外边去掉
        float areaSize = cv::contourArea(*itContours);
        if(rect.size() == resultImage.size() || areaSize < 30) {
            continue;
        }

        if(areaSize > maxArea) {
            snRect = rect;
            maxArea = areaSize;
        }
    }

    // 定位失败
    if (snRect.width == 0 || snRect.height == 0) {
        return false;
    }

    // 定位成功
    output_mat = input_mat(snRect);
    return true;
}

@interface ZXingSNCodeDetector()
@property (nonatomic, strong) ZXingMatSupperScale   *supperScale;
@property (nonatomic, strong) ZXMultiFormatReader   *reader;
@end

@implementation ZXingSNCodeDetector


- (instancetype)init {
    self = [super init];
    if(self) {
        _supperScale = [[ZXingMatSupperScale alloc] init];
        _reader = [[ZXMultiFormatReader alloc] init];
        _reader.hints = [ZXDecodeHints hints];
    }
    return self;
}

- (std::vector<float>) getScaleList:(int)width height:(int)height {
    if (width < 320 || height < 320) return {1.0, 2.0, 0.5};
    if (width < 640 && height < 640) return {1.0, 0.5};
    return {1.0,0.8};
}

-(std::vector<cv::Rect>) getCropAreaList:(int)width height:(int)height {
    //全部区域
    cv::Rect rect1 = cv::Rect(0,0,width,height);

    //中间区域 (中心区域方框)
    float min_size = std::min(width,height);
    cv::Rect rect2 = cv::Rect((width - min_size)/2.0,(height - min_size)/2.0,min_size,min_size);

    //下半部分
    cv::Rect rect3 = cv::Rect(0,height/2.0,width,height/2.0);

    return {rect1,rect2,rect3};
}

-(std::vector<cv::Mat>) clippedSourceMat:(cv::Mat)inputMat {
    
    if(!inputMat.data || inputMat.empty()) {
        return {};
    }
    
    std::vector<cv::Mat> results;
    cv::Mat src_mat;
    if(!safeBGR2GrayImage(inputMat, src_mat)) {
        return {};
    }
    
    int matWidth = inputMat.size().width;
    int matHeight = inputMat.size().height;
    std::vector<cv::Rect> rect_list = [self getCropAreaList:matWidth height:matHeight];
    for(auto iter_area = rect_list.begin();iter_area != rect_list.end(); ++iter_area) {
        auto rect = *iter_area;
        if(rect.width == 0 && rect.height == 0) {
            continue;
        }

        cv::Mat cropped_mat = src_mat(rect);
        std::vector<float> scales = [self getScaleList:matWidth height:matHeight];
        for(int i = 0; i < scales.size(); i ++) {
            float cur_scale = scales[i];
            cv::Mat scaled_image;
            cv::Mat threshold_mat;
            if(thresholdScanSNImage(cropped_mat,threshold_mat)) {
                scaled_image = [_supperScale processImageScale:threshold_mat scale:cur_scale];
            } else {
                scaled_image = [_supperScale processImageScale:cropped_mat scale:cur_scale];
            }
            results.emplace_back(scaled_image);
        }
    }
    
    return results;
}

-(ZXResult*)detect:(cv::Mat)imageMat {
    
    if(!imageMat.data || imageMat.empty()) {
        return nil;
    }
    
    NSError *error;
    ZXingCvMatSource *source = [ZXingCvMatSource create:imageMat];
    ZXGlobalHistogramBinarizer *binarizer = [ZXGlobalHistogramBinarizer binarizerWithSource:source];
    ZXBinaryBitmap *binaryBitmap = [ZXBinaryBitmap binaryBitmapWithBinarizer:binarizer];
    ZXResult *result = [_reader decodeWithState:binaryBitmap error:&error];
    if(result && error == nil) {
        return result;
    }
    
    return nil;
}
@end
