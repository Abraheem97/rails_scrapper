# spec/services/scraper_service_spec.rb

require 'rails_helper'
require 'vcr'

RSpec.describe ScraperService do
  let(:test_url) { 'https://www.alza.cz/aeg-7000-prosteam-lfr73964cc-d7635493.htm' }

  let(:fields_config) do
    {
      price: '.price-box__primary-price__value',
      rating_value: '.ratingValue',
      rating_count: '.ratingCount',
      meta: ['keywords', 'twitter:image']
    }
  end

  let(:expected_result) do
    {
      price: ['15 990,-', '512,-'],
      rating_value: '4,9',
      rating_count: '25 hodnocení',
      meta: {
        'keywords' => 'AEG,7000,ProSteam®,LFR73964CC,Automatické pračky,Automatické pračky AEG,Chytré pračky,Chytré pračky AEG',
        'twitter:image' => 'https://image.alza.cz/products/AEGPR065/AEGPR065.jpg?width=360&height=360'
      }
    }
  end

  def normalize(text)
    Array(text).map { |t| t.to_s.gsub(/\u00a0|\s+/, ' ').strip }
  end

  before do
    Rails.cache.clear
  end

  describe '#extract', vcr: { cassette_name: 'alza_product_scrape', record: :new_episodes } do
    it 'returns correctly extracted data from the product page' do
      service = described_class.new(test_url)
      result = service.extract(fields_config)

      expect(normalize(result[:price])).to eq(normalize(expected_result[:price]))
      expect(result[:rating_value]).to eq(expected_result[:rating_value])
      expect(result[:rating_count]).to eq(expected_result[:rating_count])
      expect(result[:meta]).to eq(expected_result[:meta])
    end

    it 'stores HTML content in cache after first scrape' do
      service = described_class.new(test_url)
      cache_key = "scraped_html:#{test_url}"
      service.extract(fields_config)

      expect(Rails.cache.exist?(cache_key)).to be true
      expect(Rails.cache.read(cache_key)).to be_present
    end

    it 'uses cached content on subsequent calls' do
      service = described_class.new(test_url)

      first_result = service.extract(fields_config)
      second_result = service.extract(fields_config)

      expect(second_result).to eq(first_result)
    end
  end

  describe 'private methods' do
    let(:service) { described_class.new(test_url) }
    let(:html_content) do
      VCR.use_cassette('alza_product_scrape') do
        service.extract(fields_config)
        Rails.cache.read("scraped_html:#{test_url}")
      end
    end
    let(:doc) { Nokogiri::HTML(html_content) }

    describe '#extract_css_content' do
      it 'returns correct array for price' do
        result = service.send(:extract_css_content, doc, '.price-box__primary-price__value')
         expect(normalize(result)).to eq(normalize(expected_result[:price]))
      end

      it 'returns string for rating_value' do
        result = service.send(:extract_css_content, doc, '.ratingValue')
        expect(result).to eq(expected_result[:rating_value])
      end

      it 'returns nil for non-existent selector' do
        result = service.send(:extract_css_content, doc, '.non-existent-class')
        expect(result).to be_nil
      end
    end

    describe '#extract_meta_tags' do
      it 'returns correct meta tag values' do
        result = service.send(:extract_meta_tags, doc, ['keywords', 'twitter:image'])
        expect(result).to eq(expected_result[:meta])
      end
    end
  end
end
