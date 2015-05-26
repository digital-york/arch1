class TGN < Qa::Authorities::Base
    include Qa::Authorities::WebServiceBase

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
      query = URI.escape(sparql(untaint(q)))
      "http://vocab.getty.edu/sparql.json?query=#{query}&_implicit=false&implicit=true&_equivalent=false&_form=%2Fsparql"

    end

    def sparql(q)
      search = untaint(q)
      # The full text index matches on fields besides the term, so we filter to ensure the match is in the term.
      sparql = "SELECT ?s ?name ?par {
              ?s a skos:Concept; luc:term \"#{search}\";
                 skos:inScheme <http://vocab.getty.edu/tgn/> ;
                 gvp:prefLabelGVP [skosxl:literalForm ?name] ;
                  gvp:parentString ?par .
              FILTER regex(?name, \"#{search}\", \"i\") .
            } LIMIT 10"
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
      response['results']['bindings'].map do |result|
        { 'id' => result['s']['value'], 'label' => result['name']['value']  + ' (' + result['par']['value'] + ')' }
      end
    end

  end
