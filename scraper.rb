require 'nokogiri'
require 'byebug'
require 'httparty'

def scraper
    url = 'https://www.indeed.com/jobs?q=software+engineer&l=Brooklyn%2C+NY'
    unparsed_page = HTTParty.get(url)
    parsed_page = Nokogiri::HTML(unparsed_page)
    job_list = Array.new
    
    jobs = parsed_page.css('div.jobsearch-SerpJobCard') # listings per page
    total = parsed_page.css('div#searchCountPages').text.split(' ')[3].gsub(',','').to_i # number of pages
    per_page = jobs.count
    page = 10
    last_page = ( total.to_f / per_page.to_f ).round

    while page <= last_page
        pagination_url = "https://www.indeed.com/jobs?q=software+engineer&l=Brooklyn%2C+NY&start=#{page}"
        puts "pagination_url"
        puts "Page: #{page}"
        puts ''
        pagination_unparsed_page = HTTParty.get(pagination_url)
        pagination_parsed_page = Nokogiri::HTML(pagination_unparsed_page)
        pagination_jobs = pagination_parsed_page.css('div.jobsearch-SerpJobCard')
        pagination_jobs.each do |job|
        job = {
            title: job.css('h2.title').text,
            company: job.css('span.company').text,
            location: job.css('div.location').text,
            description: job.css('div.summary').text,
            datePosted: job.css('span.date').text,
        }
        job_list << jobs
        puts "Added #{job[:title]}"
        puts "#{job[:location]}"
        puts "#{job[:datePosted]}"
        puts ''
        puts ''
        end
        sleep(1)
        page += 10
        byebug
    end
    
end

scraper