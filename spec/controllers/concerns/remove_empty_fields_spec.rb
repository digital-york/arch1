require 'rails_helper'

RSpec.describe RemoveEmptyFields, type: :controller do
  # Define anonymou controller so we can call and test method from concerns module
  controller(ApplicationController) do
    include RemoveEmptyFields
    def index
      @params = ActionController::Parameters.new(
        'folio' => '2j62s606x',
        'entry_no' => '1',
        'summary' =>
         'Institution of Richard Askam, chaplain, to the perpetual chantry of the Blessed Virgin Mary, in the parish of Scarborough.',
        'entry_type' => ['mc87pq28n'],
        'section_type' => ['nk322d32h'],
        'is_referenced_by' =>
         ['Smith, D. M (ed.). 1974. A Calendar of the Register of Robert Waldby, Archbishop of York, 1397. Borthwick Texts and Calendars: Records of the Northern Province, 2. York: University of York, 21.'],
        'entry_dates_attributes' =>
         { '0' =>
           { 'date_role' => 'qr46r081g',
             'date_note' => '',
             'single_dates_attributes' =>
             { '0' =>
               { 'date' => '1397/06/23',
                 'date_type' => 'single',
                 'date_certainty' => ['certain'],
                 'id' => '3n204221g',
                 'rdftype' =>
                 ['http://dlib.york.ac.uk/ontologies/borthwick-registers#SingleDate',
                  'http://dlib.york.ac.uk/ontologies/borthwick-registers#All'] } },
             'id' => 'rj430742n',
             'rdftype' =>
             ['http://dlib.york.ac.uk/ontologies/borthwick-registers#EntryDate',
              'http://dlib.york.ac.uk/ontologies/borthwick-registers#All'] },
           '1' =>
           { '_destroy' => '1',
             'date_role' => '8c97ks88r',
             'date_note' => '',
             'id' => nil,
             'rdftype' =>
             ['http://dlib.york.ac.uk/ontologies/borthwick-registers#EntryDate',
              'http://dlib.york.ac.uk/ontologies/borthwick-registers#All'] } },
        'related_places_attributes' =>
         { '0' =>
           { 'place_same_as' => '9s161639f',
             'place_role' => ['37720c723'],
             'place_type' => ['nz805z690'],
             'id' => 'pz50h0249',
             'rdftype' =>
             ['http://dlib.york.ac.uk/ontologies/borthwick-registers#RelatedPlace',
              'http://schema.org/Place',
              'http://dlib.york.ac.uk/ontologies/borthwick-registers#All'] },
           '1' =>
           { '_destroy' => '1',
             'place_same_as' => '',
             'place_as_written' => [''],
             'id' => nil,
             'rdftype' =>
             ['http://dlib.york.ac.uk/ontologies/borthwick-registers#RelatedPlace',
              'http://schema.org/Place',
              'http://dlib.york.ac.uk/ontologies/borthwick-registers#All'] } },
        'related_agents_attributes' =>
              { '0' =>
                { '_destroy' => '1',
                  'person_same_as' => '',
                  'person_group' => 'person',
                  'person_gender' => '',
                  'person_as_written' => [''],
                  'id' => nil,
                  'rdftype' =>
                  ['http://dlib.york.ac.uk/ontologies/borthwick-registers#RelatedAgent',
                   'http://xmlns.com/foaf/0.1/Person',
                   'http://dlib.york.ac.uk/ontologies/borthwick-registers#All'] } }
      )
      remove_empty_fields(@params)
      # Controller must render simple response
      render plain: 'Hello World'
    end
  end
  before do
    routes.draw do
      get 'index' => 'anonymous#index'
    end
  end

  context 'ActionController::Parameters' do
    # Call anonymous controller
    before do
      get :index
    end
    # Test controller results
    it 'match properties cardinality declaration' do
      # [""] => []
      expect(assigns[:params][:entry_dates_attributes]['1'][:date_note]).to eq ''
      expect(assigns[:params][:related_places_attributes]['1'][:place_as_written]).to eq []
      expect(assigns[:params][:related_agents_attributes]['0'][:person_as_written]).to eq []
    end
  end
end
