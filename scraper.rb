require 'nokogiri'
require 'byebug'
require 'httparty'

def scraper
    url = 'https://www.indeed.com/jobs?q=software+engineer&l=Brooklyn%2C+NY' # change location or job title here for indeed.com
    unparsed_page = HTTParty.get(url)
    parsed_page = Nokogiri::HTML(unparsed_page)
    job_list = Array.new
    
    jobs = parsed_page.css('div.jobsearch-SerpJobCard') # job listings per page
    total = parsed_page.css('div#searchCountPages').text.split(' ')[3].gsub(',','').to_i # total number of pages
    per_page = jobs.count # how many jobs per each page
    page = 10 # for indeed.com their search pages increment by 10 (10, 20, 30...etc)
    last_page = ( total.to_f / per_page.to_f ).round # last page to scrape through

    while page <= last_page # loops through each page of jobs and turns the page
        pagination_url = "https://www.indeed.com/jobs?q=software+engineer&l=Brooklyn%2C+NY&start=#{page}"
        puts "pagination_url"
        puts "Page: #{page}"
        puts ''
        pagination_unparsed_page = HTTParty.get(pagination_url)
        pagination_parsed_page = Nokogiri::HTML(pagination_unparsed_page)
        pagination_jobs = pagination_parsed_page.css('div.jobsearch-SerpJobCard')
        pagination_jobs.each do |job| # save each job's info to a hash
        job = {
            title: job.css('h2.title').text,
            company: job.css('span.company').text,
            location: job.css('div.location').text,
            description: job.css('div.summary').text,
            datePosted: job.css('span.date').text,
        }
        job_list << jobs
        puts "Title: #{job[:title]}"
        puts "Company: #{job[:company]}"
        puts "Location: #{job[:location]}"
        puts "Date Posted: #{job[:datePosted]}"
        puts ''
        puts ''
        end
        sleep(1) # trying to delay hitting the page too fast
        page += 10 # page's on indeed.com increment by 10
        byebug
    end
    
end

scraper