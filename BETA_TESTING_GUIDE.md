# Beta Testing Guide - MetadataKill

## 🎯 Welcome Beta Testers!

Thank you for participating in MetadataKill beta testing. This guide will help you thoroughly test the app and provide valuable feedback.

**Beta Version:** 1.0.0  
**Build Date:** 2025-10-20  
**Target Platform:** iOS 15.0+

---

## 📱 Getting Started

### Installation
1. Download TestFlight from the App Store
2. Open the invitation link
3. Install MetadataKill Beta
4. Grant photo library permissions when prompted

### First Launch
1. Open MetadataKill
2. Read the welcome screen
3. Choose your preferred language (English or Français)
4. Explore the main menu

---

## 🧪 Test Scenarios

### A. Image Cleaning Tests

#### Test A1: Single Image Processing
**Objective:** Verify basic image metadata removal

**Steps:**
1. Open Image Cleaner
2. Tap "Select from Photos"
3. Choose a single photo with GPS data
4. Tap "Clean 1 Photo"
5. Wait for processing
6. Check results

**Expected Results:**
- ✅ Photo processes successfully
- ✅ GPS removed indicator shown
- ✅ Processing time displayed
- ✅ Cleaned photo saved

**Report If:**
- ❌ Processing fails
- ❌ GPS not removed
- ❌ App crashes
- ❌ Long processing time (>10s for 12MP)

#### Test A2: Batch Image Processing
**Objective:** Test multiple image processing

**Steps:**
1. Open Image Cleaner
2. Select 10-20 photos
3. Start cleaning
4. Observe progress bar
5. Check all results

**Expected Results:**
- ✅ Progress updates smoothly
- ✅ All images processed
- ✅ Results show success/failure for each
- ✅ Can cancel during processing

**Report If:**
- ❌ Progress freezes
- ❌ Some images fail
- ❌ Memory issues
- ❌ Cancel doesn't work

#### Test A3: Different Image Formats
**Objective:** Test format compatibility

**Test with:**
- [ ] JPEG
- [ ] HEIC
- [ ] PNG
- [ ] WebP (if available)
- [ ] Live Photos

**Expected Results:**
- ✅ All supported formats work
- ✅ Format converted correctly (HEIC→JPEG if enabled)
- ✅ Quality maintained

### B. Video Cleaning Tests

#### Test B1: Single Video Processing
**Objective:** Verify video metadata removal

**Steps:**
1. Open Video Cleaner
2. Select a video with location
3. Choose processing mode (try all 3)
4. Clean video
5. Check results

**Processing Modes to Test:**
- [ ] Fast Copy (re-mux)
- [ ] Safe Re-encode
- [ ] Smart Auto

**Expected Results:**
- ✅ Video processes successfully
- ✅ Location metadata removed
- ✅ Video plays correctly
- ✅ Quality acceptable

#### Test B2: Large Video Files
**Objective:** Test with large videos

**Test with:**
- [ ] 1-2 minute video (~50MB)
- [ ] 5-10 minute video (~200MB)
- [ ] 4K video if available

**Expected Results:**
- ✅ Progress updates during processing
- ✅ No memory issues
- ✅ Reasonable processing time
- ✅ Can cancel if needed

### C. Batch Processing Tests

#### Test C1: Mixed Media Batch
**Objective:** Process images and videos together

**Steps:**
1. Open Batch Processor
2. Select mix of photos and videos
3. Process all
4. Check results

**Expected Results:**
- ✅ Both types processed correctly
- ✅ Progress accurate
- ✅ Results separated properly

### D. Settings Tests

#### Test D1: Language Switching
**Objective:** Verify bilingual support

**Steps:**
1. Open Settings
2. Change language
3. Restart app
4. Verify all text translated

**Test in:**
- [ ] English
- [ ] Français

**Expected Results:**
- ✅ All UI text in chosen language
- ✅ Error messages localized
- ✅ Consistent translations

#### Test D2: Quality Settings
**Objective:** Test quality sliders

**Steps:**
1. Open Settings
2. Adjust HEIC Quality (50%-100%)
3. Adjust JPEG Quality (50%-100%)
4. Process images
5. Check file sizes

**Expected Results:**
- ✅ Sliders work smoothly
- ✅ Quality changes affect output
- ✅ Lower quality = smaller files

#### Test D3: Delete Original Files
**Objective:** Test deletion feature

**Steps:**
1. Enable "Delete Original File" in Settings
2. Process a test image
3. Confirm deletion warning
4. Check Photos app

**Expected Results:**
- ⚠️ Warning dialog appears
- ✅ Original deleted after confirmation
- ✅ Cleaned version saved
- ✅ Success message shown

**IMPORTANT:** Use test photos you can delete!

### E. Error Handling Tests

#### Test E1: Invalid File
**Objective:** Test error messages

**Steps:**
1. Try to process corrupted image
2. Try to process unsupported format
3. Try with no storage space

