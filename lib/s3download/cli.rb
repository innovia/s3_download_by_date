#!/usr/bin/env ruby
# encoding: UTF-8
require 'aws-sdk-v1'
require 'thor'
require 'chronic'
require 'progressbar'
require 'active_support/time'
require 'fileutils'
require 'json'

class S3download::Cli < Thor
  default_task :fetch
  attr_accessor :s3, :debug, :files_found, :range, :target, :bucket, :from, :to, :prefix
  
  desc 'fetch', 'Download S3 files by range (date)'
  class_option  :bucket, :alias => 'b',                                                                      :banner => 'S3 Bucket Name'
  class_option  :prefix, :alias => 'f',                                                                      :banner => 'Folder inside the specified bucket'
  class_option  :from,                                      :default =>  Chronic.parse('today at 00:00:00'), :desc => 'From in a natural language date/time like yesterday, \'last week\', etc...' 
  class_option  :to,                                        :default =>  Chronic.parse('today at 23:59:59'), :desc => 'To in a natural language date/time like yesterday, \'last week\', etc...' 
  class_option  :save_to,                                                                                    :banner => 'Location of downloaded files'
  class_option  :timezone,                                  :default => 'UTC',                               :desc => 'timezone to filter files by date [UTC] ex: "Eastern Time (US & Canada)"'
  class_option  :debug,                                     :default => false, :type => :boolean            
  class_option  :verbose,                                   :default => false, :type => :boolean            
  def fetch
    raise Thor::RequiredArgumentMissingError, 'You must supply an S3 bucket name' if options[:bucket].nil?
    raise Thor::RequiredArgumentMissingError, 'You must supply a location where to save the downloaded files to' if options[:save_to].nil?
    
    if options[:prefix].nil?
      say "You did not pass a --prefix option, this will scan the entire bucket and can be very slow if there too many files in that bucket\n", color = :yellow
      say "If you're trying to script this and bypass this question, use --prefix '' (empty string)\n", color = :yellow
      response = ask "Continue without a prefix? (y/n)", color = :white
      exit 0 if response == 'n'
      self.prefix  = ''
    else
      self.prefix = options[:prefix]
    end

    init  

    ProgressBar.new("Looking for files: ", bucket.count) do |pbar|      
      bucket.each do |object|
        if options[:verbose]
          say "timezone: #{options[:timezone]}" 
          say "object last modified: #{object.last_modified}"
          say "object last modified in timezone: #{object.last_modified.in_time_zone(options[:timezone])}"
          say "object falls in range: #{self.range}? => #{self.range.cover?(object.last_modified.in_time_zone(options[:timezone]))}"
        end

        if self.range.cover?(object.last_modified.in_time_zone(options[:timezone]))
          self.files_found += 1
          say("Downloading #{object.key} #{object.last_modified.in_time_zone(options[:timezone])}\n", color = :white) if options[:debug]
          FileUtils.mkdir_p "#{target}/#{object.key.match(/(.+)\//)[1]}"

          begin
            File.open("#{target}/#{object.key}", "w") do |f|
              f.write(object.read)
            end
          rescue Exception => e
             say "Unable to save file: #{e}", color = :red
          end
        end
        pbar.inc
      end
    end
    say "Total files downloaded from S3: #{self.files_found}", color = :yellow
  end

  desc 'list_timezones', 'list timezones'
  def list_timezones
     say JSON.pretty_generate(ActiveSupport::TimeZone::MAPPING), color = :white
  end

  map ["-v", "--version"] => :version
  desc "version", "version"
  def version
    say S3download::ABOUT
  end

  private
  def init
    aws_init
    self.debug = true if options[:verbose]
    self.bucket = self.s3.buckets[options[:bucket]].objects.with_prefix(self.prefix)
    self.from = Chronic.parse("#{options[:from]}").in_time_zone(options[:timezone])   
    self.to = Chronic.parse("#{options[:to]}").in_time_zone(options[:timezone])
    self.range = self.from..self.to
    self.target = File.expand_path(options[:save_to])
    self.files_found = 0

    FileUtils.mkdir_p "#{self.target}"

    File.open("#{self.target}/download_info.txt", "w") {|f| 
      f.write("#{Time.now} - Downloaded bucket #{options[:bucket]}/#{self.prefix} from: #{from} - to #{to}")
    }

    say "S3 Search & Download", color = :white
    say "--------------------\n", color = :white
    say "Bucket: #{options[:bucket]}", color = :cyan
    say "Prefix: #{self.prefix}\n", color = :cyan
    say "TimeZone: #{options[:timezone]}", color = :cyan
    say "From: #{from}", color = :cyan
    say "To: #{to}", color = :cyan
    say("Download target: #{options[:save_to]}/#{self.prefix}", color = :cyan) if options[:debug]
    say("Range: #{self.range}", color = :green) if options[:debug]
  end

  def aws_init
    config = {
      :access_key_id => ENV['AWS_ACCESS_KEY'],
      :secret_access_key => ENV['AWS_SECRET_KEY'],
      :region => ENV['REGION'] || 'us-east-1'
    }

    if config[:access_key_id].nil? || config[:secret_access_key].nil?
      say "You must set your AWS Secret Key and AWS Access Key Id in your environment variables", color = :red
      say "export REGION='eu-west-1' (default to us-east-1)\nexport AWS_ACCESS_KEY=\"YOUR AWS KEY ID\"\nexport AWS_SECRET_KEY=\"YOUR AWS SECRET KEY\"", color = :green
      exit 1
    end

    self.s3 = AWS::S3.new(config)
  end
end