//
//  OpenCVWrapper.m
//  TestOpenCVSwift
//
//  Created by Denow Cleetus on 25/09/19.
//  Copyright © 2019 Denow Cleetus. All rights reserved.
//

#import "OpenCVWrapper.h"
#ifdef __cplusplus
#undef NO
#undef YES
#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#endif

@implementation OpenCVWrapper

+(NSString *)openCVVersionString
{
    return [NSString stringWithFormat: @"OpenCV Version: %s", CV_VERSION];
}

+ (UIImage *)makeGrayFromImage:(UIImage *)image
{
    // Transform UIImage to cv::Mat
    cv::Mat imageMat;
    UIImageToMat(image, imageMat);
    
    // If the image was already grayscale return it
    if (imageMat.channels() == 1) return image;
    
    // Transform the cv::Mat color image to gray
    cv::Mat grayMat;
    cv::cvtColor(imageMat, grayMat, cv::COLOR_BGR2GRAY);
    
    // Transform grayMat to UIImage and return
    return MatToUIImage(grayMat);
}

+(double)imageVariance:(UIImage *)image
{
    /// variance can be used in identifying sharp details such as edges.
    
    cv::Mat matImage;
    UIImageToMat(image, matImage);
    
    cv::Mat matImageGrey;
    cv::cvtColor(matImage, matImageGrey, cv::COLOR_BGR2GRAY);
    
    cv::Mat laplacianImage;
    Laplacian(matImageGrey, laplacianImage, CV_64F);
    cv::Scalar mean, stddev; // 0:1st channel, 1:2nd channel and 2:3rd channel
    meanStdDev(laplacianImage, mean, stddev, cv::Mat());
    
    double variance = stddev.val[0] * stddev.val[0];
    return variance;
}

+(double)imageBrightness:(UIImage *)image
{
    cv::Mat matImage;
    UIImageToMat(image, matImage);
    cv::Mat hsv;
    cv::cvtColor(matImage, hsv, cv::COLOR_BGR2HSV);
    
    const auto result = cv::mean(hsv);
    double brigtness = result[2];
    
    return brigtness;
}

// MARK: -
// OpenCV port of 'LAPM' algorithm (Nayar89)
double modifiedLaplacian(const cv::Mat& src)
{
    cv::Mat M = (cv::Mat_<double>(3, 1) << -1, 2, -1);
    cv::Mat G = cv::getGaussianKernel(3, -1, CV_64F);
    
    cv::Mat Lx;
    cv::sepFilter2D(src, Lx, CV_64F, M, G);
    
    cv::Mat Ly;
    cv::sepFilter2D(src, Ly, CV_64F, G, M);
    
    cv::Mat FM = cv::abs(Lx) + cv::abs(Ly);
    
    double focusMeasure = cv::mean(FM).val[0];
    return focusMeasure;
}

// OpenCV port of 'LAPV' algorithm (Pech2000)
double varianceOfLaplacian(const cv::Mat& src)
{
    cv::Mat lap;
    cv::Laplacian(src, lap, CV_64F);
    
    cv::Scalar mu, sigma;
    cv::meanStdDev(lap, mu, sigma);
    
    double focusMeasure = sigma.val[0]*sigma.val[0];
    return focusMeasure;
}

// OpenCV port of 'TENG' algorithm (Krotkov86)
double tenengrad(const cv::Mat& src, int ksize)
{
    cv::Mat Gx, Gy;
    cv::Sobel(src, Gx, CV_64F, 1, 0, ksize);
    cv::Sobel(src, Gy, CV_64F, 0, 1, ksize);
    
    cv::Mat FM = Gx.mul(Gx) + Gy.mul(Gy);
    
    double focusMeasure = cv::mean(FM).val[0];
    return focusMeasure;
}

// OpenCV port of 'GLVN' algorithm (Santos97)
double normalizedGraylevelVariance(const cv::Mat& src)
{
    cv::Scalar mu, sigma;
    cv::meanStdDev(src, mu, sigma);
    
    double focusMeasure = (sigma.val[0]*sigma.val[0]) / mu.val[0];
    return focusMeasure;
}

@end
