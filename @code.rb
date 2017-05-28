rails new my_blog --api
cd my_blog


rails g scaffold user email:string password:string auth_token:string

rails g scaffold post title:string body:text user:references

rails g scaffold comment body:text user:references post:references

rake db:migrate


rails server -e development

#Go to
http://localhost:3000/users

#Write db/seeds.rb
u1 = User.create(email: 'user@example.com', password: 'password')
u2 = User.create(email: 'user2@example.com', password: 'password')
 
p1 = u1.posts.create(title: 'First Post', body: 'An Airplane')
p2 = u1.posts.create(title: 'Second Post', body: 'A Train')
 
p3 = u2.posts.create(title: 'Third Post', body: 'A Truck')
p4 = u2.posts.create(title: 'Fourth Post', body: 'A Boat')
 
p3.comments.create(body: "This post was terrible", user: u1)
p4.comments.create(body: "This post was the best thing in the whole world", user: u1)


# app/model/user.rb
class User < ActiveRecord::Base
  has_many :posts
  has_many :comments
end

# app/model/post.rb
class Post < ActiveRecord::Base
  has_many :comments
en

	
rake db:seed

# database is now already set up.

# add in Gemfile
gem 'active_model_serializers'

gem install active_model_serializers

rails g serializer user

# And that will create the following file: 
# app/serializers/user_serializer.rb

class UserSerializer < ActiveModel::Serializer
  attributes :id
end

#Now, if you !restart the server! and navigate to your /users URL, you should see JSON that looks like this:
# http://localhost:3000/users
{users: [{id: 1},{id: 2}]}

### Or you can play like:
class UserSerializer < ActiveModel::Serializer
  attributes :id, :email

  def email 
    emails = object.email.split("@") 
    "#{emails[0].first}*@#{emails[1]}" 
  end 
end
#Then 
[{"id":1,"email":"u*@example.com"},{"id":2,"email":"u*@example.com"}]


#See how simple that was? This same serialization pattern will also carry over for all of your controller actions that handle GET requests that return JSON. Now go ahead and run the serializers for the remaining Post and Comment resources, and then we’ll get into some configuration:
rails g serializer post
rails g serializer comment


#Occasionally, you may want to modify the data that you return in JSON, but because this specific alteration is only meant for serialization cases, you don’t want to dirty up the model files by creating a model method. AMS provides a solution for that. You can create a method inside your serializer and therein access the current object being serialized, and then call that method with the same syntax as if it were an attribute on that object. Doesn’t make sense? Take a look at this example:
# app/serializers/user_serializer.rb

class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :created_at, :say_hello
 
  has_many :posts
 
  def say_hello
    "Hello #{object.email}!"
  end
end

###???? 
#If you don’t like the JSON syntax of having a root key like user or whatever resource you’re querying, then you can go back to the old syntax we had where it strictly returns either just the JSON representation of the object (e.g. show), or an array of JSON objects (e.g. index). You just have to add a short method in your application_controller.rb to set it globally: ????
# app/controllers/application_controller.rb
 
 def default_serializer_options
   { root: false }
 end

 #




###  For part 5
#Filtering Resources
# And we’re just going to change the first line of the action to this:
#  app/controllers/comments_controller.rb
 
  def index
    @comments = Comment.where(comment_params)
 
    render json: @comments
  end

# Then we would meet exception:
    "status": 400,
    "error": "Bad Request",
    "exception": "#<ActionController::ParameterMissing: param is missing or the value is empty: comment>",
one way to fix it is to modify app\controllers\comments_controller.rb

     def comment_params
      #params.require(:comment).permit(:body, :user_id, :post_id)
      params.permit(:body, :user_id, :post_id)
    end

# and

  if !Comment.where(comment_params).nil?
    @comments = Comment.where(comment_params)
  else
    @comments = Comment.all
   end

    render json: @comments
  end

# for the post_serializer.rb
# if you would like to add the user_id?
class PostSerializer < ActiveModel::Serializer
  attributes :id
  has_many :comments
  belongs_to :user_id
end

#To get AMS to use the JSON API spec, we literally have to add one line of code, and then we’ll automatically be blessed with some super sweet auto-formatting. You just need to !!create!! an initializer, add the following line, and restart your server:
# config/initializers/active_model_serializers.rb
ActiveModelSerializers.config.adapter = :json_api
##


