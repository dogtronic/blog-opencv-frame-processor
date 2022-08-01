#import <Foundation/Foundation.h>
#import "OpenCV.h"
#import <opencv2/opencv.hpp>
#import <UIKit/UIImage.h>
#import <CoreMedia/CMSampleBuffer.h>

@implementation OpenCV : NSObject

+ (NSString *) getOpenCVVersion {
  return [NSString stringWithFormat:@"Version: %s", CV_VERSION];
}

+ (NSDictionary *)findObjects:(UIImage *)image {
  
  cv::Vec3b lowerBound(90, 120, 120);
  cv::Vec3b upperBound(140, 255, 255);

  cv::Mat matBGR, hsv;
  std::vector<cv::Mat> channels;

  cv::Mat matRGB = [self cvMatFromUIImage:(image)];
  cv::cvtColor(matRGB,matBGR,cv::COLOR_RGB2BGR);
  cv::cvtColor(matBGR,hsv,cv::COLOR_BGR2HSV);
  cv::inRange(hsv, lowerBound, upperBound, hsv);
  cv::split(hsv, channels);
  

  std::vector<std::vector<cv::Point>> contours;
  cv::findContours(channels[0], contours, cv::RETR_TREE, cv::CHAIN_APPROX_SIMPLE );

  std::vector<NSDictionary *> rects;

  for( int i = 0; i< contours.size(); i++ ) {
      double area = contourArea(contours[i],false);
      if (area>3000) {
        cv::Rect rect = cv::boundingRect(contours.at(i));
      
        return @{@"x": [NSNumber numberWithInt:rect.x] , @"y":
                            [NSNumber numberWithInt: rect.y], @"width": [NSNumber numberWithInt:rect.width], @"height": [NSNumber numberWithInt:rect.height] };
      }
  }

  return @{};
}

+ (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
  CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
  CGFloat cols = image.size.width;
  CGFloat rows = image.size.height;
  cv::Mat cvMat(rows, cols, CV_8UC4);
  CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,
                                                 cols,
                                                 rows,
                                                 8,
                                                 cvMat.step[0],
                                                 colorSpace,
                                                 kCGImageAlphaNoneSkipLast |
                                                 kCGBitmapByteOrderDefault);
  CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
  CGContextRelease(contextRef);
  return cvMat;
}

+ (UIImage *) toUIImage:(CMSampleBufferRef)samImageBuff
  {
       CVImageBufferRef imageBuffer =
         CMSampleBufferGetImageBuffer(samImageBuff);
       CIImage *ciImage = [CIImage imageWithCVPixelBuffer:imageBuffer];
       CIContext *temporaryContext = [CIContext contextWithOptions:nil];
       CGImageRef videoImage = [temporaryContext
                         createCGImage:ciImage
                         fromRect:CGRectMake(0, 0,
                         CVPixelBufferGetWidth(imageBuffer),
                         CVPixelBufferGetHeight(imageBuffer))];

       UIImage *image = [[UIImage alloc] initWithCGImage:videoImage];
       CGImageRelease(videoImage);
      return image;
}

+(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat {
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];

    CGColorSpaceRef colorSpace;
    CGBitmapInfo bitmapInfo;

    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
        bitmapInfo = kCGImageAlphaNone | kCGBitmapByteOrderDefault;
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
        // OpenCV defaults to either BGR or ABGR. In CoreGraphics land,
        // this means using the "32Little" byte order, and potentially
        // skipping the first pixel. These may need to be adjusted if the
        // input matrix uses a different pixel format.
        bitmapInfo = kCGBitmapByteOrder32Little | (
            cvMat.elemSize() == 3? kCGImageAlphaNone : kCGImageAlphaNoneSkipFirst
        );
    }

    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);

    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(
        cvMat.cols,                 //width
        cvMat.rows,                 //height
        8,                          //bits per component
        8 * cvMat.elemSize(),       //bits per pixel
        cvMat.step[0],              //bytesPerRow
        colorSpace,                 //colorspace
        bitmapInfo,                 // bitmap info
        provider,                   //CGDataProviderRef
        NULL,                       //decode
        false,                      //should interpolate
        kCGRenderingIntentDefault   //intent
    );

    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);

    return finalImage;
}

@end
