require 'tnw_common'
require 'tnw_common/shared/Constants'
require 'tnw_common/solr/solr_query'
require 'tnw_common/tna/tna_search'

class NewSolrFieldsController < ApplicationController

  # define shared solr connection
  def initialize()
    @solr_server = TnwCommon::Solr::SolrQuery.new(SOLR[Rails.env]['url'])
    @tna_search = TnwCommon::Tna::TnaSearch.new(@solr_server)
  end

  # Add customized solr fields if the model is Document
  def modify_tna_document(solr_doc)
    # Repository is already indexed as repository_tesim by Active Fedora

    # Find department info and store it to the facet
    solr_doc[TnwCommon::Shared::Constants::FACET_REGISTER_OR_DEPARTMENT]=@tna_search.get_department_label(solr_doc[:id])

    # Reference is already indexed as reference_tesim

    # Publication should already be indexed as publication_tesim

    # Summary is already indexed as summary_tesim
    # summary (Text field)
    solr_doc[TnwCommon::Shared::Constants::SOLR_FILED_COMMON_SUMMARY_SEARCH] = array_to_lowercase(solr_doc[TnwCommon::Shared::Constants::SOLR_FILED_COMMON_SUMMARY_TESIM])

    # document type (Text field)
    # map document_type_facet_ssim (authority id) to label
    # Document type (Linked to entry type authority in AR)
    document_type_labels = Ingest::AuthorityHelper.s_get_entry_type_labels(solr_doc[TnwCommon::Shared::Constants::SOLR_FILED_TNA_DOCUMENT_TYPE_TESIM])
    solr_doc[TnwCommon::Shared::Constants::SOLR_FIELD_COMMON_ENTRY_TYPE_SEARCH] = array_to_lowercase(document_type_labels)
    # use the shared entry(document) type facet
    solr_doc[TnwCommon::Shared::Constants::FACET_ENTRY_TYPE] = document_type_labels

    # Entry date note (text field)
    solr_doc['entry_date_note_search'] = array_to_lowercase(solr_doc['entry_date_note_tesim'])

    # Note (Text field)
    solr_doc[TnwCommon::Shared::Constants::SOLR_FILED_COMMON_NOTE_SEARCH] = array_to_lowercase(solr_doc[TnwCommon::Shared::Constants::SOLR_FILED_COMMON_NOTE_TESIM])


    # Date of document
    entry_date_note = ''
    unless solr_doc['entry_date_note_tesim'].blank?
      entry_date_note = solr_doc['entry_date_note_tesim'][0]
    end

    document_date_ids = Ingest::DocumentDateHelper.s_get_document_date_ids(solr_doc[:id], nil, entry_date_note)
    document_date_ids.each do |document_date_id|
      single_date_ids = Ingest::DocumentDateHelper.s_get_single_date_ids(document_date_id)
      solr_doc[TnwCommon::Shared::Constants::FACET_DATE] = []  # Use this field for facet
      solr_doc[TnwCommon::Shared::Constants::SOLR_FILED_COMMON_DATE_ALL_SSIM] = [] # Use this field for date fields
      solr_doc[TnwCommon::Shared::Constants::SOLR_FILED_COMMON_DATE_FULL_SSIM] = ''   # use this field for ordering

      single_date_ids.each_with_index do |single_date_id, index|
        @solr_server.query("id:#{single_date_id}", 'date_tesim', 65535)['response']['docs'].map do |result|
          date = result['date_tesim'][0]
          year = date.split('/')[0]
          solr_doc[TnwCommon::Shared::Constants::FACET_DATE] << year
          solr_doc[TnwCommon::Shared::Constants::SOLR_FILED_COMMON_DATE_ALL_SSIM] << date
          if index==0
            solr_doc[TnwCommon::Shared::Constants::SOLR_FILED_COMMON_DATE_FULL_SSIM] = date
          end
        end
      end
    end

    # Pull out place info from TNA_Place and Place of Dating fields (linked to Place authority)
    place_same_as_array,
        place_same_as_facet_array,
        place_same_as_search_array,
        place_as_written_array = get_place_array(solr_doc[:id])
    solr_doc['place_same_as_tesim'] = place_same_as_array.uniq
    solr_doc[TnwCommon::Shared::Constants::FACET_PLACE_SAME_AS] = place_same_as_facet_array.uniq
    solr_doc['place_same_as_search'] = place_same_as_search_array.uniq
    solr_doc['place_as_written_tesim'] = place_as_written_array.uniq

    # Language (linked field to language authority)
    language_new,unused = get_preflabel_array(solr_doc['language_tesim'])
    solr_doc['language_new_tesim'] = language_new
    solr_doc['language_facet_ssim'] = language_new
    solr_doc['language_search'] = array_to_lowercase(language_new)

    # subject (Linked field)
    subject_new, subject_alt = get_preflabel_array(solr_doc['subject_tesim'])
    solr_doc[TnwCommon::Shared::Constants::FACET_SUBJECT] = subject_new
    unless subject_alt.empty? then subject_new += subject_alt.compact end
    solr_doc['subject_new_tesim'] = subject_new
    solr_doc['subject_search'] = array_to_lowercase(subject_new)

    # Addressee
    addressees = Ingest::TnaPersonHelper.s_get_linked_addressee_as_written_labels(solr_doc[:id])
    solr_doc['tna_addressees_tesim'] = addressees
    solr_doc['person_as_written_search'] = array_to_lowercase(addressees)

    # Sender
    senders = Ingest::TnaPersonHelper.s_get_linked_sender_as_written_labels(solr_doc[:id])
    solr_doc['tna_senders_tesim'] = senders
    senders.each do |sender|
      solr_doc['person_as_written_search'] << sender.downcase
    end

    # Person
    persons = Ingest::TnaPersonHelper.s_get_linked_person_as_written_labels(solr_doc[:id])
    solr_doc['tna_persons_tesim'] = persons
    persons.each do |person|
      solr_doc['person_as_written_search'] << person.downcase
    end

    # solr_doc['person_as_written_search'] = array_to_lowercase(solr_doc['person_as_written_tesim'])
    #
    # # related agents
    # person_name_authority_new,person_name_authority_alt = get_preflabel_array(solr_doc['person_same_as_tesim'])
    # solr_doc['person_same_as_facet_ssim'] = person_name_authority_new
    # unless person_name_authority_alt.empty? then person_name_authority_new += person_name_authority_alt.compact end
    # solr_doc['person_same_as_new_tesim'] = person_name_authority_new
    # solr_doc['person_same_as_search'] = array_to_lowercase(person_name_authority_new)
    #
    # person_role_new,person_role_alt = get_preflabel_array(solr_doc['person_role_tesim'])
    # solr_doc['person_role_facet_ssim'] = person_role_new
    # unless person_role_alt.empty? then person_role_new += person_role_alt.compact end
    # solr_doc['person_role_new_tesim'] = person_role_new
    # solr_doc['person_role_search'] = array_to_lowercase(person_role_new)
    #
    # person_descriptor_new,person_descriptor_alt = get_preflabel_array(solr_doc['person_descriptor_tesim'])
    # solr_doc['person_descriptor_facet_ssim'] = person_descriptor_new
    # unless person_descriptor_alt.empty? then person_descriptor_new += person_descriptor_alt.compact end
    # solr_doc['person_descriptor_new_tesim'] = person_descriptor_new
    # solr_doc['person_descriptor_search'] = array_to_lowercase(person_descriptor_new)
    #
    # solr_doc['person_descriptor_as_written_search'] = array_to_lowercase(solr_doc['person_descriptor_tesim'])
    #
    # solr_doc['person_note_search'] = array_to_lowercase(solr_doc['person_note_tesim'])
    #
    # solr_doc['person_related_place_search'] = array_to_lowercase(solr_doc['person_related_place_tesim'])
    #
    # solr_doc['person_related_person_search'] = array_to_lowercase(solr_doc['person_related_person_tesim'])


    # add the register name and folio label to the entries
    # register_new,folio_new = get_entry_register_array(solr_doc['folio_ssim'])
    # solr_doc['entry_register_facet_ssim'] = register_new
    # solr_doc['entry_folio_facet_ssim'] = folio_new

    # facets from dates, related places/agents and folio/register added to entries
    # these runs on everything because it uses id, the only other field that ALL entries have is entry_no, but that is not unique
    # entry_place_name_authority_new = get_entry_place_array(get_id(solr_doc[:id]))
    # solr_doc['entry_place_same_as_facet_ssim'] = entry_place_name_authority_new

    entry_person_name_authority_new = get_entry_agent_array(get_id(solr_doc[:id]))
    solr_doc[TnwCommon::Shared::Constants::FACET_PERSON_SAME_AS] = entry_person_name_authority_new


    return solr_doc
  end

  # This code adds new solr fields which are required for the search application
  # Note that this code is called from initializers/active_fedora.rb and overrides the to_solr active_fedora method
  # '_search' fields are added for searching in the interface and are lowercase versions of the actual terms
  # '_new_tesim' fields are created from ids, e.g. for language, so that solr doesn't have to join documents
  # '_facet_ssim' fields provide the string and are used for facets
  # 'search' is a new fieldType which is defined in the solr schema.xml
  # 'new_tesim' already exists as fieldType 'tesim' in schema.xml
  # 'facet_ssim' already exists as fieldType 'ssim' in schema.xml
  # For 'search' and new_tesim, altlabels from related objects have been merged into the array
  def modify_sdoc(sdoc)
    if 'Document' == sdoc['has_model_ssim'][0]
      return modify_tna_document(sdoc)
    end

    begin
      if 'Entry' == sdoc['has_model_ssim'][0]
        sdoc['repository_tesim'] = 'BIA'
      end

      # entries
      entry_type_new,entry_type_alt = get_preflabel_array(sdoc['entry_type_tesim'])
      sdoc['entry_type_facet_ssim'] = entry_type_new
      unless entry_type_alt.empty? then entry_type_new += entry_type_alt.compact end
      sdoc['entry_type_new_tesim'] = entry_type_new
      sdoc['entry_type_search'] = array_to_lowercase(entry_type_new)

      section_type_new,section_type_alt = get_preflabel_array(sdoc['section_type_tesim'])
      unless section_type_alt.empty? then section_type_new += section_type_alt.compact end
      sdoc['section_type_facet_ssim'] = section_type_new
      sdoc['section_type_new_tesim'] = section_type_new
      sdoc['section_type_search'] = array_to_lowercase(section_type_new)

      sdoc['summary_search'] = array_to_lowercase(sdoc['summary_tesim'])

      sdoc['marginalia_search'] = array_to_lowercase(sdoc['marginalia_tesim'])

      language_new,unused = get_preflabel_array(sdoc['language_tesim'])
      sdoc['language_new_tesim'] = language_new
      sdoc['language_facet_ssim'] = language_new
      sdoc['language_search'] = array_to_lowercase(language_new)

      subject_new, subject_alt = get_preflabel_array(sdoc['subject_tesim'])
      sdoc['subject_facet_ssim'] = subject_new
      unless subject_alt.empty? then subject_new += subject_alt.compact end
      sdoc['subject_new_tesim'] = subject_new
      sdoc['subject_search'] = array_to_lowercase(subject_new)

      sdoc['note_search'] = array_to_lowercase(sdoc['note_tesim'])

      sdoc['editorial_note_search'] = array_to_lowercase(sdoc['editorial_note_tesim'])

      sdoc['is_referenced_by_search'] = array_to_lowercase(sdoc['is_referenced_by_tesim'])

      sdoc['place_as_written_search'] = array_to_lowercase(sdoc['place_as_written_tesim'])

      # related places
      place_name_authority_new,place_name_authority_alt = get_preflabel_array(sdoc['place_same_as_tesim'])
      sdoc['place_same_as_facet_ssim'] = place_name_authority_new
      unless place_name_authority_alt.empty? then place_name_authority_new += place_name_authority_alt.compact end
      sdoc['place_same_as_new_tesim'] = place_name_authority_new
      sdoc['place_same_as_search'] = array_to_lowercase(place_name_authority_new)

      place_role_new,place_role_alt = get_preflabel_array(sdoc['place_role_tesim'])
      sdoc['place_role_facet_ssim'] = place_role_new
      unless place_role_alt.empty? then place_role_new += place_role_alt.compact end
      sdoc['place_role_new_tesim'] = place_role_new
      sdoc['place_role_search'] = array_to_lowercase(place_role_new)

      place_type_new,place_type_alt = get_preflabel_array(sdoc['place_type_tesim'])
      sdoc['place_type_facet_ssim'] = place_type_new
      unless place_type_alt.empty? then place_type_new += place_type_alt.compact end
      sdoc['place_type_new_tesim'] = place_type_new
      sdoc['place_type_search'] = array_to_lowercase(place_type_new)

      sdoc['place_note_search'] = array_to_lowercase(sdoc['place_note_tesim'])

      sdoc['person_as_written_search'] = array_to_lowercase(sdoc['person_as_written_tesim'])

      # related agents
      person_name_authority_new,person_name_authority_alt = get_preflabel_array(sdoc['person_same_as_tesim'])
      #sdoc['person_same_as_facet_ssim'] = person_name_authority_new
      sdoc['person_same_as_facet_ssim'] = Indexer::PersonFacetHelper.s_get_person_facets_from_entry(get_id(sdoc[:id]))

      unless person_name_authority_alt.empty? then person_name_authority_new += person_name_authority_alt.compact end
      sdoc['person_same_as_new_tesim'] = person_name_authority_new
      sdoc['person_same_as_search'] = array_to_lowercase(person_name_authority_new)

      person_role_new,person_role_alt = get_preflabel_array(sdoc['person_role_tesim'])
      sdoc['person_role_facet_ssim'] = person_role_new
      unless person_role_alt.empty? then person_role_new += person_role_alt.compact end
      sdoc['person_role_new_tesim'] = person_role_new
      sdoc['person_role_search'] = array_to_lowercase(person_role_new)

      person_descriptor_new,person_descriptor_alt = get_preflabel_array(sdoc['person_descriptor_tesim'])
      sdoc['person_descriptor_facet_ssim'] = person_descriptor_new
      unless person_descriptor_alt.empty? then person_descriptor_new += person_descriptor_alt.compact end
      sdoc['person_descriptor_new_tesim'] = person_descriptor_new
      sdoc['person_descriptor_search'] = array_to_lowercase(person_descriptor_new)

      sdoc['person_descriptor_as_written_search'] = array_to_lowercase(sdoc['person_descriptor_tesim'])

      sdoc['person_note_search'] = array_to_lowercase(sdoc['person_note_tesim'])

      sdoc['person_related_place_search'] = array_to_lowercase(sdoc['person_related_place_tesim'])

      sdoc['person_related_person_search'] = array_to_lowercase(sdoc['person_related_person_tesim'])

      # dates
      date_role_new,date_role_alt = get_preflabel_array(sdoc['date_role_tesim'])
      sdoc['date_role_facet_ssim'] = date_role_new
      unless date_role_alt.empty? then date_role_new += date_role_alt.compact end
      sdoc['date_role_new_tesim'] = date_role_new
      sdoc['date_role_search'] = array_to_lowercase(date_role_new)

      sdoc['date_note_search'] = array_to_lowercase(sdoc['date_note_tesim'])

      # date_facet = get_date_array(get_id(sdoc[:id]))
      date_facet = Indexer::DateFacetHelper.s_get_date_facets_from_entry(get_id(sdoc[:id]))

      sdoc['date_facet_ssim'] = date_facet[0] unless date_facet.blank?
      sdoc['date_full_ssim'] = date_facet[1] unless date_facet.blank?

      # Store SingleDate in single Solr dynamic field e.g. *_ssi (Note *_dttsi requieres dates in ISO format)
      # Downcase occassional dates with comments
      sdoc['date_new_ssi'] = sdoc['date_tesim'][0].downcase unless sdoc['date_tesim'].blank?

      # add the register name and folio label to the entries
      register_new,folio_new = get_entry_register_array(sdoc['folio_ssim'])
      sdoc['entry_register_facet_ssim'] = register_new
      sdoc['entry_folio_facet_ssim'] = folio_new

      # facets from dates, related places/agents and folio/register added to entries
      # these runs on everything because it uses id, the only other field that ALL entries have is entry_no, but that is not unique
      entry_place_name_authority_new = get_entry_place_array(get_id(sdoc[:id]))
      sdoc['entry_place_same_as_facet_ssim'] = entry_place_name_authority_new

      entry_person_name_authority_new = get_entry_agent_array(get_id(sdoc[:id]))
      sdoc['entry_person_same_as_facet_ssim'] = entry_person_name_authority_new

      entry_date_new = get_entry_date_array(get_id(sdoc[:id]))
      sdoc['entry_date_facet_ssim'] = entry_date_new

      sdoc

    rescue => error
      log_error(__method__, __FILE__, error)
      raise
    end
  end

  # Convert field to lowercase so that all variations can be searched
  # for in the search interface, e.g. 'Paul' 'PAUL', 'paul'
  def array_to_lowercase(old_array)

    begin

      new_array = []

      if old_array != nil
        old_array.each do |t|
          new_array << t.downcase unless t.nil?
        end
      end

      return new_array

    rescue => error
      log_error(__method__, __FILE__, error)
      raise
    end

  end

  # Return name array for the corresponding ids
  def get_preflabel_array(input_array)

    begin

      preflabel_array = []
      altlabel_array = []

      if input_array != nil

        input_array.each do |id|
          SolrQuery.new.solr_query('id:' + id, 'preflabel_tesim,altlabel_tesim', 1)['response']['docs'].map do |result|
            preflabel = result['preflabel_tesim'].join unless result['preflabel_tesim'].nil?
            altlabel = result['altlabel_tesim'].join unless result['altlabel_tesim'].nil?
            preflabel_array << preflabel
            altlabel_array << altlabel
          end
        end
      end

      return preflabel_array, altlabel_array

    rescue => error
      log_error(__method__, __FILE__, error)
      raise
    end

  end

  # Return name array for the corresponding related ids
  def get_entry_place_array(id)
    begin

      preflabel_array = []

      query = SolrQuery.new
      q = 'relatedPlaceFor_ssim:' + id

      unless id.nil?
        num = query.solr_query(q, 'place_same_as_tesim', 0)['response']['numFound'].to_i
        query.solr_query(q, 'place_same_as_tesim', num)['response']['docs'].map do |result|
          unless result['place_same_as_tesim'].nil?
            result['place_same_as_tesim'].each do |place|
              query.solr_query('id:' + place, 'preflabel_tesim', 1)['response']['docs'].map do |result2|
                preflabel = result2['preflabel_tesim'].join unless result2['preflabel_tesim'].nil?
                preflabel_array << preflabel
              end
            end
          end
        end
      end
      preflabel_array

    rescue => error
      log_error(__method__, __FILE__, error)
      raise
    end

  end

  def get_entry_agent_array(id)
    begin
      preflabel_array = []
      query = SolrQuery.new
      q = 'relatedAgentFor_ssim:' + id

      unless id.nil?
        num = query.solr_query(q, 'person_same_as_tesim', 0)['response']['numFound'].to_i
        query.solr_query(q, 'person_same_as_tesim', num)['response']['docs'].map do |result|
          unless result['person_same_as_tesim'].nil?
            result['person_same_as_tesim'].each do |agent|
              query.solr_query('id:' + agent, 'preflabel_tesim', 1)['response']['docs'].map do |result2|
                preflabel = result2['preflabel_tesim'].join unless result2['preflabel_tesim'].nil?
                preflabel_array << preflabel
              end
            end
          end
        end
      end

      preflabel_array

    rescue => error
      log_error(__method__, __FILE__, error)
      raise
    end

  end

  # Return date array for the corresponding related dates
  def get_entry_date_array(id)

    begin

      date_array = []
      query = SolrQuery.new
      q = 'entryDateFor_ssim:' + id

      unless id.nil?
        num = query.solr_query(q, 'id', 0)['response']['numFound'].to_i
        query.solr_query(q, 'id', num)['response']['docs'].map do |result|
          query.solr_query('dateFor_ssim:' + result['id'], 'date_tesim', 1)['response']['docs'].map do |result2|
            unless result2['date_tesim'].nil?
              result2['date_tesim'].each do |date_tesim|
                # get year only
                date = date_tesim.gsub('[', '').gsub(']', '')
                begin
                  # get the first four chars; if these are a valid number over 1000 add them
                  if date[0..3].to_i >= 1000
                    date_array << date[0..3].to_i
                  end
                rescue
                  # if the value isn't a number, skip
                end
              end
            end
          end
        end
      end
      date_array

    rescue => error
      log_error(__method__, __FILE__, error)
      raise
    end

  end

  def get_date_array(id)

    begin

      date_array = []
      query = SolrQuery.new
      q = 'id:' + id

      unless id.nil?
        query.solr_query(q, 'date_tesim', 1)['response']['docs'].map do |result|
          unless result['date_tesim'].nil?
            result['date_tesim'].each do |date_tesim|
              # get year only
              date = date_tesim.gsub('[', '').gsub(']', '')
              begin
                # get the first four chars; if these are a valid number over 1000 add them
                if date[0..3].to_i >= 1000
                  date_array << date[0..3].to_i
                end
              rescue
                # if the value isn't a number, skip
              end
            end
          end
        end
      end
      date_array

    rescue => error
      log_error(__method__, __FILE__, error)
      raise
    end

  end

  # Return name array for the corresponding related registers and folios
  def get_entry_register_array(folio)

    begin
      register_array = []
      folio_array = []

      unless folio.nil?
        SolrQuery.new.solr_query('id:' + folio[0], 'isPartOf_ssim,preflabel_tesim', 1)['response']['docs'].map do |result|
          unless result['preflabel_tesim'].nil?
            folio_array << result['preflabel_tesim'][0].gsub('Abp Reg','Register')
          end
          unless result['isPartOf_ssim'].nil?
            SolrQuery.new.solr_query('id:' + result['isPartOf_ssim'][0], 'reg_id_tesim,date_tesim', 1)['response']['docs'].map do |result2|
              reg = ''
              unless result2['reg_id_tesim'].nil?
                reg = result2['reg_id_tesim'][0].gsub('Abp Reg','Register')
              end
              unless result2['date_tesim'].nil?
                reg += " (#{result2['date_tesim'][0]})"
              end
              register_array << reg
            end
          end
        end
      end
      return register_array, folio_array

    rescue => error
      log_error(__method__, __FILE__, error)
      raise
    end

  end

  def get_id(o)
    id = (o.include? '/') ? o.rpartition('/').last : o
  end

  # From RelatedPlace(AR), TnaPlace(TNA), PlaceOfDating(TNA)
  # Get place_same_as(string) and place_written_as(string)
  # input_array: array of linked object ids
  # return [place_same_as],[place_as_written]
  def get_place_array(document_id)
    begin
      place_same_as_array = []
      place_same_as_facet_array = []
      place_same_as_search_array = []
      place_as_written_array = []

      fields_to_query = ['placeOfDatingFor_ssim','tnaPlaceFor_ssim']
      unless document_id.blank?
        fields_to_query.each do |query_field|
          @solr_server.query("#{query_field}:#{document_id}", 'place_same_as_tesim,place_same_as_facet_ssim,place_same_as_search,place_as_written_tesim', 65535)['response']['docs'].map do |result|
            unless result['place_as_written_tesim'].nil?
              place_as_written = result['place_as_written_tesim']

              place_as_written.each do |paw|
                place_as_written_array << paw.squish
              end
            end

            unless result['place_same_as_tesim'].nil?
              place_same_as = result['place_same_as_tesim']
              place_same_as.each do |psa|
                place_same_as_array << psa.squish
              end
            end

            unless result['place_same_as_facet_ssim'].nil?
              place_same_as_facets = result['place_same_as_facet_ssim']
              place_same_as_facets.each do |psaf|
                place_same_as_facet_array << psaf.squish
              end
            end

            unless result['place_same_as_search'].nil?
              place_same_as_search = result['place_same_as_search']
              place_same_as_search.each do |psas|
                place_same_as_search_array << psas.squish
              end
            end
          end
        end
      end

      return place_same_as_array, place_same_as_facet_array, place_same_as_search_array, place_as_written_array

    rescue => error
      log_error(__method__, __FILE__, error)
      raise
    end

  end

end