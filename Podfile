platform :ios, "7.0"

# ignore all warnings from all pods
inhibit_all_warnings!

target :default do
    pod "ReactiveCocoa", :podspec => "https://raw.githubusercontent.com/creepone/ReactiveCocoa/private/ReactiveCocoa.podspec.json"
    pod "libextobjc", "~> 0.4"
    pod "iOS-blur", "~> 0.0.5"
    pod "CocoaLumberjack", "~> 1.8"
    pod "SSZipArchive", "~> 0.3"
    pod "TSMessages", "~> 0.9.9"
    pod "FastImageCache", "~> 1.3"
    pod "SVProgressHUD", "~> 1.0"
    pod "FFCircularProgressView", "~> 0.3"
    pod "Dropbox-iOS-SDK", "~> 1.3.10"
    pod "Google-API-Client", "~> 0.1.1"
    pod "RaptureXML", "~> 1.0.1"
    link_with "Player"
end

target :test do
    pod "OCMock", "~> 3.0.2"
    link_with "Player Tests"
end