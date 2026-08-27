#import <Foundation/Foundation.h>

// The Linux iOS toolchain used by CI does not provide compiler-rt's
// __isOSVersionAtLeast helper. Some FFmpeg VideoToolbox objects reference it,
// so provide the small compatibility implementation here.
__attribute__((visibility("default")))
int __isOSVersionAtLeast(int major, int minor, int patch) {
    NSOperatingSystemVersion current = [[NSProcessInfo processInfo] operatingSystemVersion];

    if (current.majorVersion != major) {
        return current.majorVersion > major;
    }
    if (current.minorVersion != minor) {
        return current.minorVersion > minor;
    }
    return current.patchVersion >= patch;
}
