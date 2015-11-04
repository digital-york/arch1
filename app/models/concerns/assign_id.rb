module AssignId
  extend ActiveSupport::Concern

  included do
    require 'active_fedora/noid'
  end

  def assign_id
    noid_service.mint
  end

  def create_container_id(parent)
    if self.class.name == 'ContainedFile'
      "#{parent}/files/#{noid_service.mint}"
    else
      "#{parent}/#{self.class.name.pluralize.downcase}/#{noid_service.mint}"
    end
  end

  private
  def noid_service
    @noid_service ||= ActiveFedora::Noid::Service.new
  end

end