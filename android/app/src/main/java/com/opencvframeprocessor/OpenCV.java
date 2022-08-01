package com.opencvframeprocessor;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.ImageFormat;
import android.graphics.Matrix;
import android.graphics.YuvImage;

import com.facebook.react.bridge.WritableNativeMap;

import org.opencv.android.Utils;
import org.opencv.core.Core;
import org.opencv.core.CvType;
import org.opencv.core.Mat;
import org.opencv.core.MatOfPoint;
import org.opencv.core.Rect;
import org.opencv.core.Scalar;
import org.opencv.imgproc.Imgproc;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.List;
import androidx.camera.core.ImageProxy;

public class OpenCV {
    static WritableNativeMap findObjects(Mat matRGB) {
        Scalar lowerBound = new Scalar(90, 120, 120);
        Scalar upperBound = new Scalar(140, 255, 255);

        Mat matBGR = new Mat(), hsv = new Mat();
        List<Mat> channels = new ArrayList<>();

        Imgproc.cvtColor(matRGB, matBGR, Imgproc.COLOR_RGB2BGR);
        Imgproc.cvtColor(matBGR, hsv, Imgproc.COLOR_BGR2HSV);
        Core.inRange(hsv, lowerBound, upperBound, hsv);
        Core.split(hsv, channels);

        List<MatOfPoint> contours = new ArrayList<>();
        Mat hierarchy = new Mat();

        Imgproc.findContours(channels.get(0), contours, hierarchy, Imgproc.RETR_TREE, Imgproc.CHAIN_APPROX_SIMPLE);

        for (int i = 0; i < contours.size(); i++) {
            MatOfPoint contour = contours.get(i);
            double area = Imgproc.contourArea(contour);

            if(area > 3000) {
                Rect rect = Imgproc.boundingRect(contour);
                WritableNativeMap result = new WritableNativeMap();
                result.putInt("x", rect.x);
                result.putInt("y", rect.y);
                result.putInt("width", rect.width);
                result.putInt("height", rect.height);

                return result;
            }
        }

      return new WritableNativeMap();
    }

    static Mat imageToMat(ImageProxy imageProxy) {
        ImageProxy.PlaneProxy[] plane = imageProxy.getPlanes();
        ByteBuffer yBuffer = plane[0].getBuffer();
        ByteBuffer uBuffer = plane[1].getBuffer();
        ByteBuffer vBuffer = plane[2].getBuffer();

        int ySize = yBuffer.remaining();
        int uSize = uBuffer.remaining();
        int vSize = vBuffer.remaining();

        byte[] nv21 = new byte[ySize + uSize + vSize];

        yBuffer.get(nv21, 0, ySize);
        vBuffer.get(nv21, ySize, vSize);
        uBuffer.get(nv21, ySize + vSize, uSize);
        try {
            YuvImage yuvImage = new YuvImage(nv21, ImageFormat.NV21, imageProxy.getWidth(), imageProxy.getHeight(), null);
            ByteArrayOutputStream stream = new ByteArrayOutputStream(nv21.length);
            yuvImage.compressToJpeg(new android.graphics.Rect(0, 0, yuvImage.getWidth(), yuvImage.getHeight()), 90, stream);
            Bitmap bitmap = BitmapFactory.decodeByteArray(stream.toByteArray(), 0, stream.size());
            Matrix matrix = new Matrix();
            matrix.postRotate(90);
            stream.close();
            Bitmap rotatedBitmap = Bitmap.createBitmap(bitmap, 0, 0, bitmap.getWidth(), bitmap.getHeight(), matrix, true);
            Mat mat = new Mat(rotatedBitmap.getWidth(), rotatedBitmap.getHeight(), CvType.CV_8UC4);
            Utils.bitmapToMat(rotatedBitmap, mat);
            return mat;
        } catch (IOException e) {
            e.printStackTrace();
        }
        return null;
    }
}
