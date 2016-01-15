module Uber
  class UberApi
    include HTTParty
    HTTP_TIMEOUT = 10
    BASE_URI = "https://sandbox-api.uber.com/v1/"

    AUTHENTICATION_HEADERS = {"Content-Type"=>"application/json",
                              "Authorization"=>"Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJzY29wZXMiOlsicmVxdWVzdCJdLCJzdWIiOiI0OWI0NzIyMS0xOTg1LTQwYmEtOWFmOS02MTVhNDZlYTRmOTMiLCJpc3MiOiJ1YmVyLXVzMSIsImp0aSI6IjVlMTQ0M2UyLTAxODQtNGMxZC1iNzg2LTQzMjA1NTRhNGIzOCIsImV4cCI6MTQ1NTQ0NTE2MywiaWF0IjoxNDUyODUzMTYyLCJ1YWN0IjoiRDBmcjB0NzZ3WHZUdXVwSDVDUjhXODBrMEtNNVQzIiwibmJmIjoxNDUyODUzMDcyLCJhdWQiOiJXWWpfMXRBZk9ISjFtYUtpT1ZNc1ZNdXRLUWtwOVBtbyJ9.g2Pq1DY-nrXURJs_Re14Sa_OwN_pWaaP4H4cdjlOd_3UVQOwa8emA-HfHu5H35dTuGJF5Vq7wFHzI2akAkViuxR_WlO67hIWXpY5Tt3fpXOkSo9GwQmoEBxqcK7wyDINSGApN3MM1zBwP2NPn6FxUr-em5MIcA45RP5cLPuWuF7yYZACOShMmZGNn8qlXL8SdEG7IhaUys3tPuiIIt3CCt69MygQUJ3cJMT69WZYEcvgRqFzI2YeXtKBNi0aTt2iCghsjar8npUuurOHQuBfpqPpjYcZDQYiTsUQTYS33RvxLeP4uabRAZM7xI0vQug3OhGy80soim9GSd89nl4H3Q"}

    def get_request
      get("requests/current")
    end

    private

    def get(url_path)
      address = BASE_URI + url_path
      self.class.get(address, {headers: AUTHENTICATION_HEADERS })
    end

  end
end