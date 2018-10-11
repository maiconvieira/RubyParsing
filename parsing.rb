require 'nokogiri'
require 'pdf-reader'
require 'open-uri'
require 'uri'


@doc = Nokogiri::HTML(open("http://legiscam.cvj.sc.gov.br/fusion/cvj/pautaComissao.jsp?id=138021"))
re = /[0-9]*$/
node = @doc.xpath("/html/body/div/table/tbody/tr[*]/td[1]/a/@href")
node.each do |url|
	url.to_s.scan(re) do |match|
		teste = match.to_s
		puts url + ": " + teste
	end
end

#re = /[0-9]*$/m
#str = 'http://legiscam.cvj.sc.gov.br:80/fusion/file/download/1511327'

# Print the match result
#str.scan(re) do |match|
#    puts match.to_s
#end

#	puts url.URI.s
#	p uri
#	p uri.scheme
#	p uri.host

#	puts uri
#	io = open(uri)
#	reader = PDF::Reader.new(io)
#		reader.pages.each do |page|
#		puts page.fonts
#		puts page.text
#		puts page.raw_content
#	end
# end

#def add_keywords_to_profile(user)
#  io = open(user.resume_pdf.to_s)
#  reader = PDF::Reader.new(io)
#  reader.pages.each do |page|
#    string = page.text
#    KeywordHelper.keywords.each do |word|
#      if string.downcase.include?(word.downcase)
#        user.keywords.push(word)
#        user.save
#      end
#    end
#  end
#end
