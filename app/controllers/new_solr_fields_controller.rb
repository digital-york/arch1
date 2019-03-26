class NewSolrFieldsController < ApplicationController

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

    begin

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
      sdoc['person_same_as_facet_ssim'] = person_name_authority_new
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

      date_facet = get_date_array(sdoc[:id])
      sdoc['date_facet_ssim'] = date_facet

      # add the register name and folio label to the entries
      register_new,folio_new = get_entry_register_array(sdoc['folio_ssim'])
      sdoc['entry_register_facet_ssim'] = register_new
      sdoc['entry_folio_facet_ssim'] = folio_new

      # facets from dates, related places/agents and folio/register added to entries
      # these runs on everything because it uses id, the only other field that ALL entries have is entry_no, but that is not unique
      entry_place_name_authority_new = get_entry_place_array(sdoc[:id])
      sdoc['entry_place_same_as_facet_ssim'] = entry_place_name_authority_new

      entry_person_name_authority_new = get_entry_agent_array(sdoc[:id])
      sdoc['entry_person_same_as_facet_ssim'] = entry_person_name_authority_new

      entry_date_new = get_entry_date_array(sdoc[:id])
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
                preflabel = result2['preflabel_tesim'].join unless result['preflabel_tesim'].nil?
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
                preflabel = result2['preflabel_tesim'].join unless result['preflabel_tesim'].nil?
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

end
