# frozen_string_literal: true

class ScraperController < ApplicationController
  def new; end

  def scrape
    @url = params[:url]
    @fields_input = params[:fields]

    begin
      fields = JSON.parse(@fields_input)
      scraper = ScraperService.new(@url)
      @result = scraper.extract(fields)
    rescue JSON::ParserError
      @error = 'Invalid JSON format in fields.'
    rescue StandardError => e
      @error = "Scraping failed: #{e.message}"
    end

    render :new
  end
end
