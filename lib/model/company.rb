require_relative '../db'

module PicketLine
  class Company
    class << self
      def get_by_slug(slug)
        c = PicketLine::DB.get_company(slug.to_s)
        parse_profile(c)
      end
      
      private
      
      def parse_profile(c)
        c[:profile] = JSON::parse(c[:profile])
        c[:profile][:critics] ||= {}
        c[:profile][:critics][:sites] ||= {}
        c[:profile][:critics][:posts] ||= {}
        c
      end
    end
  end
end
