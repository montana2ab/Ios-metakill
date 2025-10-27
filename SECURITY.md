# Security Policy

## Supported Versions

MetadataKill is currently in beta. We are actively maintaining the following versions:

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Security Principles

MetadataKill is built with privacy and security as core principles:

### Privacy-First Design

- **Zero Data Collection**: No analytics, tracking, or telemetry
- **No Network Access**: All processing happens locally on-device
- **No Third-Party SDKs**: No external dependencies that could compromise privacy
- **On-Device Only**: All metadata removal and file processing is done locally

### Security Features

- **Metadata Removal**: Complete removal of EXIF, GPS, IPTC, XMP from images
- **Video Metadata**: Removal of QuickTime metadata, chapters, and location data
- **No Data Retention**: Temporary files are cleaned up immediately after processing
- **Secure File Handling**: Security-scoped resource handling for document access
- **Privacy Manifest**: Compliant with Apple's privacy requirements

## Reporting a Vulnerability

We take security issues seriously. If you discover a security vulnerability in MetadataKill, please follow these steps:

### How to Report

1. **DO NOT** open a public issue
2. Send a detailed report to the repository maintainers via:
   - GitHub Security Advisories (preferred): Navigate to the Security tab
   - Email: Create a private security advisory

### What to Include

Please include the following information in your report:

- Description of the vulnerability
- Steps to reproduce the issue
- Affected versions
- Potential impact
- Suggested fix (if available)
- Your contact information (if you'd like to be credited)

### What to Expect

- **Acknowledgment**: We will acknowledge receipt of your vulnerability report within 48 hours
- **Updates**: We will provide updates on the status of your report every 5-7 days
- **Timeline**: We aim to release a fix within 30 days for critical issues
- **Credit**: With your permission, we will credit you in the security advisory and release notes

## Security Best Practices for Users

When using MetadataKill:

1. **Original Files**: Keep backups of original files before cleaning
2. **Verify Output**: Review cleaned files to ensure they meet your needs
3. **Sensitive Data**: While MetadataKill removes metadata, be aware that image/video content itself may contain sensitive information
4. **Permissions**: Only grant necessary permissions (Photos, Files) when prompted
5. **Updates**: Keep the app updated to receive latest security improvements

## Security Considerations in Code

### For Contributors

When contributing to MetadataKill, please follow these security guidelines:

1. **No Network Calls**: Never add code that makes network requests
2. **No Logging of Sensitive Data**: Do not log file paths, names, or metadata content
3. **Input Validation**: Validate all user inputs and file operations
4. **Error Handling**: Handle errors gracefully without exposing sensitive information
5. **Dependencies**: Avoid adding dependencies; if necessary, thoroughly vet them
6. **Code Review**: All code must be reviewed for security implications

### Known Security Boundaries

- **File Content**: MetadataKill removes metadata but does not analyze or modify image/video content
- **Filesystem Permissions**: App operates within iOS sandbox restrictions
- **File Deletion**: When delete option is enabled, files are deleted using standard iOS APIs (not secure overwrite)
- **Memory**: Sensitive metadata may temporarily exist in memory during processing

## Responsible Disclosure

We follow coordinated vulnerability disclosure principles:

1. Security issues are kept confidential until a fix is released
2. We work with reporters to understand and verify issues
3. We publicly acknowledge reporters (with permission) after fixes are released
4. We release security advisories through GitHub Security Advisories

## Security Audits

- **Last Security Review**: October 2025
- **Next Planned Review**: Before v1.0 public release
- **Scope**: All data processing, file handling, and privacy-related code

## Additional Resources

- [Privacy Policy](PRIVACY.md)
- [Contributing Guidelines](CONTRIBUTING.md)
- [Architecture Documentation](ARCHITECTURE.md)

## Questions?

If you have questions about security that don't involve reporting a vulnerability:

- Open a GitHub Discussion in the Security category
- Review existing documentation in PRIVACY.md

---

**Note**: This security policy applies to the MetadataKill application code. For security issues with dependencies or platform (iOS/Swift), please report to the appropriate upstream projects.

Last Updated: October 2025
