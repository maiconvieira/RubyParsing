#!/usr/bin/ruby

count = 0
regex1 = /(^I\. LEITURA E VOTAÇÃO DA ATA DA REUNIÃO ANTERIOR;\n((.|\n)*)II\. LEITURA DO EXPEDIENTE:\n)/
regex2 = /(^II\. LEITURA DO EXPEDIENTE:\n((.|\n)*)III\. DISTRIBUIÇÃO DAS PROPOSIÇÕES AOS RELATORES:\n)/
regex3 = /(^III\. DISTRIBUIÇÃO DAS PROPOSIÇÕES AOS RELATORES:\n((.|\n)*)IV\. LEITURA, DISCUSSÃO E VOTAÇÃO DAS PROPOSIÇÕES:\n)/
regex4 = /(^IV\. LEITURA, DISCUSSÃO E VOTAÇÃO DAS PROPOSIÇÕES:\n((.|\n)*)V\. OUTROS ASSUNTOS:\n)/
regex5 = /(^V\. OUTROS ASSUNTOS:\n((.|\n)*)(\n(.*)\nPresidente da Comissão))/
regex6 = /(^(\d{1,2}\.)(.*)( - | nº )(.*)$)/
regex7 = /(^\d{1,2}\.((.|\n)*)Autoria:)/
regex8 = /(^Autoria:(\s){0,1}((.|\n)*)Assunto:)/
regex9 = /(^Assunto:(\s){0,1}((.|\n)*)Relator Designado:)/
regex10 = /(^Relator (De|Rede)signado:(\s){0,1}((.|_)*)$)/

Dir.glob('Comissão de */*/201*.txt') do |file|
  count += 1
  content = File.read(file)
  puts "#{count} - #{file}"
  scraping1 = regex1.match(content).to_s.gsub(regex1, '\2')
  puts "Renunião anterior:\n#{scraping1}" unless scraping1==""

  scraping2 = regex2.match(content).to_s.gsub(regex2, '\2').gsub(/\n/, ' ').gsub(/(^\s+|\s$)/, '')
  puts "Leitura do expediente:\n#{scraping2}" unless scraping2==""

  scraping3 = regex3.match(content).to_s.gsub(regex3, '\2')
  unless scraping3==""
    puts "Distribuição das Proposições:"
    var_gsub = scraping3.to_s.gsub!(regex6, '{--gsub--}\1')
    array = var_gsub.split("{--gsub--}")
    array.each do |e|
      unless e==""
      projeto = regex7.match(e).to_s.gsub(regex7, '\2').gsub(/\n/, ' ').gsub(/( nº | - )/, ' ').gsub(/\s$/, '')
      autoria = regex8.match(e).to_s.gsub(regex8, '\3').gsub(/\n/, ' ').gsub(/\s$/, '')
      assunto = regex9.match(e).to_s.gsub(regex9, '\3').gsub(/\n/, ' ').gsub(/\s$/, '')
      relator = regex10.match(e).to_s.gsub(regex10, '\4').gsub(/\n/, ' ').gsub(/(_)+/, '').gsub(/\s$/, '')
      puts "#{projeto}\nAutoria: #{autoria}\nAssunto: #{assunto}\nRelator: #{relator}"
      end
    end
  end

  scraping4 = regex4.match(content).to_s.gsub(regex4, '\2')
  puts "Leitura, discussão e votação das proposições:\n#{scraping4}\n\n" unless scraping4==""

  scraping5 = regex5.match(content).to_s
  others = scraping5.gsub(regex5, '\2')
  presidente = scraping5.gsub(regex5, '\5')
  puts "#{others}" unless others==""
  puts "Presidente: #{presidente}\n\n" unless presidente==""
end
