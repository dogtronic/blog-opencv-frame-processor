#import <Foundation/Foundation.h>
#import <VisionCamera/FrameProcessorPlugin.h>
#import <VisionCamera/Frame.h>
#import <opencv2/opencv.hpp>
#import "OpenCV.h"

@interface ObjectDetectFrameProcessor : NSObject
@end

@implementation ObjectDetectFrameProcessor

static inline id objectDetect(Frame* frame, NSArray* args) {
  CMSampleBufferRef buffer = frame.buffer;
  return [OpenCV findObjects:[OpenCV toUIImage:buffer]];
}

VISION_EXPORT_FRAME_PROCESSOR(objectDetect)

@end
