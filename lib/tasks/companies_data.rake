# frozen_string_literal: true

require 'faraday'

desc 'Fetch companies html pages data after bing search'
task fetch_companies_data: [:environment] do |_t, _args|
  companies = %w[Apple Google Rakuten Nvidia Twilio]

  CSV.open('companies_data.csv', 'w') do |csv|
    csv << %w[Name URL HTML Type]
    companies.each do |company|
      search_sentence = "#{company} investor relations"
      puts "Query: #{search_sentence}"
      puts 'URLs from bing search'
      results = bing_search(search_sentence)
      page_doc, url = extract_page_data(results)
      csv << [company, url, page_doc, '']
    end
  end
end

def bing_search(search_sentence)
  conn = Faraday.new(url: 'https://api.bing.microsoft.com') do |faraday|
    faraday.request :url_encoded
    faraday.adapter Faraday.default_adapter
  end

  response = conn.get do |req|
    req.url '/v7.0/search'
    req.headers['Ocp-Apim-Subscription-Key'] = ENV['BING_SEARCH_API_KEY']
    req.params['q'] = search_sentence
    req.params['count'] = 1
    req.params['offset'] = 0
    req.params['mkt'] = 'en-US'
    req.params['responseFilter'] = 'WebPages'
  end

  JSON.parse(response.body)
end

def extract_page_data(results)
  result = results['webPages']['value'].first
  url = result['url']
  res = Faraday.get(url)
  return if res.status != 200

  puts "URL: #{url}"

  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('user-agent=Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/111.0.0.0 Safari/537.36')
  driver = Selenium::WebDriver.for(:chrome, options: options)
  driver.get(url)
  driver.execute_script('return document.readyState')
  html = driver.page_source
  driver.quit
  [html, url]
end
