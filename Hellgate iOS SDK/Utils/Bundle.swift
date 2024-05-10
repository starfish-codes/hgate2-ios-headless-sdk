import Foundation

private class BundleFinder {}

extension Bundle {
    static let hellgateModule: Bundle? = {

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
                    print("*** Found one ***")
                    print(bundle.bundlePath)
                    print(bundle.resourcePath ?? "no resource path")
                    return bundle
                }
            }
        }

        print("&&& Last resort &&&")
        let bundle = Bundle(for: BundleFinder.self)
        print(bundle.bundlePath)
        print(bundle.resourcePath ?? "no resource path")
        return bundle
    }()
}
