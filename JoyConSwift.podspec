Pod::Spec.new do |s|
  s.name = "JoyConSwift"
  s.version = "0.2.0"
  s.summary = "IOKit wrapper for Nintendo Joy-Con and ProController (macOS, Swift)"
  s.homepage = "https://github.com/magicien/JoyConSwift"
  s.license = "MIT"
  s.author = { "magicien" => "magicien.du.ballon@gmail.com" }
  s.platform = :osx, "10.14"
  s.source = { :git => "https://github.com/magicien/JoyConSwift.git", :tag => "v#{s.version}" }
  s.source_files = "Source/**/*.{swift,h}"
  s.swift_version = "5.0"
end
