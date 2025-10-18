# 🚀 MetadataKill - TestFlight Beta Testing Guide

## Welcome Beta Testers! 🎉

Thank you for helping us test **MetadataKill** - the privacy-first metadata cleaning app for iOS!

---

## 📋 What is MetadataKill?

MetadataKill removes all metadata (EXIF, GPS, IPTC, XMP) from your photos and videos, protecting your privacy by:
- ✅ Removing GPS location data
- ✅ Cleaning camera/device information
- ✅ Stripping timestamps and other sensitive data
- ✅ Processing 100% on-device (no cloud, no tracking)

---

## 🎯 Testing Instructions

### Getting Started

1. **Install the app** from TestFlight
2. **Grant necessary permissions** when prompted:
   - Photo Library access (for selecting photos to clean)
   - Files access (for selecting files to clean)
3. **Choose your language**: English or French (auto-detected)

### What to Test

#### 🖼️ Image Cleaning

**Test 1: Single Image**
1. Tap **"Clean Photos"** on the home screen
2. Select **"Select from Photos"** or **"Select from Files"**
3. Choose **1 photo** (JPEG, HEIC, or PNG)
4. Tap **"Clean 1 Photo"**
5. Wait for processing to complete
6. Verify the cleaned image is saved

**Test 2: Batch Processing - 10 Images**
1. Go to **"Clean Photos"**
2. Select **10 JPEG images** from your library or files
3. Tap **"Clean 10 Photos"**
4. Monitor the progress indicator
5. Verify all 10 images are processed successfully
6. Check the results for metadata removal stats

**Test 3: Live Photo**
1. Go to **"Clean Photos"**
2. Select a **Live Photo** from your Photo Library
3. Clean it
4. Verify both the photo and video components are processed
5. Check that the Live Photo functionality is preserved (if applicable)

#### 🎬 Video Cleaning

**Test 4: Single Video**
1. Tap **"Clean Videos"** on the home screen
2. Select a video file
3. Choose processing mode in Settings if desired (Fast Copy, Safe Re-encode, Smart Auto)
4. Tap **"Clean 1 Video"**
5. Wait for processing (may take longer for large files)
6. Verify the cleaned video is saved

**Test 5: 4K Video**
1. Go to **"Clean Videos"**
2. Select a **4K video** (3840×2160 or higher)
3. Clean it using the default settings
4. Verify:
   - Processing completes without crashes
   - Output video maintains quality
   - File size is reasonable
   - Video plays correctly

#### ⚙️ Settings & Configuration

**Test 6: Settings**
1. Go to **Settings**
2. Try changing:
   - Language (English ↔ French)
   - Metadata removal options
   - Image quality settings
   - Video processing mode
   - Output mode (Replace Original, New Copy, etc.)
3. Verify settings are saved and persist after app restart

#### 🔄 Batch Processing

**Test 7: Mixed Media Batch**
1. Tap **"Batch Processing"**
2. Select a mix of photos and videos
3. Process them together
4. Verify all files are handled correctly

---

## ⚠️ Known Issues

The following issues are already known and being worked on:

1. **UI Test Integration**: UI tests are basic and require manual intervention for file selection
2. **Large File Processing**: Very large 4K videos (>1GB) may take several minutes to process
3. **Memory Usage**: Processing many large files simultaneously may cause memory warnings on older devices
4. **Live Photo Export**: Cleaned Live Photos may lose their "live" effect when exported (depends on output format)
5. **Localization**: Some system dialogs may still appear in device language rather than app language
6. **Background Processing**: App may not process files if backgrounded for extended periods

---

## 📸 Test Files We Need

Please help us test with diverse file types! We're looking for:

### Images
- ✅ JPEG from various cameras (iPhone, DSLR, Android)
- ✅ HEIC files (iOS native format)
- ✅ PNG files with metadata
- ✅ RAW files (DNG, CR2, NEF, ARW)
- ✅ Images with GPS data
- ✅ Images without GPS data
- ✅ Very high resolution images (>20MP)
- ✅ Live Photos

### Videos
- ✅ 4K videos (3840×2160)
- ✅ 1080p videos
- ✅ 720p videos
- ✅ Videos from iPhone
- ✅ Videos from other devices
- ✅ Videos with GPS metadata
- ✅ Short clips (<10 seconds)
- ✅ Longer videos (>5 minutes)
- ✅ Videos with chapters
- ✅ HDR videos

**How to Share Test Files:**
If you have interesting test cases or files that cause issues, please note them in your feedback!

---

## 🐛 How to Report Issues

When reporting bugs or issues, please include:

1. **Device Information**
   - iPhone model (e.g., iPhone 14 Pro)
   - iOS version (e.g., iOS 17.1)

2. **Steps to Reproduce**
   - What you were trying to do
   - What happened vs. what you expected
   - Can you reproduce it consistently?

3. **File Information** (if applicable)
   - File type (JPEG, HEIC, MP4, etc.)
   - Approximate file size
   - Resolution (for images/videos)
   - Source (iPhone camera, downloaded, etc.)

4. **Screenshots or Screen Recordings**
   - Very helpful for UI issues!

5. **Logs** (if app crashes)
   - Check Settings > Privacy > Analytics > Analytics Data
   - Look for "MetadataKill" crash logs

---

## 📊 What We're Measuring

We're collecting **anonymous** metrics via MetricKit to improve performance:

- ✅ App launch time
- ✅ Processing performance
- ✅ Memory usage
- ✅ Battery impact
- ✅ Crash reports (if any)

**Note**: All processing is done on-device. No photos, videos, or personal data ever leave your device!

---

## 💡 Tips for Best Results

1. **Free up storage**: Ensure you have enough free space (at least 2GB recommended)
2. **Close other apps**: For best performance when processing large files
3. **Use Wi-Fi for updates**: Beta updates may be frequent
4. **Check Settings**: Explore different processing modes for videos
5. **Test edge cases**: Unusual file formats, very large files, etc.

---

## 🎯 Focus Areas

We especially need feedback on:

1. **Performance**
   - How fast does processing complete?
   - Any lag or freezing?
   - Battery drain during heavy use?

2. **Accuracy**
   - Is metadata actually removed? (You can verify with apps like "ViewExif" or "Metapho")
   - Any metadata left behind?
   - Image/video quality preservation?

3. **User Experience**
   - Is the interface intuitive?
   - Are instructions clear?
   - Any confusing workflows?

4. **Localization** (for French users)
   - Are translations accurate and natural?
   - Any missing translations?
   - Cultural appropriateness?

5. **Stability**
   - Any crashes?
   - Any data loss?
   - App hangs or becomes unresponsive?

---

## 📱 Contact & Feedback

- **TestFlight Feedback**: Use the built-in feedback form (shake device or screenshot)
- **GitHub Issues**: Report detailed bugs at [github.com/montana2ab/Ios-metakill/issues]
- **Email**: [Your contact email]

---

## 🙏 Thank You!

Your testing and feedback are invaluable in making MetadataKill the best privacy tool for iOS. We appreciate your time and effort!

**Happy Testing!** 🚀

---

## 📅 Version History

### Current Beta: v1.0.0 (Build 1)
- Initial beta release
- Core metadata cleaning functionality
- English & French localization
- OSLog integration
- MetricKit monitoring
- Basic UI tests
- Integration tests for metadata verification

### Coming Soon
- More language support
- Advanced settings
- Batch processing improvements
- Export options
- Siri shortcuts integration
