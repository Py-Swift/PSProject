# Kivy Library Development Guidelines

## Cross-Platform Library Development for Desktop and Mobile

This document outlines best practices and important considerations when creating Python libraries for Kivy applications that target both desktop (macOS, Linux, Windows) and mobile platforms (iOS, Android).

---

## Platform Support Awareness

### Binary Dependencies

When choosing to use binary libraries as dependencies, **it is critical to ensure that mobile platforms have supporting wheels available**. Many Python packages with C extensions or binary components are only built for desktop platforms.

#### Required Checks:
- ✅ Verify wheel availability on PyPI for both `iphoneos` and `android` platforms
- ✅ Check the package's supported platforms before adding as a dependency
- ✅ Test actual installation on target mobile platforms

### Platform-Specific Library Support

Always clearly document platform limitations in your library's README and documentation:

#### Android-Only Support
```markdown
⚠️ **Platform Notice**: This library only supports Android mobile devices.
Desktop platforms (macOS, Linux, Windows) are supported, but iOS is not available.
```

**When to use**: If your library depends on Android-specific APIs or packages that have no iOS equivalent.

#### iOS-Only Support
```markdown
⚠️ **Platform Notice**: This library only supports iOS mobile devices.
Desktop platforms (macOS, Linux, Windows) are supported, but Android is not available.
```

**When to use**: If your library depends on iOS-specific frameworks or packages unavailable on Android.

#### Desktop-Only Support
```markdown
⚠️ **Platform Notice**: This library is for DESKTOP USE ONLY.
Mobile platforms (iOS and Android) are not supported.
```

**When to use**: When your library has dependencies that cannot be compiled or are unavailable for mobile platforms.

---

## Cross-Platform API Design

### Facade Pattern for Platform-Specific Implementations

If you need different implementations for Android and iOS, **always create a unified facade** so that the API remains identical for users on both platforms.

#### Example Structure:

```python
# mylib/__init__.py
import sys

if sys.platform == 'darwin' and hasattr(sys, 'getandroidapilevel'):
    # Android (uses Termux/Pydroid detection)
    from .android_impl import implementation as _impl
elif sys.platform == 'darwin':
    # iOS or macOS
    from .ios_impl import implementation as _impl
else:
    # Desktop fallback
    from .desktop_impl import implementation as _impl

# Expose unified API
def process_data(data):
    """Process data using platform-specific implementation."""
    return _impl.process_data(data)
```

#### Benefits:
- ✅ Users write the same code regardless of platform
- ✅ Easy to test and maintain
- ✅ Clear separation of platform-specific logic
- ✅ Graceful fallbacks for unsupported platforms

---

## Dependencies to Avoid on Mobile

### ❌ Binary Libraries Without Mobile Support

**Problem**: Many C-extension packages are only compiled for desktop platforms.

**Examples of problematic dependencies**:
- Libraries with no `iphoneos` or `android` wheels on PyPI
- Packages requiring system libraries not available on mobile
- Extensions that haven't been cross-compiled for ARM architectures

**Solution**:
- Use pure Python alternatives when possible
- Contribute mobile wheels to upstream projects
- Bundle pre-compiled libraries with your package
- Clearly document desktop-only status if no alternative exists

### ❌ Subprocess-Based Solutions

**Problem**: Spawning subprocesses on mobile platforms is unreliable, sandboxed, and considered bad practice.

**Why to avoid**:
- iOS has strict sandbox restrictions on process execution
- Android limits subprocess capabilities for security
- Mobile apps don't have access to system utilities
- Performance and battery implications
- Unpredictable behavior across devices

**Examples to avoid**:
```python
# ❌ BAD: Don't do this in mobile-compatible libraries
import subprocess
result = subprocess.run(['ffmpeg', '-i', 'input.mp4'], capture_output=True)
```

**Solution**:
- Use Python libraries that provide native APIs (e.g., `av` instead of calling `ffmpeg`)
- Implement functionality in pure Python or use mobile-compatible C extensions
- Use platform-specific APIs through bridges like `pyjnius` (Android) or `pyobjus` (iOS)

---

## Best Practices

### 1. Platform Detection

Use proper platform detection to handle platform-specific code:

```python
import sys
import platform

def is_android():
    return hasattr(sys, 'getandroidapilevel')

def is_ios():
    return sys.platform == 'darwin' and platform.machine().startswith('iP')

def is_mobile():
    return is_android() or is_ios()
```

### 2. Graceful Degradation

Provide fallbacks or clear error messages for unsupported platforms:

```python
def advanced_feature():
    if is_mobile():
        raise NotImplementedError(
            "This feature is only available on desktop platforms. "
            "Mobile support is planned for a future release."
        )
    # Desktop implementation
    ...
```

### 3. Testing on Real Devices

- ✅ Test on actual iOS and Android devices, not just simulators/emulators
- ✅ Verify all dependencies install correctly
- ✅ Check for runtime errors specific to mobile environments
- ✅ Test performance and battery impact

### 4. Documentation

Always include a **Platform Support** section in your README:

```markdown
## Platform Support

| Platform | Support Level |
|----------|--------------|
| Linux    | ✅ Full      |
| macOS    | ✅ Full      |
| Windows  | ✅ Full      |
| Android  | ✅ Full      |
| iOS      | ✅ Full      |
```

Or if limitations exist:

```markdown
## Platform Support

| Platform | Support Level | Notes |
|----------|--------------|-------|
| Linux    | ✅ Full      | |
| macOS    | ✅ Full      | |
| Windows  | ✅ Full      | |
| Android  | ⚠️ Limited   | Feature X not available |
| iOS      | ❌ None      | Binary dependency not available |
```

---

## Dependency Checklist

Before adding any dependency to your library, ask:

- [ ] Is this a pure Python package?
- [ ] If binary, are wheels available for `iphoneos` and `android`?
- [ ] Does it spawn subprocesses?
- [ ] Does it depend on system utilities?
- [ ] Have I tested it on actual mobile devices?
- [ ] Is the dependency absolutely necessary, or is there a pure Python alternative?
- [ ] If mobile support is impossible, have I documented this clearly?

---

## Resources

### Tools for Mobile Development
- **PSProject**: Build system for Python iOS/macOS apps with Xcode integration
- **python-for-android**: Toolchain for Android Python apps
- **kivy-ios**: Toolchain for iOS Python apps
- **pyjnius**: Access Java classes from Python (Android)
- **pyobjus**: Access Objective-C classes from Python (iOS)

### Testing Mobile Wheels
```bash
# Check if a package has mobile wheels
pip index versions <package-name>

# Try installing on mobile (will fail if no wheel available)
pip install <package-name> --platform iphoneos
pip install <package-name> --platform android
```

---

## Conclusion

Creating truly cross-platform Kivy libraries requires careful consideration of mobile platform limitations. By following these guidelines, you can create libraries that work seamlessly across desktop and mobile devices, providing a consistent and reliable experience for all users.

**Remember**: When in doubt, choose pure Python solutions and avoid system-level dependencies. Your users on mobile platforms will thank you!
