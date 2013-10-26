require 'enumerator'

sample_content = {
	title: "Card Title", 
	subtitle: "Card Subtitle", 
	description: "description..."
}

content = Array.new(17, sample_content)

PAGE_SIZE = 10
ROW_SIZE = 5

output = []
content.each_slice(PAGE_SIZE) do |page_of_content|
	this_page = []
	page_of_content.each_slice(ROW_SIZE) do |row_of_content|
		this_page << row_of_content.map{"1"}
	end
	output << this_page
end

card_content = ""
row_count = 0
content.each_slice(PAGE_SIZE) do |page_of_content|
	card_content += "<table>\n"
	page_of_content.each_slice(ROW_SIZE) do |row_of_content|
		card_content += "<tr>\n"
		row_of_content.each do |card|
			card_content += "<td>\n"
			card_content += "<h1>" + card[:title] + "</h1>"
			card_content += "<h2>" + card[:subtitle] + "</h2>"
			card_content += "<p>" + card[:description] + "</p>"
			card_content += "</td>\n"
		end
		card_content += "</tr>\n"
		if row_count.even?
			card_content += "<tr class='separator' />\n"
		end
		row_count += 1
	end
	card_content += "<table>\n"
end

tmpl = open("template-base.html").read

puts tmpl.sub("$CONTENT", card_content)
