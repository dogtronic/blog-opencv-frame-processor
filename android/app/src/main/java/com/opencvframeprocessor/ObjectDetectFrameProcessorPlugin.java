package com.opencvframeprocessor;

import androidx.camera.core.ImageProxy;
import com.mrousavy.camera.frameprocessor.FrameProcessorPlugin;

import org.opencv.core.Mat;

public class ObjectDetectFrameProcessorPlugin extends FrameProcessorPlugin {
    @Override
    public Object callback(ImageProxy image, Object[] params) {
        Mat mat = OpenCV.imageToMat(image);
        return OpenCV.findObjects(mat);
    }

    ObjectDetectFrameProcessorPlugin() {
        super("objectDetect");
    }
}
