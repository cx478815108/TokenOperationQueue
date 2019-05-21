Pod::Spec.new do |s|
    s.name         = 'TokenOperationQueue'
    s.version      = '1.0'
    s.summary      = 'GCD wrapper tool'
    s.homepage     = 'https://github.com/cx478815108/TokenOperationQueue'
    s.license      = 'MIT'
    s.authors      = {'cx478815108' => 'feelings0811@wutnews.net'}
    s.platform     = :ios, '10.0'
    s.source       = {:git => 'https://github.com/cx478815108/TokenOperationQueue.git', :tag => 'v1.0'}
    s.source_files = 'source/**/*.{h,m}'
    s.requires_arc = true
end