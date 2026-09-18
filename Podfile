platform :ios, '17.6'
project 'Kirokun.xcodeproj', 'Debug' => :debug, 'Release' => :release, 'ProtoDebug' => :debug, 'ProtoRelease' => :release
use_frameworks!

target 'Kirokun' do
  pod 'Firebase/Auth', '12.19.0'
  pod 'Firebase/Messaging', '12.19.0'
  pod 'Firebase/Database', '12.19.0'
  pod 'SwiftyJSON', '~> 5.0'
  pod 'Alamofire', '~> 5.10'
  pod 'DGCharts', '~> 5.1'

  target 'KirokunTests' do
    inherit! :search_paths
  end
  target 'KirokunUITests' do
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '17.6'
    end
  end
end
