Pod::Spec.new do |s|
    s.name                           = 'Hellgate-iOS-SDK'
    s.version                        = '1.0.0'
  
    s.summary                        = 'Tokenize card details using starfish team\'s Hellgate.'
    s.license                        = { :type => 'MIT', :file => 'LICENSE' }
    s.homepage                       = 'https://starfish.team'
    s.authors                        = { 'Hellgate' => 'hellgate@starfish.team' }
    s.source                         = { :git => 'https://github.com/starfish-codes/hgate2-ios-headless-sdk.git', :branch => "main" }
    s.frameworks                     = 'Foundation', 'UIKit'
    s.requires_arc                   = true
    s.platform                       = :ios
    s.swift_version		               = '5.7'
    s.ios.deployment_target          = '15.0'
    s.weak_framework                 = 'SwiftUI'
    s.source_files                   = 'Hellgate iOS SDK/**/*.swift'
    s.ios.resource_bundle            = { 'HellgateBundle' => ['Hellgate iOS SDK/Resources/**/*.{lproj,png,xcassets}'] }

  end
