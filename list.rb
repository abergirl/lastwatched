require 'rubygems'
require 'sinatra'
require 'data_mapper'
require 'json'
DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/checklist.rb")
	class Item
  include DataMapper::Resource
	property :id, Serial
	property :content, Text, :required => true
	property :done, Boolean, :required => true, default => false
	property :created, DateTime
  end
DataMapper.finalize.auto_upgrade!

# Route for /
get '/?' do
  @items = Item.all(:order => :created.desc)
  redirect '/new' if @items.empty?
 erb :index
end

# Route for /new
get '/new?' do
	@title = "Add Item"
	erb :new
end

   post '/new/?' do
	Item.create(:content => params[:content], :created => Time.now)
	redirect '/'
end	

# Route for /done
post '/done?' do
 	item = Item.first(:id => params[:id])
	item.done = !item.done
	item.save
	content_type 'application/json'
	value = item.done ? 'done' : 'Not Done'
	{ :id => params[:id], :status => value}.to_json
end

# Delete items
get '/delete/:id?' do
        @item = Item.first(:id => params[:id])
        erb :delete
end

post '/delete/:id?' do
   if params.has_key?("ok")
        item = Item.first(:id => params[:id])
        item.destroy
        redirect '/'
   else
        redirect '/'
   end
end
