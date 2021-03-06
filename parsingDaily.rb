#!/usr/bin/ruby

require 'nokogiri'
require 'pdf-reader'
require 'open-uri'
require 'fileutils'

daily = "http://legiscam.cvj.sc.gov.br/fusion/cvj/diarios.jsp"

def txt_cleaning(text)
  scraping = text.to_s
  scraping.gsub!(/^\s+/, '')
  scraping.gsub!(/^CÂMARA DE VEREADORES DE JOINVILLE\nESTADO DE SANTA CATARINA\nDIÁRIO DA CÂMARA DE VEREADORES DE JOINVILLE\n/, '')
  scraping.gsub!(/CÂMARA DE VEREADORES DE JOINVILLE\nESTADO DE SANTA CATARINA\nDiário da Câmara/, '')
  scraping.gsub!(/CÂMARA DE VEREADORES DE JOINVILLE\nESTADO DE SANTA CATARINA/, '')
  scraping.gsub!(/^Sessão Ordinária do dia \d+ de \w+ de \d+\.\n/, '')
#	scraping.gsub!(/^\*\n/, '')#	scraping.gsub!(/^Av\. Hermann August Lepper, 1\.100 - Saguaçu - CEP 89\.221-005 - Joinville\/SC\s+\d+\n/, '')
#	scraping.gsub!(/^E-mail: camara@cvj\.sc\.gov\.br - Home page:www\.cvj\.sc\.gov\.br\n/, '')
#	scraping.gsub!(/^Fone: \(47\) 2101-3333 - Fax: \(47\) 2101-3200$/, '')
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
folder = "Sessões"
FileUtils.mkdir_p folder unless File.exists?(folder)
parsed = doc.xpath("/html/body/div/table/tbody/tr[*]")
parsed.each do |node|
  ord = "Ordinária"
  get_type = node.xpath("td[5]/text()").to_s
  if ( get_type==ord )
    type = get_type
  else
    type = get_type.force_encoding('iso-8859-1').encode('utf-8')
  end
  if type==ord
    date = node.xpath("td[3]/text()").to_s.gsub!(/(\d{2})(\/)(\d{2})(\/)(\d{4})/, '\5\3\1')
    meeting = node.xpath("td[6]/text()").to_s.rjust(3,'0')
    link = node.xpath("td[1]/a/@href")
    text = ""
		link.each do |uri|
			id = /\d+$/.match(uri).to_s
      filename = "#{date}#{meeting}-#{id}.txt"
      folder_filename = File.join(folder, filename)
			unless File.file?(folder_filename)
				puts "Creating file: #{filename}"
				io = open(uri)
				reader = PDF::Reader.new(io)
				reader.pages.each do |page|
					text << txt_cleaning(page)
					File.open(folder_filename, "w+") { |f| f << text }
				end
				puts "Finished!\n\n"
			else
				puts "File: #{filename} already exist!\n\n"
			end
    end
  end
end
puts "The End!"
