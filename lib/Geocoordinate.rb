class Geocoordinate

  def self.location_geocoordinate(location)
    begin
      # RestClient.proxy = "http://127.0.0.1:8089/"
      # use the google geocoding api load the location geocoordinate
      res = RestClient.get("https://maps.googleapis.com/maps/api/geocode/json?latlng=#{location[:lat]},#{location[:lng]}&key=#{Settings.google_map.geocoding_apikey}")
      results = JSON.parse(res.body)["results"]
      Rails.logger.debug results
      if results.empty?
        return { status: -1, msg: 'not load the location geocoordinate'}
      end
      address = address_to_geocoordinate(results.first["address_components"])
    rescue Exception => e
      return { status: -2, msg: e.message}
    end
  end

  def self.nearest_gas_station(location)
    begin
      # use the google map api get the nearest gas station place id
      res = RestClient.get("https://maps.googleapis.com/maps/api/place/radarsearch/json?location=#{location[:lat]},#{location[:lng]}&radius=5000&type=gas_station&key=#{Settings.google_map.places_apikey}")
      results = JSON.parse(res.body)["results"]
      Rails.logger.debug results
      if results.empty?
        return { status: -1, msg: 'not found any gas station'}
      end
      place_id = results.first["place_id"]
      # use the google map api load the nearest gas station geocoordinate
      res = RestClient.get("https://maps.googleapis.com/maps/api/place/details/json?placeid=#{place_id}&key=#{Settings.google_map.places_apikey}")
      result = JSON.parse(res.body)["result"]["address_components"]
      nearest_gas_station = address_to_geocoordinate(result)
    rescue Exception => e
      return { status: -2, msg: e.message}
    end
  end

  private

  def self.address_to_geocoordinate(address_components)
    street_number = address_components[0]["short_name"]
    route = address_components[1]["short_name"]
    city = address_components[3]["long_name"]
    state = address_components[5]["short_name"]
    postal_code = address_components[7]["short_name"]
    begin
      postal_code_suffix = '-' + address_components[8]["short_name"]
    rescue Exception => e
      postal_code_suffix = ''
    end
    {
      "streetAddress": "#{street_number} #{route}",
      "city": city,
      "state": state,
      "postalCode": "#{postal_code}#{postal_code_suffix}"
    }
  end
end
