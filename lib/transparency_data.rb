require 'net/http'

class TransparencyData
  HOST = 'transparencydata.com'
  PATH = '/api/1.0/entities.json'
  APIKEY = '2704975b96fc4221b8990e6f3d595afd'
  
  class << self
    def search(term)
      res = Net::HTTP.start(HOST, 80) do |http|
        http.get("/api/1.0/entities.json?apikey=#{APIKEY}&search=#{term}")
      end
      JSON.parse(res.body)
    end
    
    def get(id)
      res = Net::HTTP.start(HOST, 80) do |http|
        http.get("/api/1.0/entities/#{id}.json?apikey=#{APIKEY}")
      end
      JSON.parse(res.body)
    end
  end
    
end
