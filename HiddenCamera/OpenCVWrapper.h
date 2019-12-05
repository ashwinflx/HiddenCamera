//
//  HiddenCamera.h
//  HiddenCamera
//
//  Created by qbuser on 21/11/19.
//  Copyright © 2019 QBurst. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenCVWrapper : NSObject

+(NSString *)openCVVersionString;
+(UIImage *)makeGrayFromImage:(UIImage *)image;
+(double)imageVariance:(UIImage *)image;
+(double)imageBrightness: (UIImage *)image;


@end

NS_ASSUME_NONNULL_END
