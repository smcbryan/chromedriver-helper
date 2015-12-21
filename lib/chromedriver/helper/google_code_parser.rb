require 'nokogiri'
require 'open-uri'

module Chromedriver
  class Helper
    class GoogleCodeParser
      BUCKET_URL = 'http://chromedriver.storage.googleapis.com'

      attr_reader :source, :platform

      def initialize(platform, open_uri_provider=OpenURI)
        @platform = platform
        @source = open_uri_provider.open_uri(BUCKET_URL)
      end

      def downloads
        doc = Nokogiri::XML.parse(source)
        items = doc.css("Contents Key").collect {|k| k.text }
        items.reject! {|k| !(/chromedriver_#{platform}/===k) }
        items.map {|k| "#{BUCKET_URL}/#{k}"}
      end

      # Lock chromedriver version to 2.20 to prevent backslash or unwanted updates
      def newest_download
        downloads.select{|x| x =~ /\/2.20\//}.last
      end

      private

      def version_of url
        Gem::Version.new grab_version_string_from(url)
      end

      def grab_version_string_from url
        # assumes url is of form similar to http://chromedriver.storage.googleapis.com/2.3/chromedriver_mac32.zip
        url.split("/")[3]
      end
    end
  end
end
