//
//  ZXingScanCodeManager.h
//  ZXingSDK
//
//  Created by Jianglun Jin on 2021/11/17.
//

#import <Foundation/Foundation.h>
#import "ZXResult.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^ZXingScanCodeResultBlock)(NSArray<ZXResult *> *results);

@interface ZXingScanCodeManager : NSObject
+(instancetype)manager;
- (instancetype)init NS_UNAVAILABLE;

/** 开始扫码sn code
 *
 * @image 待扫码的图片
 * @complete 完成结果或者回调
 */
- (void)startScanSNCode:(UIImage*)image completion:(ZXingScanCodeResultBlock) complete;
@end

NS_ASSUME_NONNULL_END
