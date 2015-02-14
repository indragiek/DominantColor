Pod::Spec.new do |spec|
	spec.name = 'DominantColor'
	spec.version = '0.1.0'
	spec.summary = 'Finding dominant colors of an image using k-means clustering.'
	spec.homepage = 'https://github.com/indragiek/DominantColor'
	spec.license = 'MIT'
	spec.author = { 'Indragie Karunaratne' => 'i@indragie.com' }
	spec.source = { :git => 'https://github.com/indragiek/DominantColor.git', :tag => spec.version.to_s }
	spec.source_files = 'DominantColor/Shared/*.{swift,h,m}'
	spec.requires_arc = true
	spec.frameworks = 'GLKit'
	spec.ios.deployment_target = '8.0'
	spec.osx.deployment_target = '10.9'
	spec.ios.frameworks = 'UIKit'
	spec.osx.frameworks = 'Cocoa'
end