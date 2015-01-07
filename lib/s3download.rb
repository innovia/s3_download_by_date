module S3download
  VERSION   = "0.2.4"
  ABOUT     = "S3download by date v#{VERSION} (c) #{Time.now.strftime("2014-%Y")} @innovia\nFind files & folders between dates on S3 given bucket and download them"
  
  autoload :Cli, 		  's3download/cli'
end