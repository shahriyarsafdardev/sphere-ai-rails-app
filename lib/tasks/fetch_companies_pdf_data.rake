# frozen_string_literal: true

require 'faraday'
require 'nokogiri'
require 'open-uri'
require 'pdf-reader'

desc 'Fetch companies all pdf documents data after bing search'
task :fetch_companies_pdf_data, [:companies] => [:environment] do |_t, _args|
  companies = _args[:companies].split(' ')
  companies.each do |company|
    search_sentence = "#{company} investor relations"
    puts "Query: #{search_sentence}"
    puts 'URLs from bing search'
    results = bing_search(search_sentence)
    page_html, url = extract_page_data(results)
    pdf_links = extract_pdf_links(page_html, url)
    company = Company.find_or_create_by(name: company)

    pdf_links.each do |pdf_link|
      next unless Document.find_by(url: pdf_link).nil?

      publish_date, title, transcript = extract_pdf_text(pdf_link)
      unless transcript.nil?
        new_doc = Document.create(published_at: publish_date, title: title, url: pdf_link, company_id: company.id, transcript: transcript)
        puts "Created Document with id: #{new_doc.id}"
      end
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
  html = fetch_html(url)
  [html, url]
end

def fetch_html(url)
  res = Faraday.get(url)
  return nil unless res.status == 200

  puts "URL: #{url}"

  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('user-agent=Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/111.0.0.0 Safari/537.36')
  driver = Selenium::WebDriver.for(:chrome, options: options)
  driver.get(url)
  driver.execute_script('return document.readyState')
  document = driver.find_element(tag_name: 'body')
  html = document.attribute('innerHTML')
  driver.quit

  html
end

def extract_pdf_links(html, url)
  domain = URI(url).host
  doc = Nokogiri::HTML(html)
  pdf_links = doc.css('a[href$=".pdf"]').map { |link| link['href'] } || []
  pdf_links.map do |pdf_link|
    update_pdf_link(pdf_link, domain)
  end
end

def update_pdf_link(pdf_link, domain)
  if pdf_link.exclude?('https') && pdf_link.exclude?('http')
    pdf_domain = URI(pdf_link).host
    pdf_link = pdf_link.gsub(%r{\A[/.]+}, '')
    pdf_link = if !pdf_domain
                 "https://#{domain}/#{pdf_link}"
               else
                 "https://#{pdf_link}"
               end
  end
  pdf_link
end

def extract_pdf_text(pdf_link)
  page_json = []

  begin
    pdf = URI.open(pdf_link)
    reader = PDF::Reader.new(pdf)
    reader_info = reader.info
    pages = reader.pages
    puts "PDF Link >> #{pdf_link}"
    pages.each_with_index do |page, i|
      page_json << { number: "#{i + 1}", text: page.text.squeeze.strip }
    end
    [reader_info[:ModDate] || reader_info[:CreationDate], reader_info[:Title], page_json]
  rescue StandardError => e
    puts e
    [nil, nil, nil]
  end
end
