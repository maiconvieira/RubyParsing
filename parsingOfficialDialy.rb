#!/usr/bin/ruby

require 'nokogiri'
require 'pdf-reader'
require 'open-uri'
require 'fileutils'

daily = "https://www.joinville.sc.gov.br/jornal"

def txt_cleaning(text)
  scraping = text.to_s
	scraping.gsub!(/^\s+/, '')
	scraping.gsub!(/^\*\n/, '')
	scraping.gsub!(/^CÂMARA DE VEREADORES DE JOINVILLE\nESTADO DE SANTA CATARINA\n/, '')
	scraping.gsub!(/^Av\. Hermann August Lepper, 1\.100 - Saguaçu - CEP 89\.221-005 - Joinville\/SC\s+\d+\n/, '')
	scraping.gsub!(/^E-mail: camara@cvj\.sc\.gov\.br - Home page:www\.cvj\.sc\.gov\.br\n/, '')
	scraping.gsub!(/^Fone: \(47\) 2101-3333 - Fax: \(47\) 2101-3200$/, '')
#	scraping.gsub!(/^Divisão de Apoio às Comissões\n/,'')
#	scraping.gsub!(/^COMISSÃO DE LEGISLAÇÃO, JUSTIÇA E REDAÇÃO\n/, '')
#	scraping.gsub!(/^Coordenadoria Jurídica Legislativa\n/, '')
#	scraping.gsub!(/^COMISSÃO DE URBANISMO, OBRAS, SERVIÇOS PÚBLICOS E MEIO AMBIENTE\n/, '')
#	scraping.gsub!(/^Coordenadoria de Urbanismo, Obras, Serviços\n/, '')
#	scraping.gsub!(/^COMISSÃO DE FINANÇAS, ORÇAMENTO E CONTAS DO MUNÍCIPIO\n/, '')
#	scraping.gsub!(/^Coordenadoria de Finanças\n/, '')
#	scraping.gsub!(/^COMISSÃO DE SAÚDE, ASSISTÊNCIA E PREVIDÊNCIA SOCIAL\n/, '')
#	scraping.gsub!(/^Coordenadoria de Políticas Públicas\n/, '')
#	scraping.gsub!(/^Comissão de Saúde, Assistência e Previdência Social\n/, '')
#	scraping.gsub!(/^COMISSÃO DE EDUCAÇÃO, CULTURA, DESPORTO, CIÊNCIAS E TECNOLOGIA\n/, '')
#	scraping.gsub!(/^Comissão de Educação, Cultura, Desporto, Ciências e Tecnologia\n/, '')
#	scraping.gsub!(/^COMISSÃO DE CIDADANIA E DIREITOS HUMANOS\n/, '')
#	scraping.gsub!(/^COMISSÃO DE PARTICIPAÇÃO POPULAR E CIDADANIA\n/, '')
#	scraping.gsub!(/^Comissão de Participação Popular e Cidadania\n/, '')
#	scraping.gsub!(/^COMISSÃO DE ECONOMIA, AGRICULTURA, INDÚSTRIA, COMÉRCIO E TURISMO\n/, '')
#	scraping.gsub!(/^Comissão de Economia, Agricultura, Indústria, Comércio e Turismo\n/, '')
#	scraping.gsub!(/^COMISSÃO DE PROTEÇÃO CIVIL E SEGURANÇA PÚBLICA\n/, '')
#	scraping.gsub!(/^COMISSÃO DE PROTEÇÃO CIVIL E ANTIDROGAS\n/, '')
#	scraping.gsub!(/^Comissão de Proteção Civil e Antidrogas\n/, '')
	return scraping
end

def get_date_commision(text)
	var = /(ORDINÁRIA|EXTRAORDINÁRIA|INSTALAÇÃO) - (\d{2})\/(\d{2})\/(\d{4})/.match(text).to_s
	name = var.gsub!(/(ORDINÁRIA|EXTRAORDINÁRIA|INSTALAÇÃO)( - )(\d{2})(\/)(\d{2})(\/)(\d{4})/, '\7\5\3_\1')
	return name
end

doc = Nokogiri::HTML(open(daily))
	comm = doc.xpath("/html/body/div/h2/text()").to_s.force_encoding('iso-8859-1').encode('utf-8')
FileUtils.mkdir_p comm unless File.exists?(comm)
parsed = doc.xpath("/html/body/div/table/tbody/tr[1]")
parsed.each do |node|
	puts meeting = node.xpath("td[2]/text()").to_s.rjust(2,'0')
	date = node.xpath("td[3]/text()").to_s.gsub!(/(\d{2})(\/)(\d{2})(\/)(\d{4})/, '\5\3\1')
#		time = node.xpath("td[4]/text()").to_s.gsub!(/(\d{2})(:)(\d{2})/, '\1\3')
	type = node.xpath("td[5]/text()").to_s.force_encoding('iso-8859-1').encode('utf-8')
	subfolder = File.join(comm, type)
	FileUtils.mkdir_p subfolder unless File.exists?(subfolder)
#		local = node.xpath("td[6]/text()").to_s.force_encoding('iso-8859-1').encode('utf-8')
	href = node.xpath("td[1]/a/@href")
	text = ""
	href.each do |uri|
		id = /\d+$/.match(uri).to_s
		filename = "#{date}#{meeting}-#{id}.txt"
		puts "Creating file: #{filename}"
		io = open(uri)
		reader = PDF::Reader.new(io)
		reader.pages.each do |page|
			text << txt_cleaning(page)
			folder_filename = File.join(subfolder, filename)
			unless File.exists?(folder_filename)
				File.open(folder_filename, "w+") { |f| f << text }
			end
		end
		puts "Finished!\n\n"
	end
end
puts "The End!"
