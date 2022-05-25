#
#  Be sure to run `pod s lint TencentCloundLogProducer.podspec' to ensure this is a
#  valid s and to remove all comments including this before submitting the s.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "TencentCloundLogProducer"
  s.version      = "0.1.0"
  s.summary      = "TencentCloundLogProducer ios"

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  s.description  = <<-DESC
  log service ios producer.
  https://cloud.tencent.com/product/cls
                   DESC

  s.homepage     = 'https://cloud.tencent.com/'
  s.license      = { :type => 'Apache License, Version 2.0', :text => <<-LICENSE
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
  LICENSE
}

  s.author             = { "herrylv" => "herrylv@tencent.com" }
  s.source       = { :git => "https://github.com/TencentCloud/tencentcloud-cls-demo.git", :tag => s.version.to_s  }
  s.social_media_url = 'http://t.cn/AiRpol8C'
  s.ios.deployment_target = '8.0'
  s.default_subspec = 'Core'

  s.subspec 'Core' do |c|
      c.vendored_libraries = 'TencentCloundLogProducer/tencentclound-log-c-sdk/openssl/lib/libcrypto.a','TencentCloundLogProducer/tencentclound-log-c-sdk/openssl/lib/libssl.a','TencentCloundLogProducer/tencentclound-log-c-sdk/curl/lib/libcurl.a'
      c.source_files =
          'TencentCloundLogProducer/TencentCloundLogProducer/*.{h,m}',
          'TencentCloundLogProducer/tencentclound-log-c-sdk/src/*.{c,h}',
          'TencentCloundLogProducer/tencentclound-log-c-sdk/curl/include/curl/*.{c,h}',
          'TencentCloundLogProducer/tencentclound-log-c-sdk/openssl/include/openssl/*.{c,h}',
          'TencentCloundLogProducer/TencentCloundLogProducer/utils/*.{m,h}'
    
          c.public_header_files =
          'TencentCloundLogProducer/TencentCloundLogProducer/*.h',
          'TencentCloundLogProducer/TencentCloundLogProducer/utils/*.h',
          'TencentCloundLogProducer/tencentclound-log-c-sdk/src/log_define.h',
          'TencentCloundLogProducer/tencentclound-log-c-sdk/src/log_adaptor.h',
          'TencentCloundLogProducer/tencentclound-log-c-sdk/src/log_inner_include.h',
          'TencentCloundLogProducer/tencentclound-log-c-sdk/src/log_multi_thread.h',
          'TencentCloundLogProducer/tencentclound-log-c-sdk/src/log_producer_client.h',
          'TencentCloundLogProducer/tencentclound-log-c-sdk/src/log_error.h',
          'TencentCloundLogProducer/tencentclound-log-c-sdk/src/ProducerConfig.h',
          'TencentCloundLogProducer/tencentclound-log-c-sdk/src/log_producer_config.h'

  end
end
