#!/usr/bin/ruby

require 'nokogiri'
require 'pdf-reader'
require 'open-uri'
require 'fileutils'

dir_base = "downloads"
FileUtils.mkdir_p dir_base unless File.exists?(dir_base)

# http://legiscam.cvj.sc.gov.br/fusion/cvj/diarios.jsp
# https://www.joinville.sc.gov.br/jornal

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

commissions.each do |commission|
	doc = Nokogiri::HTML(open(commission))
	comm = doc.xpath("/html/body/div/h2/text()")
	dir_comm = File.join(dir_base, comm)
	FileUtils.mkdir_p dir_comm unless File.exists?(dir_comm)
	json = doc.xpath("/html/body/div/table/tbody/tr[1]")
	metting = json.xpath("/td[2]/text()")
	puts metting
	href = json.xpath("/td[1]/a/@href")
	text = ""
	href.each do |uri|
		id = /\d+$/.match(uri).to_s
#		Dir.glob("#{dir_base}/*") do |file|
#			puts /\d+$/.match(file).to_s
#			unless (/\d+$/.match(file).to_s == id)
				puts "Creating file: #{id}"
				io = open(uri)
				reader = PDF::Reader.new(io)
				reader.pages.each do |page|
					text << txt_cleaning(page)
					text.each_line do |line|
						@name = get_date_commision(line) unless (get_date_commision(line) == nil)
					end
					filename = "#{@name}_#{id}"
					folder_filename = File.join(dir_base, filename)
					unless File.exists?(folder_filename)
						File.open(folder_filename, "w+") { |f| f << text }
					end
				end
				puts "Finished!\n\n"
	#		end
	#	end
	end
end
puts "The End!"
