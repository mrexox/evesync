class Package
  attr_accessor :name, :version

  def initialize(params)
    @name = params[:name]
    @version = params[:version]
  end
end
