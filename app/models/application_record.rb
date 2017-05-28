class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def default_serializer_options
   { root: false }
  end
end
