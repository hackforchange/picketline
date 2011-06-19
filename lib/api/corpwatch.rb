require 'net/http'

class CorpWatch
  HOST = 'api.corpwatch.org'
  KEY = 'f9e4433920063c782d8f79ea6a55c890'
  
  class << self
    def children(id)
      res = Net::HTTP.start(HOST, 80) do |http|
        http.get("/companies/#{id}/children.json?key=$#{KEY}")
      end
      results = []
      json = JSON.parse(res.body)
      json["result"]["companies"].each do |k,v|
        results << v
      end
      results
    end
    
  end
    
end
