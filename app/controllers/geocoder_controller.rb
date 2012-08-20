class GeocoderController < ApplicationController
  def search
    results = if params[:query].present?
      params[:query]
    elsif params[:country_code].present?
      search_foreign
    else
      search_polish
    end

    render :json => results
  end

  def search_polish
    street = params[:street]
    city = params[:city]
    commune = params[:commune]
    district = params[:district]
    voivodeship = params[:voivodeship]

    #head :bad_request and return unless voivodeship.present? && district.present? && commune.present?
    query = "#{voivodeship}, #{district}, #{commune}, #{city}"
    street.present? ? query + ", #{street}" : query

    results = fetch_results(query)
    results = fetch_results("#{voivodeship}, #{district}, #{commune}, #{city}") if results.size == 0
    results = fetch_results("#{voivodeship}, #{district}, #{commune}") if results.size == 0
    results = fetch_results("#{voivodeship}, #{district}") if results.size == 0
    results = fetch_results("#{city}") if results.size == 0

    return results
  end

  def search_foreign
    country_code = params[:country_code]
    place = params[:place]
    province = params[:province]
    street = params[:street]

    query = [street, place, province, country_code].compact.join(', ')
    results = fetch_results(query)

    return results
  end

  private

  def fetch_results(query)
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
