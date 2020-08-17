module Ingest
    module OrderedCollectionHelper
        # create a new ordered collection
        # return the newly created ordered collection
        # e.g.
        #   c = Ingest::OrderedCollectionHelper.create_ordered_colleciton('Test collection')
        def self.create_ordered_colleciton(pref_label)
            c = OrderedCollection.new
            c.rdftype = c.add_rdf_types
            c.preflabel = pref_label

            c.save

            c
        end
    end
end