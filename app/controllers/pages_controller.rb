class PagesController < ApplicationController
  get '/', provides: :html do
    erb :'pages/homepage'
  end
end
