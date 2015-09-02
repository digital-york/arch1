module AssignId
  extend ActiveSupport::Concern

  included do
    require 'active_fedora/noid'
    # @id_path = ''
  end

  def assign_id
    noid_service.mint

    # This can be used to set our own 'pairtree' path, but now we're just using noid for that
    # @id_path + Time.now.strftime("%Y/%m/%d/%H/%M/") + noid_service.mint
    # if @id_path.nil?
    #   noid_service.mint
    # else
    #   @id_path + noid_service.mint
    # end
  end

  private
  def noid_service
    @noid_service ||= ActiveFedora::Noid::Service.new
  end

  # def set_id_path(p)
  #   p.gsub(/\s+/, "") # remove whitespace
  #   if p.end_with?('/')
  #     @id_path = p
  #   else
  #     @id_path = p + '/'
  #   end
  # end

end