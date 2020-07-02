require 'curb'
require 'nokogiri'
require 'csv'

# Run to check the script:
# ruby script.rb https://www.petsonic.com/snacks-huesos-para-perros/ result.csv

# Git repo: https://github.com/BuHogeJI2/ruby-parser

def check_args()

	puts 'Checking args...'

	if ARGV.length() <= 1
		puts 'Too small args'
		return 0
	elsif ARGV.length() > 2
		puts 'Too much args'
		return 0
	else
		return 1
	end
end

def get_prod_links(url)

	puts 'Reading category...'

	list_of_links = []
	i = 0

	while true

		if i == 0
			http = Curl.get(url).body_str
			i+=1
		else
			http = Curl.get(url + "?p=#{i+=1}").body_str
		end

		doc = Nokogiri::HTML(http)

		load_btn = doc.xpath('//button[@class = "loadMore next button lnk_view btn btn-default"]')
		load_btn.empty? ? break : doc.xpath('//a[@class="product-name"]').map { |link| list_of_links.push(link.attr('href')) }

	end

	return list_of_links
end

def get_prod_weight_and_price(doc)

	doc_info = doc.xpath('//ul[@class = "attribute_radio_list"]//li')
	
	prod_prices_tags = doc_info.xpath('//span[@class = "price_comb"]')
	prod_weight_tags = doc_info.xpath('//span[@class = "radio_label"]')

	prod_prices_list = prod_prices_tags.map { |price| price.text }
	prod_weight_list = prod_weight_tags.map { |weight| weight.text }

	result_info = prod_weight_list.zip(prod_prices_list)
	return result_info
end

def get_prod_data(urls_list)

	puts 'Collecting data...'

	result_arr = []

	urls_list.each do |url|

		prod_result = []

		http = Curl.get(url).body_str
		prod_doc = Nokogiri::HTML(http)

		prod_info = get_prod_weight_and_price(prod_doc)
		prod_name = prod_doc.xpath('//h1[@class = "product_main_name"]').text
		prod_img = prod_doc.xpath('//img[@id = "bigpic"]').attr('src')

		prod_info.map { |info| prod_result.push(prod_name + " - " + info[0], info[1], prod_img) }

		result_arr.push(prod_result)

	end

	return result_arr
end

def start()

	if check_args == 1

		url = ARGV[0]
		file_name = ARGV[1]

		data_list = get_prod_data(get_prod_links(url))

		CSV.open(file_name, 'wb') do |csv|
			for data in data_list
				csv << data
			end
		end

		puts 'Done! Check the file!'
	end
end


start()
