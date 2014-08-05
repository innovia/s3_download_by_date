Gem::Specification.new do |s|
  s.name        = "s3_download_by_date"
  s.version     = '0.1.0'
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
  s.executables = ["s3download"]
  # s.extra_rdoc_files = ['README.md', 'LICENSE']
  s.license = 'MIT'
end
