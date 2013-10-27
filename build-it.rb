require 'enumerator'
require 'csv'

csv_input = ARGV[0]
output_codename = ARGV[1]

raise "need csv_input" unless csv_input
raise "need output_codename" unless output_codename

content = CSV.read(csv_input, :headers => true).map do |c|
	{title: c['Title'],
	 subtitle: c['Subtitle'],
	 description: c['Description']
	}
end

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

File.open("#{output_codename}.html", "w"){|f| f << tmpl.sub("$CONTENT", card_content)}
puts `prince #{output_codename}.html`
