class CompareController < ApplicationController

def index
  @user = session[:current_user]
  render :index
end

end
