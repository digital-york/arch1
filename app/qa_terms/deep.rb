class Deep < Qa::Authorities::Base

    include Qa::Authorities::WebServiceBase
    include TermsHelper

    attr_reader :subauthority

    @q = ''
    @variants = 'true'

    def initialize(subauthority)
      @subauthority = subauthority
    end

    def search q
      @q = q
      parse_authority_response(json(build_query_url(q)))
    end

    # get_json is not ideomatic, so we'll make an alias
    def json(*args)
      begin
        get_json(*args)
      rescue
        nil
      end
    end

    def build_query_url q
      query = URI.escape(untaint(q))
      # to limit to UK, USE; "http://unlock.edina.ac.uk/ws/search?name=#{query},UK&gazetteer=deep&format=json"
      "http://unlock.edina.ac.uk/ws/search?name=#{query}&searchVariants=#{@variants}&maxRows=200&gazetteer=deep&format=json"
    end

    def untaint(q)
      q.gsub(/[^\w\s-]/, '')
    end

    def find id
      json(find_url(id))
    end

    def find_url id
      "http://unlock.edina.ac.uk/ws/search?name=#{id}&gazetteer=deep&format=json"
    end

    def search_by_id q
      parse_authority_response(find(q))
    end

    def request_options
      { accept: 'application/sparql-results+json'}
    end

    private

    # Reformats the data received from the service
    def parse_authority_response(response)
      # There is a max results setting of 200; if we get 200 results, re-run the search without variants
      if response != nil

        if response['features'].length == '200'
          @variants = 'false'
          search(@q)
        end

        response['features'].map do |result|
          geo = TermsHelper::Geo.new
          al = geo.adminlevel(result['properties']['adminlevel1'].to_s,result['properties']['adminlevel2'].to_s)
          { 'id' => result['id'], 'label' => "#{result['properties']['name']} (#{al})",
            'countrycode' => result['properties']['countrycode'],
            'adminlevel1' => result['properties']['adminlevel1'],
            'adminlevel2' => result['properties']['adminlevel2'],
            'adminlevel3' => result['properties']['adminlevel3'],
            'adminlevel4' => result['properties']['adminlevel4'],
            'name' => result['properties']['name'],
            'featuretype' => result['properties']['featuretype'],
            'gazetteer' => result['properties']['gazetteer'],
            'uricdda' => result['properties']['uricdda']}
        end
      end
    end

  end
