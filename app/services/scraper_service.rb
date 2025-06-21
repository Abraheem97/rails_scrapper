# app/services/scraper_service.rb

class ScraperService
  def initialize(url)
    @url = url
  end

  def extract(fields_config)
    html = fetch_with_cache
    doc = Nokogiri::HTML(html)
    result = {}

    fields_config.each do |field_name, selector|
      result[field_name] = if selector.is_a?(Array)
                             extract_meta_tags(doc, selector)
                           else
                             extract_css_content(doc, selector)
                           end
    end

    result
  rescue StandardError => e
    raise "Scraping failed: #{e.message}"
  end

  private

  def fetch_with_cache
    Rails.cache.fetch("scraped_html:#{@url}", expires_in: 1.hour) do
      fetch_with_stealth
    end
  end

  def fetch_with_stealth
    headers = {
      'User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)...',
      'Accept' => 'text/html,application/xhtml+xml,...',
      'Connection' => 'keep-alive',
      'Upgrade-Insecure-Requests' => '1'
    }

    response = HTTParty.get(@url, headers: headers, timeout: 10, follow_redirects: true)
    
    # Save the response body to debug.html
    File.write("debug.html", response.body)

    raise "Blocked by CAPTCHA" if response.body.include?('captcha') || response.body.include?('human')

    response.body
  rescue => e
    raise "Scraping failed: #{e.message}"
  end

  def extract_css_content(doc, selector)
    elements = doc.css(selector)
    return nil if elements.empty?
    elements.size == 1 ? elements.first.text.strip : elements.map { |el| el.text.strip }
  end

  def extract_meta_tags(doc, names)
    names.each_with_object({}) do |name, result|
      meta = if name == 'keywords'
               doc.at_css('meta[name="keywords"]')
             else
               doc.at_css("meta[name='#{name}'], meta[property='#{name}']")
             end
      result[name] = meta&.[]('content')
    end
  end
end
