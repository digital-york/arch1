class Unlock < Qa::Authorities::Base
    include Qa::Authorities::WebServiceBase
    include TermsHelper

    attr_reader :subauthority
    def initialize(subauthority)
      @subauthority = subauthority
    end

    def search q
      parse_authority_response(json(build_query_url(q)))
    end

    # get_json is not ideomatic, so we'll make an alias
    def json(*args)
      get_json(*args)
    end

    def build_query_url q
      query = URI.escape(untaint(q))
      "http://unlock.edina.ac.uk/ws/search?name=#{query},UK&format=json"
    end

    def untaint(q)
      q.gsub(/[^\w\s-]/, '')
    end

    def find id
      json(find_url(id))
    end

    def find_url id
      "http://vocab.getty.edu/tgn/#{id}.json"
    end

    def request_options
      { accept: 'application/sparql-results+json'}
    end

    private

    # Reformats the data received from the service
    def parse_authority_response(response)
      response['features'].map do |result|
        geo = TermsHelper::Geo.new
        al = geo.adminlevel(result['properties']['adminlevel1'].to_s,result['properties']['adminlevel2'].to_s)
        { 'id' => result['id'], 'label' => "#{result['properties']['name']} (#{al})",
          'countrycode' => result['properties']['countrycode'],
          'adminlevel1' => result['properties']['adminlevel1'],
          'adminlevel2' => result['properties']['adminlevel2'],
          'adminlevel3' => result['properties']['adminlevel3'],
          'adminlevel4' => result['properties']['adminlevel4'],
          'featuretype' => result['properties']['featuretype'],
          'gazetteer' => result['properties']['gazetteer']}
      end
    end

  end
