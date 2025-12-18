# How to Improve Bill Scanner Accuracy

## 1. **Improve ML Model Training** (Most Important)

### Retrain with Better Data:
- **More training samples**: Collect 200-500+ images per class (currently you have 10 classes)
- **Diverse lighting conditions**: Include bright, dim, natural, and artificial lighting
- **Different angles**: Include slight rotations and perspective variations
- **Various bill conditions**: New, old, worn, folded, slightly damaged bills
- **Different backgrounds**: White, colored, textured backgrounds
- **Both sides**: Train on both front and back of bills if possible

### Training Tips:
- Use Teachable Machine's "Advanced" settings
- Enable data augmentation during training (flips, rotations, brightness variations)
- Train for more epochs (50-100+)
- Use higher resolution images (at least 224x224, preferably 299x299 or 331x331)
- Balance the dataset - ensure equal samples per class

## 2. **Improve Image Capture Quality**

### Current Settings:
```dart
imageQuality: 90  // In main.dart line 2615
```

### Recommendations:
- Increase to `imageQuality: 95` or `100` for better detail
- Add image resolution requirements (minimum 1024x1024)
- Implement focus checking before capture
- Add exposure/white balance adjustment

## 3. **Enhance Image Preprocessing**

### Current Enhancement:
```dart
contrast: 1.05
brightness: 1.02
```

### Improvements to Consider:
- **Noise reduction**: Apply denoising filter for low-light images
- **Sharpening**: Apply unsharp mask to enhance edges
- **Histogram equalization**: Normalize brightness distribution
- **Adaptive thresholding**: Better contrast in varying lighting
- **Color space conversion**: Try LAB or HSV for better feature extraction

## 4. **Optimize Test-Time Augmentation**

### Current Augmentation:
- 5 variations (original, brighter, darker, higher contrast, lower contrast)

### Additional Augmentations:
- **Rotation**: ±5 degrees
- **Slight scaling**: 0.95x to 1.05x
- **Gamma correction**: Different gamma values
- **Color jitter**: Slight hue/saturation variations

## 5. **Adjust Confidence Threshold**

### Current Setting:
```dart
minConfidenceThreshold = 0.5
```

### Recommendations:
- **For production**: Increase to 0.7-0.8 to reduce false positives
- **For testing**: Lower to 0.3-0.4 to see all predictions
- **Dynamic threshold**: Use different thresholds per class based on training performance

## 6. **Add Image Quality Checks**

Before processing, validate:
- **Focus**: Check image sharpness (variance of Laplacian)
- **Brightness**: Ensure adequate lighting (not too dark/bright)
- **Blur detection**: Reject blurry images
- **Bill coverage**: Ensure bill occupies sufficient area of image

## 7. **Improve Matching Logic**

### Current Approach:
- Basic value + material matching

### Enhancements:
- **Confidence-weighted matching**: Use prediction scores more effectively
- **Ensemble methods**: Combine multiple predictions
- **Post-processing rules**: Add domain knowledge (e.g., polymer bills are newer)

## 8. **User Guidance**

Improve scanning guidelines:
- **Distance**: Optimal distance from bill (e.g., 20-30cm)
- **Lighting**: Use diffused white light
- **Angle**: Hold camera parallel to bill
- **Stability**: Wait for focus before capturing
- **Coverage**: Ensure entire bill is visible

## 9. **Model Architecture**

If retraining from scratch:
- **Use EfficientNet**: Better accuracy than MobileNet
- **Larger input size**: 299x299 or 331x331 instead of 224x224
- **Transfer learning**: Start with pre-trained ImageNet weights
- **Fine-tuning**: Fine-tune all layers, not just the classifier

## 10. **Data Collection Strategy**

### Systematic Collection:
1. **Controlled environment**: Take photos in consistent lighting
2. **Multiple devices**: Train on images from different cameras/phones
3. **Real-world scenarios**: Include actual user-captured images
4. **Edge cases**: Focus on difficult cases (similar bills, poor lighting)

## Quick Wins (Easy to Implement):

1. ✅ Increase `imageQuality` to 95-100
2. ✅ Add more test-time augmentations (rotation, scaling)
3. ✅ Improve image enhancement (sharpen, denoise)
4. ✅ Add image quality validation before processing
5. ✅ Adjust confidence threshold based on your needs

## Long-term Improvements:

1. 🔄 Retrain model with more diverse data
2. 🔄 Use better model architecture (EfficientNet)
3. 🔄 Implement ensemble predictions
4. 🔄 Add active learning (collect difficult cases for retraining)
5. 🔄 A/B test different preprocessing pipelines

## Expected Impact:

- **Better training data**: +15-30% accuracy
- **Improved preprocessing**: +5-10% accuracy
- **More augmentations**: +3-5% accuracy
- **Higher image quality**: +2-5% accuracy
- **Quality checks**: +5-10% (by rejecting bad images)

**Total potential improvement: 30-60% accuracy increase**

