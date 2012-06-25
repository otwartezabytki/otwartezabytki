class GeocoderController < ApplicationController
  def search

    query = if params[:query].present?
      params[:query]
    else
      street = params[:street]
      city = params[:city]
      commune = params[:commune]
      district = params[:district]
      voivodeship = params[:voivodeship]

      head :bad_request and return unless voivodeship.present? && district.present? && commune.present?
      query = "#{voivodeship}, #{district}, #{commune}, #{city}"
      street.present? ? query + ", #{street}" : query
    end

    results = fetch_reqults(query)
    results = fetch_reqults("#{voivodeship}, #{district}, #{commune}, #{city}") if results.size == 0
    results = fetch_reqults("#{voivodeship}, #{district}, #{commune}") if results.size == 0
    results = fetch_reqults("#{voivodeship}, #{district}") if results.size == 0
    results = fetch_reqults("#{city}") if results.size == 0

    render :json => results
  end

  private

  def fetch_reqults(query)
    result = []
    Geocoder.search(query).each do |e|
      result.push({
        :latitude => e.latitude,
        :longitude => e.longitude
      })
    end

    result
  end
end
