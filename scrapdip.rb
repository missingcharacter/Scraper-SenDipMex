# encoding: utf-8
 
require 'open-uri'
require 'awesome_print'
require 'nokogiri'
require 'json'
 
 
class CongreScraper
 
  Fields = ["Tipo de elección", "Entidad", "Distrito"]
  BaseURL = "http://sitl.diputados.gob.mx/LXI_leg/curricula.php?dipt=DIPUTADO"
 
  def initialize
    
    len = 500
    diputados = (1..len).map do |i|
      url = BaseURL.sub("DIPUTADO", i.to_s)
      doc = Nokogiri::HTML open(url)
      tds = doc.css 'td'
      data = {}
      tds.each do |td|
        Fields.each do |field|
          if td.content.match "#{field}:"
            data[field] = td.parent.css("td")[1].content.strip
          end
        end
        if td.content.strip.match /^Dip\./
          data["Nombre"] = td.content.strip
        end

      end
      
      imgs = doc.css "img"
      imgs.each do |img|
        src = img["src"]
        if src.match /foto/
          data["Foto"] = src
          other_images = img.parent.parent.css("img")
          if other_images and other_images.size >= 2
            party = other_images[1]
            src = party["src"]
            data["PartidoImg"] = src
            party_matches = src.match(/images\/.*?(panal|pan|prd|pri|pt|vrd|movimiento_ciudadano)/)
            data["Partido"] = if party_matches.nil? then nil else party_matches[1] end
          else
            data["PartidoImg"] = nil
            data["Partido"] = nil
          end
        end
      end
      
      coms = doc.css "a"
      data["Comisiones"] = []
      coms.each do |a|
        if a["href"].index("integrantes_de_comision") == 0
          data["Comisiones"] << a.content.strip
          
        end
      end 
      data
    end
    
    puts diputados.to_json
 
  end
 
  def collect_between(first, last)
    result = [first]
    until first == last
      first = first.next
      result << first
    end
    result
  end
 
end
 
 
 
CongreScraper.new
