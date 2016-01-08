namespace :proxies do
  desc "TODO"
  task pox: :environment do

    f1 = Folio.create(id: 'folio19')
    f1.preflabel = 'folio 19'
    f2 = Folio.create(id: 'folio20')
    f2.preflabel = 'folio 20'
    f3 = Folio.create(id: 'folio21')
    f3.preflabel = 'folio 21'

    reg = Register.create(id: 'register7')

    reg.ordered_folio_proxies.append_target f1
    #reg.ordered_folio_proxies.append_target f2
    reg.save
    #puts reg.folios # => [generic_file2, generic_file]
    #puts reg.ordered_folios # => [generic_file2, generic_file]

# Not all generic files must be ordered.
    #reg.folios += [f3]
    #reg.folios # => [generic_file2, generic_file, generic_file3]
    #reg.ordered_folios # => [generic_file2, generic_file]

# non-ordered accessor is not ordered.
    #reg.ordered_folio_proxies.insert_target_at(0, f3)
    #reg.folios # => [generic_file2, generic_file, generic_file3]
    #reg.ordered_folios # => [generic_file3, generic_file2, generic_file]

    #reg.save

# Deletions
    #reg.ordered_folio_proxies.delete_at(1)
    #reg.ordered_folios # => [generic_file3, generic_file]

  end

  task order: :environment do

    action = 'next_tesim'
    id = 'folio7'

    next_id = ''

    if action != nil && id != nil
      register = Register.find('register3')

      SolrQuery.new.solr_query('id:"' + register.id + '/list_source"', 'ordered_targets_ssim')['response']['docs'].map.each do |result|
        order = result['ordered_targets_ssim']
        hash = Hash[order.map.with_index.to_a]
        if action == 'next_tesim'
          next_id = order[hash[id] + 1]
        elsif action == 'prev_tesim'
          next_id = order[hash[id] - 1]
        end
      end
    end
    puts next_id
  end

  task order2: :environment do
    register = 'register3'
    @folio_list = []
    folio_hash = {}

    # Get the list of folios in order
    SolrQuery.new.solr_query('id:"' + register + '/list_source"', 'ordered_targets_ssim')['response']['docs'].map.each do |result|
      order = result['ordered_targets_ssim']
      # could change this to a single query
      q = ''
      order.each do |o|
        q += 'id:"' + o + '" OR '
      end
      if q.end_with? ' OR '
        q = q[0..q.length - 4]
      end
      SolrQuery.new.solr_query(q, 'id,preflabel_tesim')['response']['docs'].map.each do |res|
        folio_hash[res['id']] = res['preflabel_tesim'].join()
        @folio_list += [res['id'],folio_hash[res['id']]]
      end
    end

  end

end
