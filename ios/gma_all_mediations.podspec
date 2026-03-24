Pod::Spec.new do |s|
  s.name             = 'gma_all_mediations'
  s.version          = '0.0.1'
  s.summary          = 'Flutter plugin to manage Google Mobile Ads mediation consent.'
  s.description      = <<-DESC
    gma_all_mediations provides a unified initialisation and consent
    propagation layer for Google Mobile Ads Flutter mediation adapters.
    The native iOS plugin applies Chartboost GDPR/CCPA consent signals
    automatically via the Chartboost SDK, so Flutter consumers need zero
    AppDelegate code.
  DESC
  s.homepage         = 'https://github.com/theatifwaheed/gma_all_mediations'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'FluXpert' => 'theatifwaheed@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.platform         = :ios, '13.0'
  s.static_framework = true

  # Flutter engine
  s.dependency 'Flutter'

  # Chartboost mediation adapter — brings in the Chartboost SDK which exposes
  # CBGDPRDataUseConsent and CBCCPADataUseConsent used in GmaAllMediationsPlugin.swift.
  # Version kept in sync with gma_mediation_chartboost's podspec requirement.
  s.dependency 'GoogleMobileAdsMediationChartboost', '~> 9.11.0'

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386'
  }
  s.swift_version = '5.0'
end
