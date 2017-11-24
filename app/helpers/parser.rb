require 'nokogiri'
require 'open-uri'
require 'rest-client'

module Parser
    class Movie
        def naver
            # 네이버 현재상영영화중 하나를 랜덤으로 뽑아주는 코드
        
            doc = Nokogiri::HTML(open("http://movie.naver.com/movie/running/current.nhn"))
            movie_title = Array.new
            
            doc.css("ul.lst_detail_t1 dt a").each do |title|
            	movie_title << title.text
            end
            
            title = movie_title.sample
            return "<" + title + ">"
        end
    end
    
    class Animal
        def cat
            cat_xml = RestClient.get 'http://thecatapi.com/api/images/get?format=xml&type=jpg'
            doc = Nokogiri::XML(cat_xml)
            cat_url = doc.xpath("//url").text
            
            return cat_url
        end
    end
    
    class Akmu
        
        def get_news (word)

            keyword=URI::escape(word)
            url = "https://search.naver.com/search.naver?ie=utf8&where=news&query=#{keyword}&sm=tab_tmr&frm=mr&nso=so:r,p:all,a:all&sort=0"
            result=RestClient.get(url)
            parsed_result=Nokogiri::HTML(result.body)
            result = parsed_result.css("._sp_each_title")
            array=[]
            3.times do |i|
                array << result[i]["title"]
                array << result[i]["href"]
            	#array << "#{a["title"]} - (#{a["href"]})"
            	#break
            end
            array.to_s
        end
    end
    
end 