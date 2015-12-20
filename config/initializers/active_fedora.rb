ActiveFedora::Indexing.module_eval do

    extend ActiveSupport::Concern
    extend ActiveSupport::Autoload

   # Overridden 04/12/2015 (py)
   def to_solr(_solr_doc = {}, _opts = {})
      sdoc = indexing_service.generate_solr_document
      return NewSolrFieldsController.new.modify_sdoc(sdoc)
   end

end