#!/usr/bin/ruby

require 'nokogiri'
require 'pdf-reader'
require 'open-uri'
require 'fileutils'

dir_base = "downloads"

# http://legiscam.cvj.sc.gov.br/fusion/cvj/diarios.jsp
# https://www.joinville.sc.gov.br/jornal

commissions = ["http://legiscam.cvj.sc.gov.br/fusion/cvj/pautaComissao.jsp?id=138021"]#,
#	"http://legiscam.cvj.sc.gov.br/fusion/cvj/pautaComissao.jsp?id=138018",
#	"http://legiscam.cvj.sc.gov.br/fusion/cvj/pautaComissao.jsp?id=138034",
#	"http://legiscam.cvj.sc.gov.br/fusion/cvj/pautaComissao.jsp?id=138037",
#	"http://legiscam.cvj.sc.gov.br/fusion/cvj/pautaComissao.jsp?id=138031",
#	"http://legiscam.cvj.sc.gov.br/fusion/cvj/pautaComissao.jsp?id=2315315",
#	"http://legiscam.cvj.sc.gov.br/fusion/cvj/pautaComissao.jsp?id=138028",
#	"http://legiscam.cvj.sc.gov.br/fusion/cvj/pautaComissao.jsp?id=2315448"]

def txt_cleaning(text)
  scraping = text.to_s
#	scraping.gsub!(/^\s+/, '')
#	scraping.gsub!(/^\*\n/, '')
#	scraping.gsub!(/^CÂMARA DE VEREADORES DE JOINVILLE\nESTADO DE SANTA CATARINA\n/, '')
#	scraping.gsub!(/^Divisão de Apoio às Comissões\n/,'')
#	scraping.gsub!(/^Av\. Hermann August Lepper, 1\.100 - Saguaçu - CEP 89\.221-005 - Joinville\/SC\s+\d+\n/, '')
#	scraping.gsub!(/^E-mail: camara@cvj\.sc\.gov\.br - Home page:www\.cvj\.sc\.gov\.br\n/, '')
#	scraping.gsub!(/^Fone: \(47\) 2101-3333 - Fax: \(47\) 2101-3200$/, '')
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

def id_extracting(text)
	id = /[0-9]*$/.match(text).to_s
	return id
end

def year_extracting(text)
	year = /(ORDINÁRIA|EXTRAORDINÁRIA|DE INSTALAÇÃO) - \d+\/\d+\/\d+/.match(text.to_s)
	year = /[0-9]{4}$/.match(year.to_s).to_s
	return year
end

def commission_extracting(text)
	commission = /(ORDINÁRIA|EXTRAORDINÁRIA|DE INSTALAÇÃO) - \d+\/\d+\/\d+/.match(text.to_s)
	commission = /(ORDINÁRIA|EXTRAORDINÁRIA|DE INSTALAÇÃO)/.match(commission.to_s).to_s
	return commission
end

commissions.each do |commission|
	@doc = Nokogiri::HTML(open(commission))
	node = @doc.xpath("/html/body/div/table/tbody/tr[*]/td[1]/a/@href")
	node.each do |uri|
#		id_extracted = id_extracting(uri)
		filename = "#{id_extracting(uri)}.txt"
#		folder = File.join("downloads", filename)
		unless File.exist?(File.join(dir_base, filename))
			io = open(uri)
			reader = PDF::Reader.new(io)
#			puts "Creating file: #{filename}"
			reader.pages.each do |page|
	#			year_extracted =
				unless (year_extracting(page) == nil)
					year_dir = File.join(dir_base, year_extracting(page))
					FileUtils.mkdir_p year_dir unless File.exists?(year_dir)
				end
				unless (commission_extracting(page) == nil)
					commission_dir = File.join(dir_base, year_extracting(page), commission_extracting(page))
					FileUtils.mkdir_p commission_dir unless File.exists?(commission_dir)
				end
				scraped = txt_cleaning(page)
				dir_and_file = File.join(commission_dir, filename)
				unless File.exist?(dir_and_file)
#					puts dir_and_file
#					puts scraped
					File.open(dir_and_file, "a+") { |f| f << "#{scraped}" }
				end
			end
		 	puts "Finished!\n\n"
		end
	end
end
