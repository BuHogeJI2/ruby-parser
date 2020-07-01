require 'curb'
require 'nokogiri'
require 'csv'

# source_url = 'https://www.petsonic.com/snacks-huesos-para-perros/'
# file_name = 'result.csv'
# item_url = 'https://www.petsonic.com/pienso-para-perros-hill-s-prescription-diet-pd-canine-z-d-ultra.html'

def check_args()
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

	list_of_links = []

	http = Curl.get(url).body_str
	doc = Nokogiri::HTML(http)

	doc.xpath('//a[@class="product-name"]').each do |link|
		list_of_links.push(link.attr('href'))
	end
	
	return list_of_links
end

def get_prod_weight_and_price(doc)

	prod_prices_list = []
	prod_weight_list = []

	doc_info = doc.xpath('//ul[@class = "attribute_radio_list"]//li')
	
	prod_prices_tags = doc_info.xpath('//span[@class = "price_comb"]')
	prod_weight_tags = doc_info.xpath('//span[@class = "radio_label"]')

	prod_prices_tags.each do |price|
		prod_prices_list.push(price.text)
	end

	prod_weight_tags.each do |weight|
		prod_weight_list.push(weight.text)
	end

	result_info = prod_weight_list.zip(prod_prices_list)
	return result_info
end

def get_prod_data(urls_list)

	result_arr = []

	urls_list.each do |url|

		prod_result = []

		http = Curl.get(url).body_str
		prod_doc = Nokogiri::HTML(http)

		prod_info = get_prod_weight_and_price(prod_doc)
		prod_name = prod_doc.xpath('//h1[@class = "product_main_name"]').text
		prod_img = prod_doc.xpath('//img[@id = "bigpic"]').attr('src')

		prod_info.each do |info|
			prod_result.push(prod_name + " - " + info[0], info[1], prod_img)	
		end

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

	end
end

start()
