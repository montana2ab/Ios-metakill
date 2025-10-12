# Privacy Policy - MetadataKill

**Last Updated**: 2025-01-12

## Our Commitment

MetadataKill is designed with privacy as the foundation. We believe your photos, videos, and metadata should remain private and under your control.

## What We DO

✅ **Process Everything Locally**: All metadata removal happens on your device  
✅ **Work Offline**: The app functions completely without internet connection  
✅ **Preserve Your Files**: Original files remain untouched (unless you choose to replace)  
✅ **Provide Transparency**: Open-source code for full audit capability  

## What We DON'T Do

❌ **NO Data Collection**: We don't collect, store, or transmit any of your data  
❌ **NO Analytics**: No usage tracking, crash reports, or telemetry  
❌ **NO Cloud Services**: No iCloud sync, no external servers  
❌ **NO Advertising**: No ad networks or third-party SDKs  
❌ **NO Account Required**: No sign-up, login, or user profiles  

## Permissions We Request

### Photo Library Access
- **Purpose**: To read photos/videos you want to clean
- **Scope**: Limited access (only items you explicitly select)
- **Usage**: Files are read, processed, and saved back locally
- **Storage**: Cleaned files saved to your device's Documents folder

### File System Access (Optional)
- **Purpose**: To import files from Files app
- **Scope**: Only files you explicitly select
- **Usage**: Temporary access for processing only

## Data Processing

### What Happens to Your Files

1. **Selection**: You choose which files to process
2. **Reading**: File data is read into memory on your device
3. **Processing**: Metadata is removed using iOS frameworks
4. **Writing**: Clean file is saved to your device
5. **Cleanup**: Temporary data is deleted

### No Network Activity

The app:
- Does not make any network connections
- Does not communicate with external servers
- Does not upload or download any data
- Functions identically with or without internet

You can verify this by:
- Enabling Airplane Mode
- Using network monitoring tools
- Reviewing the source code

## Optional Logging

The app includes an **opt-in** private logging feature:

- **Default**: Disabled
- **Purpose**: Help diagnose technical issues
- **Content**: Processing times, error types (no file names or metadata)
- **Storage**: Encrypted, stored locally only
- **Sharing**: Only if you manually export and share logs
- **Deletion**: Logs can be cleared anytime from Settings

Example log entry (anonymized):
```
[2025-01-12 10:30:15] Image processing completed in 1.2s
[2025-01-12 10:30:16] Removed 8 metadata fields
[2025-01-12 10:30:16] Error: Insufficient space
```

## Third-Party Code

MetadataKill may include:
- **Apple Frameworks**: iOS system frameworks (ImageIO, AVFoundation, etc.)
- **Open Source Libraries**: Listed in Package.swift

All dependencies are vetted for privacy compliance.

## Children's Privacy

This app is safe for users of all ages. Since we don't collect any data, there are no special considerations for children under 13.

## Data Security

Your data security is ensured by:
- **Local Processing**: Data never leaves your device
- **System Security**: Protected by iOS security features
- **No Cloud Storage**: No data stored on external servers
- **Secure Deletion**: Temporary files are properly cleaned up

## Your Rights

You have complete control:
- **Access**: All your data stays on your device
- **Deletion**: Delete cleaned files anytime
- **Portability**: Files are standard formats
- **Transparency**: View source code on GitHub

## Changes to This Policy

We may update this privacy policy:
- To reflect app improvements
- To clarify existing practices
- In response to user feedback

Updates will be posted on:
- GitHub repository
- App Store listing
- In-app changelog

## Compliance

MetadataKill complies with:
- Apple App Store Privacy Guidelines
- GDPR (EU General Data Protection Regulation)
- CCPA (California Consumer Privacy Act)
- Other privacy regulations (by design)

### Apple Privacy Nutrition Label

**Data Not Collected**

This app does not collect any data.

### Privacy Manifest

The app includes a Privacy Manifest (`PrivacyInfo.xcprivacy`) declaring:
- No tracking
- No data collection
- Photo Library access with reason code CA92.1

## Contact

If you have questions about this privacy policy:
- **GitHub**: Open an issue at https://github.com/montana2ab/Ios-metakill/issues
- **Subject**: Privacy Policy Question

## Verification

You can verify our privacy claims:
1. Review source code on GitHub
2. Use network monitoring tools
3. Check iOS Privacy settings
4. Test in Airplane Mode

## Summary

**MetadataKill is truly privacy-first**:
- Zero data collection
- Zero network activity
- Zero tracking
- 100% local processing
- 100% under your control

Your photos, videos, and privacy are safe with MetadataKill.
