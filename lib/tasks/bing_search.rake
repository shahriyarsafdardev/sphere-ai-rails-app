# frozen_string_literal: true

require 'faraday'
require 'nokogiri'
require 'open-uri'
require 'pdf-reader'

desc 'Search for company investors in bing search'
task :company_bing_search, [:company_name] => [:environment] do |_t, args|
  search_sentence = "#{args['company_name']} investor relations"
  puts "Query: #{search_sentence}"
  conn = Faraday.new(url: 'https://api.bing.microsoft.com') do |faraday|
    faraday.request :url_encoded
    faraday.adapter Faraday.default_adapter
  end
  response = conn.get do |req|
    req.url '/v7.0/search'
    req.headers['Ocp-Apim-Subscription-Key'] = ENV['BING_SEARCH_API_KEY']
    req.params['q'] = search_sentence
    req.params['count'] = 5
    req.params['offset'] = 0
    req.params['mkt'] = 'en-US'
    req.params['responseFilter'] = 'WebPages'
  end
  results = JSON.parse(response.body)
  pdf_links = []
  puts 'URLs from bing search'
  results['webPages']['value'].each do |result|
    res = conn.get(result['url'])
    next if res.status != 200

    puts "URL: #{result['url']}"
    html = URI.open(result['url']).read
    doc = Nokogiri::HTML(html)
    sitemap_link = doc.at_css("a[href$='.xml'], a[href$='.xml.gz'], a[href*='sitemap'], a[href*='site-map'], a[href*='site_map'], link[rel='sitemap'], link[rel='alternate'][type='application/rss+xml']")
    if sitemap_link
      sitemap_url = sitemap_link['href']
      puts "Sitemap URL>>  + #{sitemap_url}"
    end
    doc.xpath('//@href').each do |link|
      pdf_links << link.to_s if link.to_s.end_with?('.pdf')
    end
  end
  puts "PDF links: #{pdf_links}"
  all_paragraphs = []
  pdf_links.each do |url|
    text = ''
    url = "https:#{url}" unless url.include?('https')
    begin
      pdf = URI.open(url)
      reader = PDF::Reader.new(pdf)
      reader.pages.each do |page|
        text += "#{page.text} "
      end
      paragraphs = text.split(/\n\n+/)
      target_paragraphs = paragraphs.select do |p|
        p.match(/\b(goal|objective)\b/i)
      end

      target_paragraphs.each do |p|
        all_paragraphs << p
      end
    rescue StandardError => e
      puts e
    end
    puts all_paragraphs
  end
end
