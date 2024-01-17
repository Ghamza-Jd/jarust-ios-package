Pod::Spec.new do |spec|
    spec.name = "Jarust"
    spec.version = "0.1.0"
    spec.summary = "Janus iOS SDK"
    spec.description = <<-DESC
    This pod contains a client SDK to connect and communicate with a
    Janus gateway server.
    DESC

    spec.homepage = "https://github.com/Ghamza-Jd/jarust-mobile-sdk"
    spec.author = "Hamza Jadid"
    spec.ios.deployment_target = '15.0'

    spec.source = { :http => "https://github.com/Ghamza-Jd/jarust-mobile-sdk/releases/download/v0.1.0/JarustNative.zip" }
    spec.vendored_frameworks = "Jarust.xcframework"
end
