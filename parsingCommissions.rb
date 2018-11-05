#!/usr/bin/ruby

require 'nokogiri'
require 'pdf-reader'
require 'open-uri'
require 'fileutils'

count = 0
commissions = ["http://legiscam.cvj.sc.gov.br/fusion/cvj/pautaComissao.jsp?id=138021",
	"http://legiscam.cvj.sc.gov.br/fusion/cvj/pautaComissao.jsp?id=138018",
	"http://legiscam.cvj.sc.gov.br/fusion/cvj/pautaComissao.jsp?id=138034",
	"http://legiscam.cvj.sc.gov.br/fusion/cvj/pautaComissao.jsp?id=138037",
	"http://legiscam.cvj.sc.gov.br/fusion/cvj/pautaComissao.jsp?id=138031",
	"http://legiscam.cvj.sc.gov.br/fusion/cvj/pautaComissao.jsp?id=2315315",
	"http://legiscam.cvj.sc.gov.br/fusion/cvj/pautaComissao.jsp?id=138028",
	"http://legiscam.cvj.sc.gov.br/fusion/cvj/pautaComissao.jsp?id=2315448"]

def txt_cleaning(text)
  scraping = text.to_s
	scraping.gsub!(/^\s+/, '')
	scraping.gsub!(/^\*\n/, '')
	scraping.gsub!(/\n $/, '')
	scraping.gsub!(/^CÂMARA DE VEREADORES DE JOINVILLE\nESTADO DE SANTA CATARINA\n/, '')
	scraping.gsub!(/^Divisão de Apoio às Comissões\n/, '')
	scraping.gsub!(/^Coordenadoria de Políticas Públicas\n/, '')
	scraping.gsub!(/^Coordenadoria de Finanças\n/, '')
	scraping.gsub!(/^Av\. Hermann August Lepper, 1\.100 - Saguaçu - CEP 89\.221-005 - Joinville\/SC\s+\d+\n/, '')
	scraping.gsub!(/^E-mail: camara@cvj\.sc\.gov\.br - Home page:www\.cvj\.sc\.gov\.br\n/, '')
	scraping.gsub!(/^Fone: \(47\) 2101-3333 - Fax: \(47\) 2101-3200$/, '')
	return scraping
end

commissions.each do |commission|
	doc = Nokogiri::HTML(open(commission))
 	comm = doc.xpath("/html/body/div/h2/text()").to_s.force_encoding('iso-8859-1').encode('utf-8')
	FileUtils.mkdir_p comm unless File.exists?(comm)
	parsed = doc.xpath("/html/body/div/table/tbody/tr[*]")
	parsed.each do |node|
		meeting = node.xpath("td[2]/text()").to_s.rjust(2,'0')
		date = node.xpath("td[3]/text()").to_s.gsub!(/(\d{2})(\/)(\d{2})(\/)(\d{4})/, '\5\3\1')
		ord = "Reunião Ordinária"
		extra = "Reunião Extraordinária"
		inst = "Reunião de Instalação"
		get_type = node.xpath("td[5]/text()").to_s
		if ( get_type==ord || get_type==extra || get_type==inst )
			type = get_type
		else
			type = get_type.force_encoding('iso-8859-1').encode('utf-8')
		end
		subfolder = File.join(comm, type)
		FileUtils.mkdir_p subfolder unless File.exists?(subfolder)
		link = node.xpath("td[1]/a/@href")
		text = ""
		link.each do |uri|
			count += 1
			id = /\d+$/.match(uri).to_s
			filename = "#{date}#{meeting}-#{id}.txt"
			folder_filename = File.join(subfolder, filename)
			unless File.file?(folder_filename)
				puts "#{count} Creating file..."
				io = open(uri)
				reader = PDF::Reader.new(io)
				reader.pages.each do |page|
					text << txt_cleaning(page)
					File.open(folder_filename, "w+") { |f| f << text }
				end
			else
				puts "#{count} File already exist!"
			end
		end
	end
end
