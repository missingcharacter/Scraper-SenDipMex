# encoding: utf-8
 
require 'open-uri'
require 'awesome_print'
require 'nokogiri'
require 'json'
 
 
class SenScraper
  
  Fields = ["Nombre", "Entidad", "Partido", "Foto"]
  BaseURL = "http://www.senado.gob.mx/index.php?ver=int&mn=4&sm=10&id=SENADOR"
  
  def initialize
      
    len = 128
    senadores = (1..len).map do |i|
      url = BaseURL.sub("SENADOR", i.to_s)
      doc = Nokogiri::HTML open(url)
      tds = doc.css 'td'
      data = {}
      tds.each do |td|
        if td.content.strip.match /.*?(Por|Lista)/
         data["Entidad"] = td.content.split("  ").join(" ").sub("Por el estado de", "").strip
        end
        if td.content.strip.match /^Sen\./
         data["Nombre"] = td.content.strip
        end
        
        imgs = doc.css "img"
          imgs.each do |img|
            src = img["src"]
            if src.match /senadores/
              data["Foto"] = src
            end
            if src.match /cuerpo/ and src.index("lcom") == nil
              data["Partido"] = src.match(/img\/cuerpo\/(.+?)\./)[1]
            end
          end
        end
        
        coms = doc.css "td td td td"
          data["Comisiones"] = []
          coms.each do |td|
            if td.content.match /.*?(\(Presidente\)|\(Secretario\)|\(Integrante\))/
              data["Comisiones"] << td.content.gsub(" ", "")
              
            end
          end 
        
        data
      end
    puts senadores.to_json  
    end
    
  end
SenScraper.new
