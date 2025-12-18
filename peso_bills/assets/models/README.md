Place your exported Teachable Machine files in this folder so the Flutter
app can run on-device classification:

1. Export your image project as a TensorFlow Lite model.
2. Copy the `.tflite` file here and rename it to `peso_bills.tflite`.
3. Copy the accompanying labels file and rename it to `labels.txt`.

After the files are in place, run `flutter pub get` and rebuild the app.

