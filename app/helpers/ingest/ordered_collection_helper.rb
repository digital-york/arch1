module Ingest
    module OrderedCollectionHelper
        # create a new ordered collection
        # return the id of newly created ordered collection
        def self.create_ordered_colleciton(pref_label)
            c = OrderedCollection.new
            c.rdftype = c.add_rdf_types
            c.preflabel = pref_label

            c.save

            c
        end


    end
end