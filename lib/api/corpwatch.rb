require 'net/http'

class CorpWatch
  HOST = 'api.corpwatch.org'
  
  class << self
    def children(id)
      res = Net::HTTP.start(HOST, 80) do |http|
        http.get("/companies/#{id}/children.json")
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
