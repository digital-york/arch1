module AssignId
  extend ActiveSupport::Concern

  # included do
  #   @id_path = ''
  # end

  def assign_id
    # commented out line will create a date-based 'pairtree' structure in fedora
    # @id_path + Time.now.strftime("%Y/%m/%d/%H/%M/") + noid_service.mint
    # this can also be done with NOID automagically, see NOID documentation
    # if @id_path.nil?
    #   noid_service.mint
    # else
    #   @id_path + noid_service.mint
    # end

    noid_service.mint

  end

  # def set_id_path(p)
  #   p.gsub(/\s+/, "") # remove whitespace
  #   if p.end_with?('/')
  #     @id_path = p
  #   else
  #     @id_path = p + '/'
  #   end
  # end

  private

  def noid_service
    @noid_service ||= ActiveFedora::Noid::Service.new
  end

end