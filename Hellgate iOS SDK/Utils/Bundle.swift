import Foundation

private class BundleFinder {}

extension Bundle {
    static let hellgateModule: Bundle? = {

        // Cocoapods bundle is set to `HellgateBundle`
        // SPM automatically names the bundle `Hellgate-iOS-SDK_Hellgate-iOS-SDK`
        // We could use .module but it won't be available for other package systems
        let bundleNames = ["HellgateBundle", "Hellgate-iOS-SDK_Hellgate-iOS-SDK"]

        let candidates = [
            // Bundle should be present here when the package is linked into an App.
            Bundle.main.resourceURL,

            // Bundle should be present here when the package is linked into a framework.
            Bundle(for: BundleFinder.self).resourceURL,

            // For command-line tools.
            Bundle.main.bundleURL
        ]

        for bundleName in bundleNames {
            for candidate in candidates {
                let bundlePath = candidate?.appendingPathComponent(bundleName + ".bundle")
                if let bundle = bundlePath.flatMap(Bundle.init(url:)) {
                    return bundle
                }
            }
        }

        // Carthage builds the assets into the .framework
        return Bundle(for: BundleFinder.self)
    }()
}
