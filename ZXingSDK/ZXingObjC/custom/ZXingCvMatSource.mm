//
//  ZXingCvMatSource.m
//  ZXingSDK
//
//  Created by Jianglun Jin on 2021/11/17.
//

#import "ZXingCvMatSource.h"
#import "ZXByteArray.h"
#import "ZXBitArray.h"

@interface ZXingCvMatSource()
{
    cv::Mat _cvImage;
}
@end

@implementation ZXingCvMatSource

+ (ZXingCvMatSource*) create:(cv::Mat)cvImage {
    return [[ZXingCvMatSource alloc] initWithCvImage:cvImage];
}

- (instancetype)initWithCvImage:(cv::Mat)cvImage {
    if(!cvImage.data || cvImage.empty()) {
        return nil;
    }
    
    self = [super initWithWidth:cvImage.size().width height:cvImage.size().height];
    if(self) {
        _cvImage = cvImage.clone();
    }
    
    return self;
}

- (ZXByteArray *)rowAtY:(int)y row:(ZXByteArray *)row {
    // Get width
    int width = [self width];
    if (!row) {
        // Create row
        row = [[ZXByteArray alloc] initWithLength:(width)];
    }

    // Get pointer to row
    const char *p = _cvImage.ptr<char>(y);
    for(int x = 0; x < width; ++x, ++p) {
        // Set row at index x
        row.array[x] = *p;
    }
    return row;
}

- (ZXByteArray *)matrix {
    // Get width and height
    int width = [self width];
    int height = [self height];

    // Create matrix
    ZXByteArray *matrix = [[ZXByteArray alloc] initWithLength:(width * height)];
    for (int y = 0; y < height; ++y) {

       // Get pointer to row
       const char *p = _cvImage.ptr<char>(y);
       // Calculate y offset
       int yoffset = y * width;
       for(int x = 0; x < width; ++x, ++p) {
           // Set row at index x with y offset
           matrix.array[yoffset + x] = *p;
       }
    }

    return matrix;
}
@end
