require_relative '../db'

module PicketLine
  class Company
    class << self
      def get_by_slug(slug)
        c = PicketLine::DB.get_company(slug.to_s)
        parse_profile(c)
      end
      
      def add_link(slug, url, blurb, title, type)
        c = get_by_slug(slug)
        c[:profile]["critics"][type] << {"url" => url, "blurb" => blurb, "title" => title}
        PicketLine::DB.update_company_profile(c[:id], c[:profile].to_json)
      end
      
      private
      
      def parse_profile(c)
        c[:profile] = JSON::parse(c[:profile])
        c[:profile]["critics"] ||= {}
        c[:profile]["critics"]["sites"] ||= []
        c[:profile]["critics"]["press"] ||= []
        c
      end
    end
  end
end
