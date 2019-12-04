//
//  OpenCVWrapper.h
//  TestOpenCVSwift
//
//  Created by Denow Cleetus on 25/09/19.
//  Copyright © 2019 Denow Cleetus. All rights reserved.
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
