# S3 Download by date range

S3 Download files by modifed date (Range)

## Installation

    $ gem install s3-download-by-date


## Configuration
add to your ~/.bash_profile (~/.zprofile if using ZSH)

```bash
export REGION='eu-west-1' (default to us-east-1)
export AWS_ACCESS_KEY="YOUR AWS KEY ID"
export AWS_SECRET_KEY="YOUR AWS SECRET KEY"

```

## Usage

s3download range --bucket=s3-bucket-name --prefix=folder_or_file_prefix --from='yesterday at noon' --to='today at noon' --save-to=~/Downloads

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request