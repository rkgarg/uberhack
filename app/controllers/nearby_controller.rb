require 'pry'
require 'uber/uber_api'
class NearbyController < ApplicationController

  def all
    lat , long = params[:lat], params[:long]
    (render :json => {'a' => "fuckkyou send me 'lat' and 'long'"} and return) if lat.nil? or long.nil?
    url = "https://maps.googleapis.com/maps/api/place/search/json?location=#{lat},#{long}&radius=400&sensor=true&type=home_goods_store|atm|liquor_store&key=AIzaSyCiUL3FVScMAT9pXvETbzMQqNcuek2C2WQ"

    final_hash = []


    resp_google = HTTParty.get(URI.encode url)
    
    JSON.parse(resp_google.body)["results"].each do |r|
      final_hash.push(google_places_format(r))
    end


    events_url = "http://api.eventful.com/rest/events/search?where=#{lat},#{long}&within=10&app_key=cXjqgGx2gvVBqvjG"
    resp_events = HTTParty.get(URI.encode events_url)

    Hash.from_xml(resp_events.body)["search"]["events"]["event"].each do |r|
      final_hash.push(eventful_places_format(r))
    end



    resp_zom = HTTParty.get("https://developers.zomato.com/api/v2.1/search?lat=#{lat}&lon=#{long}&radius=2000",
    { 
      :headers => { 'Accept' => 'application/json', 'user_key' => 'c3fdcb7cd62590868c5de06df7538201'}
    })
    JSON.parse(resp_zom.body)["restaurants"].each do |r|
      final_hash.push(zom_format(r["restaurant"]))
    end


    render :json => final_hash
  end


  private


  def google_places_format obj
    {
      'lat' => obj["geometry"]["location"]["lat"],
      'long'=> obj["geometry"]["location"]["lng"],
      'icon' => obj["icon"],
      'name' => obj["name"],
      'categories' => obj["types"],
      'meta' => obj["vicinity"]
    }
  end


  def eventful_places_format obj
    {
      'lat' => obj["latitude"],
      'long'=> obj["longitude"],
      'name' => obj["title"] + obj["venue_name"],
      'categories' => ['Event'],
      'meta' => obj["vicinity"],
      'time' => obj["start_time"]
    }
  end

  def zom_format obj
    {
      'lat' => obj["location"]["latitude"],
      'long'=> obj["location"]["longitude"],
      'icon' => obj["thumb"],
      'name' => obj["name"],
      'categories' => ['Zomato'],
      'meta' => obj["cuisines"]      
    }
  end

  def get_request_and_route
    a = Uber::UberApi.new.get_request
    route = [[28.261492, 77.1423941], [28.261492, 77.1423941]]
    eta = a['eta']
    render :json => {route: route, eta: eta}
  end


end
