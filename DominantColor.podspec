Pod::Spec.new do |spec|
	spec.name = 'DominantColor'
	spec.version = '0.2.0'
	spec.summary = 'Finding dominant colors of an image using k-means clustering.'
	spec.homepage = 'https://github.com/indragiek/DominantColor'
	spec.license = 'MIT'
	spec.author = { 'Indragie Karunaratne' => 'i@indragie.com' }
	spec.source = { :git => 'https://github.com/indragiek/DominantColor.git', :tag => spec.version.to_s }
	spec.source_files = 'DominantColor/Shared/*.{swift,h,m}'
	spec.requires_arc = true
	spec.frameworks = ['GLKit', 'GameKit']
	spec.ios.deployment_target = '9.0'
	spec.osx.deployment_target = '10.11'
	spec.ios.frameworks = 'UIKit'
	spec.osx.frameworks = 'Cocoa'
	spec.swift_versions = ['5.0']
end
