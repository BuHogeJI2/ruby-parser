require 'curb'
require 'nokogiri'


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

source_url = 'https://www.petsonic.com/snacks-huesos-para-perros/'
url_first_snack = 'https://www.petsonic.com/snacks-de-pollo-en-monodosis-para-perro.html'

def get_prods_links(url)

	list_of_links = []

	http = Curl.get(url).body_str
	doc = Nokogiri::HTML(http)

	doc.xpath('//a[@class="product-name"]').each do |link|
		list_of_links.push(link.attr('href'))
	end
	
	return list_of_links
end

def get_prod_data(urls_list)

	prod_names = []
	prod_prices = []

	urls_list.each do |url|

		http = Curl.get(url).body_str
		doc = Nokogiri::HTML(http)

		prod_name = doc.xpath('//h1[@class = "product_main_name"]').text
		prod_names.push(prod_name)

		prod_price = doc.xpath('//span[@id = "our_price_display"]').text
		prod_prices.push(prod_price)

	end


end

get_prod_data(get_prods_links(source_url))

# http = Curl.get(url_first_snack).body_str

# doc = Nokogiri::HTML(http)

# doc.xpath('//a[@class="product-name"]').each do |link|
# 	puts link.content
# end

# prod_html = doc.xpath('//div[@class = "row"]')

# prod_name = prod_html.at_xpath('//div//h1').text
# prod_price = prod_html.at_xpath('//span[@id = "our_price_display"]').text
# prod_img = prod_html.at_xpath('//img[@id = "bigpic"]').text

# puts prod_name, prod_price, prod_img




# //h2[@class = "prod-name-pack"]/*
# /html/body/div[1]/div/div[2]/div/div/div[2]/div[7]/ul/li[1]/div[1]/div[2]/div[2]/div[1]/h2