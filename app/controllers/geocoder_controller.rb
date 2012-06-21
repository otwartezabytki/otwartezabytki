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

    result = []
    Geocoder.search(query).each do |e|
      result.push({
        :latitude => e.latitude,
        :longitude => e.longitude
      })
    end

    render :json => result
  end
end
