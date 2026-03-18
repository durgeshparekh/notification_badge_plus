Pod::Spec.new do |s|
  s.name             = 'notification_badge_plus'
  s.version          = '1.0.6'
  s.summary          = 'A Flutter plugin for displaying notification badges on app icons.'
  s.description      = <<-DESC
A Flutter plugin for displaying notification badges on app icons with comprehensive Android manufacturer support and iOS compatibility.
                       DESC
  s.homepage         = 'https://github.com/durgeshparekh/notification_badge_plus'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Durgesh Parekh' => 'your.email@example.com' }
  
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '9.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end