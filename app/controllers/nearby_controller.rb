class NearbyController < ApplicationController

  def all
    binding.pry
    render :json => {'a' => "1"}
  end
end
