$:.push File.expand_path("../lib", __FILE__)
require File.expand_path('../lib/s3download', __FILE__)

Gem::Specification.new do |s|
  s.name        = "s3_download_by_date"
  s.version     = S3download::VERSION
  s.authors     = ["Ami Mahloof"]
  s.email       = "ami.mahloof@gmail.com"
  s.homepage    = "https://github.com/innovia/s3_download_by_date"
  s.summary     = "Download from S3 by date range"
  s.description = "Download files by modified date range"
  s.required_rubygems_version = ">= 1.3.6"
  s.add_runtime_dependency 'thor', '~> 0.19', '>= 0.19.1'
  s.add_runtime_dependency 'chronic', '~> 0.10', '>= 0.10.2'
  s.add_runtime_dependency 'progressbar', '~> 0.21', '>= 0.21.0'
  s.add_runtime_dependency 'aws-sdk', '~> 1.40', '>= 1.40.0'
  s.add_runtime_dependency 'activesupport', '~> 4.1', '>= 4.1.4'
  s.files = `git ls-files`.split($\).reject{|n| n =~ %r[png|gif\z]}.reject{|n| n =~ %r[^(test|spec|features)/]}
  s.executables   = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.extra_rdoc_files = ['README.md', 'LICENSE']
  s.license = 'MIT'
end
