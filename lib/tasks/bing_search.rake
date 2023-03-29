# frozen_string_literal: true

require 'faraday'
require 'nokogiri'
require 'open-uri'
require 'pdf-reader'

desc 'Search for company investors in bing search'
task :company_bing_search_new, [:company_name] => [:environment] do |_t, args|
  search_sentence = "#{args['company_name']} investor relations"
  puts "Query: #{search_sentence}"

  results = bing_search(search_sentence)
  pdf_links = extract_pdf_links(results)
  all_paragraphs = extract_target_paragraphs(pdf_links)

  puts pdf_links.empty? ? 'No PDF links found' : "PDF links: #{pdf_links}"
  puts all_paragraphs.empty? ? 'No matching keywords in PDFs' : "Matching keyword paragraphs: #{all_paragraphs}"
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
    req.params['count'] = 5
    req.params['offset'] = 0
    req.params['mkt'] = 'en-US'
    req.params['responseFilter'] = 'WebPages'
  end

  JSON.parse(response.body)
end

def extract_pdf_links(results)
  pdf_links = []

  puts 'URLs from bing search'
  results['webPages']['value'].each do |result|
    url = result['url']
    res = Faraday.get(url)
    next if res.status != 200

    puts "URL: #{url}"
    html = URI.open(url).read
    doc = Nokogiri::HTML(html)

    sitemap_url = extract_sitemap_url(doc)
    puts "Sitemap URL: #{sitemap_url}" if sitemap_url

    pdf_links += extract_pdf_links_from_doc(doc, url)
  end

  pdf_links
end

def extract_sitemap_url(doc)
  sitemap_link = doc.at_css("a[href$='.xml'], a[href$='.xml.gz'], a[href*='sitemap'], a[href*='site-map'], a[href*='site_map'], link[rel='sitemap'], link[rel='alternate'][type='application/rss+xml']")
  sitemap_link['href'] if sitemap_link
end

def extract_pdf_links_from_doc(doc, url)
  updated_pdf_links = []
  pdf_links = doc.xpath('//@href').select { |link| link.to_s.end_with?('.pdf') }.map(&:to_s)
  domain = URI.parse(url).host
  pdf_links.each do |pdf_link|
    if pdf_link.exclude?('https') && pdf_link.exclude?('http')
      pdf_link = pdf_link.gsub(%r{\A[/.]+}, '')
      pdf_link = if pdf_link.exclude?(domain)
                   "https://#{domain}/#{pdf_link}"
                 else
                   "https://#{pdf_link}"
                 end
    end
    updated_pdf_links << pdf_link
  end
  updated_pdf_links
end

def extract_target_paragraphs(pdf_links)
  all_paragraphs = []

  pdf_links.each do |url|
    url = "https:#{url}" unless url.include?('https')
    begin
      pdf = URI.open(url)
      reader = PDF::Reader.new(pdf)
      text = reader.pages.map(&:text).join(' ')
      paragraphs = text.split(/\n\n+/)
      target_paragraphs = paragraphs.select { |p| p.match(/\b(goal|objective)\b/i) }
      all_paragraphs += target_paragraphs.map(&:squeeze) if target_paragraphs.present?
    rescue StandardError => e
      puts e
    end
  end
  all_paragraphs
end
