class PersonPopupController < ApplicationController

  def index

    @type = params[:type]

    if @type == nil || @type == ''
    elsif @type == 'new_person'
      @person = Person.new
    end

puts @type

  end

  def new
  end

  def create
    person_params = whitelist_person_params
    @person = Person.new(person_params)
    @person.save
    @person_name = @person.family
    @person = Person.new
    @type = 'new person'
    render 'index'
  end

  def search

    @search_term = params[:search_term]

    response = SolrQuery.new.solr_query(q='has_model_ssim:Person', fl='id, family_tesim', rows=1000, sort='')

    temp_hash = {}

    response['response']['docs'].map do |result|
      id = result['id']
      family_name = result['family_tesim']
      if family_name != nil
        temp_hash[family_name.join()] = id
      end
    end

    @search_results_hash = temp_hash.select { |key, value| key.to_s.match(/#{@search_term}/i) }
    @search_results_hash = Hash[@search_results_hash.sort]

    render 'index'
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def whitelist_person_params
    params.require(:person).permit! # Note - this needs changing because it allows through all params at the moment!!
  end

end