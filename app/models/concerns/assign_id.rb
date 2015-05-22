module AssignId
  extend ActiveSupport::Concern

  included do
    @id_path = ''
  end

  # need to be passed the identifier part for sh
  def assign_id
    @id_path + Time.now.strftime("%Y/%m/%d/%H/%M/") + noid_service.mint
  end

  def set_id_path(p)
    p.gsub(/\s+/, "") # remove whitespace
    if p.end_with?('/')
      @id_path = p
    else
      @id_path = p + '/'
    end
  end

  private

  def noid_service
    @noid_service ||= ActiveFedora::Noid::Service.new
  end

end