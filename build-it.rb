require 'enumerator'
require 'csv'

template_input = ARGV[0]
csv_input = ARGV[1]
output_codename = ARGV[2]

raise "need template_input" unless template_input
raise "need csv_input" unless csv_input
raise "need output_codename" unless output_codename

tmpl = open(template_input).read

content = CSV.read(csv_input, :headers => true).map do |c|
	card = {
		title: c['Title'] || "",
		subtitle: c['Subtitle'] || "",
		description: c['Description'] || ""
	}
	n = (c['Quantity'] || 1).to_i
	Array.new(n, card)
end.flatten

def card_html_modifier(txt)
	# TODO: tie these to feature flags of a sort
	# and make them less context dependent
	html = txt.strip
	html.gsub!(/([+-][0-9]+)/, "<span class='bonus-modifier'>\\1</span>")
	html.gsub!(/\n([2-9]+\. )/, " <br/> \\1")
	html.gsub!(/^(.*: )/, "<b>\\1</b>")
	html.gsub!("\n", "<br/><br/>")
	html
end

def content_strategy_wide(content)
	page_size = 10
	row_size = 5

	card_content = ""
	row_count = 0
	content.each_slice(page_size) do |page_of_content|
		card_content += "<table>\n"
		page_of_content.each_slice(row_size) do |row_of_content|
			card_content += "<tr>\n"
			row_of_content.each do |card|
				card_content += "<td>\n"
				card_content += "<h1>" + card[:title] + "</h1>"
				card_content += "<h2>" + card[:subtitle] + "</h2>"
				card_html = card_html_modifier(card[:description])
				card_content += "<p>" + card_html + "</p>"
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
	card_content
end

def content_strategy_addresses(content)
	page_size = 30
	row_size = 3

	card_content = ""
	content.each_slice(page_size) do |page_of_content|
		card_content += "<table>\n"
		page_of_content.each_slice(row_size) do |row_of_content|
			card_content += "<tr>\n"
			col_count = 0
			row_of_content.each do |card|
				card_content += "<td>\n"				
				card_html = card_html_modifier(card[:description])
				card_content += "<p>" + "<b>" + card[:title] + "</b> " + card_html + "</p>"
				card_content += "</td>\n"
				if col_count < row_size
					card_content += "<td class='separator' />\n"
				end
				col_count += 1
			end
			card_content += "</tr>\n"
		end
		card_content += "<table>\n"
	end
	card_content
end

if template_input =~ /5160/
	card_content = content_strategy_addresses(content)
else
	card_content = content_strategy_wide(content)
end

File.open("#{output_codename}.html", "w"){|f| f << tmpl.sub("$CONTENT", card_content)}
puts `prince #{output_codename}.html`