**Expected Results:**
- ✅ Clear error message
- ✅ Recovery suggestion provided
- ✅ Can continue using app

#### Test E2: Permission Errors
**Objective:** Test permission handling

**Steps:**
1. Revoke photo permissions
2. Try to select photos
3. Check error message

**Expected Results:**
- ✅ Permission error shown
- ✅ Guidance to Settings provided

### F. Performance Tests

#### Test F1: Memory Usage
**Objective:** Check for memory leaks

**Steps:**
1. Process 50+ images in batch
2. Monitor memory usage
3. Check for app slowdown

**Monitor:**
- iPhone/iPad Settings > Battery > Battery Usage
- Look for high energy usage

**Expected Results:**
- ✅ Memory stays reasonable
- ✅ No app slowdown
- ✅ No thermal throttling

#### Test F2: Battery Impact
**Objective:** Assess battery consumption

**Steps:**
1. Note battery level
2. Process large batch
3. Check battery drain

**Expected Results:**
- ✅ Reasonable battery usage
- ✅ Consistent with processing time

---

## 🐛 Bug Reporting

### How to Report Issues

**Use this template:**

```
**Issue Title:** Clear, one-line description

**Device:** iPhone/iPad model, iOS version
**App Version:** MetadataKill Beta 1.0.0
**Language:** English/Français

**Steps to Reproduce:**
1. Step one
2. Step two
3. Step three

**Expected Result:**
What should happen

**Actual Result:**
What actually happened

**Frequency:**
- [ ] Always
- [ ] Sometimes
- [ ] Once

**Screenshots/Videos:**
Attach if possible

**Additional Notes:**
Any other relevant information
```

### Priority Levels

**🔴 Critical (Report Immediately):**
- App crashes
- Data loss
- Privacy violations
- Photos/videos corrupted

**🟡 High Priority:**
- Features not working
- Wrong error messages
- Performance issues
- Incorrect translations

**🟢 Low Priority:**
- UI issues
- Minor text errors
- Suggestions
- Nice-to-have features

---

## 💬 Feedback Categories

### What We Want to Know

#### 1. Usability
- Is the app easy to use?
- Are labels clear?
- Is navigation intuitive?
- Any confusing parts?

#### 2. Performance
- How fast is processing?
- Any lag or freezing?
- Battery drain acceptable?
- Memory usage reasonable?

#### 3. Reliability
- Does it work consistently?
- Any crashes or errors?
- Results accurate?
- Features work as expected?

#### 4. Design
- UI attractive?
- Colors and fonts good?
- Dark mode works well?
- Layout comfortable?

#### 5. Localization
- Translations accurate?
- Any awkward phrasing?
- Missing translations?
- Cultural appropriateness?

---

## ✅ Testing Checklist

### Core Features
- [ ] Image cleaning works
- [ ] Video cleaning works
- [ ] Batch processing works
- [ ] Settings persist
- [ ] Results accurate
- [ ] Error handling good

### User Experience
- [ ] UI responsive
- [ ] Progress indicators clear
- [ ] Error messages helpful
- [ ] Navigation smooth
- [ ] Looks professional

### Localization
- [ ] English complete
- [ ] French complete
- [ ] No hardcoded strings
- [ ] Translations accurate

### Performance
- [ ] Fast processing
- [ ] Low memory usage
- [ ] Reasonable battery
- [ ] No thermal issues

### Edge Cases
- [ ] Large files handled
- [ ] Many files in batch
- [ ] Low storage handled
- [ ] Permission errors clear
- [ ] Network errors handled

---

## 📊 Feedback Form

**Optional but Helpful:**

### Overall Rating
- [ ] ⭐⭐⭐⭐⭐ Excellent
- [ ] ⭐⭐⭐⭐ Good
- [ ] ⭐⭐⭐ Average
- [ ] ⭐⭐ Needs Work
- [ ] ⭐ Poor

### Would You Recommend?
- [ ] Yes, definitely
- [ ] Yes, with improvements
- [ ] Maybe
- [ ] No

### Best Features
What do you like most?

### Worst Issues
What needs improvement?

### Missing Features
What would you add?

---

## 🙏 Thank You!

Your feedback is invaluable. Every bug report, suggestion, and comment helps make MetadataKill better.

**Contact:**
- GitHub Issues: [Issue Tracker](https://github.com/montana2ab/Ios-metakill/issues)
- TestFlight: Use feedback button in TestFlight app

**Testing Period:** Until [DATE]

---

## 📚 Resources

### Documentation
- [README](README.md) - Full documentation
- [Privacy Policy](PRIVACY.md) - Privacy information
- [Architecture](ARCHITECTURE.md) - Technical details

### Support
- Check documentation first
- Search existing issues
- Ask in discussions
- Contact maintainers

---

**Happy Testing! 🚀**

*MetadataKill Team*
