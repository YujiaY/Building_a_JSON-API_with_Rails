class UserSerializer < ActiveModel::Serializer
  attributes :id, :half_email,:created_at, :say_hello

  def half_email 
    emails = object.email.split("@") 
    "#{emails[0].first}*@#{emails[1]}" 
  end 

   def say_hello
    "Hello #{object.email}!"
  end
  has_many :posts
end
