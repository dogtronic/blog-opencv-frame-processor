//
//  OpenCV.h
//  opencvframeprocessor
//
//  Created by Łukasz Kurant on 29/07/2022.
//

#ifndef OpenCV_h
#define OpenCV_h

#include <Foundation/Foundation.h>
#import <UIKit/UIImage.h>
#import <CoreMedia/CMSampleBuffer.h>

@interface OpenCV: NSObject
+ (NSString *) getOpenCVVersion;
+ (UIImage *) toUIImage:(CMSampleBufferRef)samImageBuff;
+ (NSDictionary *)findObjects:(UIImage *)image;
@end

#endif /* OpenCV_h */
