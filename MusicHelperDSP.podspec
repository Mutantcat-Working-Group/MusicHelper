Pod::Spec.new do |s|
  s.name             = 'MusicHelperDSP'
  s.version          = '1.0.0'
  s.summary          = 'Native DSP core for MusicHelper (MPM pitch detection, chord recognition)'
  s.description      = <<-DESC
C++ DSP library used by the MusicHelper Flutter app through dart:ffi.

Provides:
  - MPM (McLeod Pitch Method) pitch detection
  - HPS (Harmonic Product Spectrum) multi-pitch detection
  - FFT / chroma feature extraction
  - Chroma-template chord recognition

The Runner target links this pod with `use_frameworks!`, so the library is
built as a dynamic framework and its C symbols are resolvable from Dart via
`DynamicLibrary.process()`.
  DESC
  s.homepage         = 'https://github.com/Mutantcat-Working-Group/MusicHelper'
  s.license          = { :type => 'GPL-3.0', :file => 'LICENSE' }
  s.author           = 'Mutantcat'
  s.source           = { :http => 'https://github.com/Mutantcat-Working-Group/MusicHelper' }
  s.documentation_url = 'https://pub.dev/packages/music_helper'

  s.ios.deployment_target = '13.0'

  # 纯 C++ 源码,不依赖 Flutter
  s.source_files        = 'native/dsp/*.{cpp,h}'
  s.public_header_files = 'native/dsp/*.h'

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'CLANG_CXX_LANGUAGE_STANDARD' => 'c++11',
  }
  s.requires_arc = false
end
