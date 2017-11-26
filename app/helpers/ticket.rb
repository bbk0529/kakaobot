require 'rest-client'
require 'json'
require 'nokogiri'
require 'time'
require 'active_support'
require 'active_support/core_ext'
require 'csv'


module Ticket
    class Skyscanner
        
    @@departure=''
    @@arrival=''
    
    
    def setArrival(arr)
       @@arrival = arr 
    end
    
    def getArrival()
       @@arrival 
    end
    
    def setDeparture(departure)
        @@departure=departure
    end
    
    def getDeparture()
        @@departure
    end
 
    def getStatus
        @@departure + "출발 " + @@arrival + "도착"
    
    end
  
    def search(dk,k,search_start, search_end, period_start, period_finish, limit, result)
    	array1=[]
    	array2=[]
    	min1=[]
    	min2=[]
        (period_start..period_finish).to_a.each do |period|
            (search_start..search_end).to_a.each do |j|
                break if (j+period) >= search_end
                outbound = result['PriceGrids']['Grid'][0][j-1]['DirectOutboundPrice']
                inbound = result['PriceGrids']['Grid'][j-1+period][j-1]['DirectInboundPrice']
    
                outbound2 = result['PriceGrids']['Grid'][0][j-1]['IndirectOutboundPrice']
                inbound2 = result['PriceGrids']['Grid'][j-1+period][j-1]['IndirectInboundPrice']
    
                p "            " +"direct" + j.to_s + "일 부터 " + (j+period).to_s + "일 까지 " + period.to_s + "일 동안 " + (outbound + inbound).to_s + "원입니다" if  outbound && inbound && ((inbound + outbound) < limit)
                p "            " +"Indirect" + j.to_s + "일 부터 " + (j+period).to_s + "일 까지 " + period.to_s + "일 동안 " + (outbound2 + inbound2).to_s + "원입니다" if  outbound2 && inbound2 && ((inbound2 + outbound2) < limit)
    			
    			CSV.open("file.csv", "a+") do |csv|
    				if  outbound && inbound && ((inbound + outbound) < limit)
    					csv << [dk,k, "direct", j, j+period, period, (outbound + inbound)] 
    					array1.push([dk,k,"direct",j,j+period, period, (outbound+inbound)])
    					min1.push(outbound+inbound)
    				end
    
    				if  outbound2 && inbound2 && ((inbound2 + outbound2) < limit)
    	  				csv << [dk,k, "indirect", j, j+period, period, (outbound2+outbound2)] 
    					array2.push([dk,k,"indirect",j,j+period, period, (outbound2+inbound2)])
    					min2.push(outbound2+inbound2)
    				end
    			
    			end #end of CSV.open
    
            end #end of sear_start
        end #end of period start
        array1[min1.index(min1.min)] if min1.size!=0
        array2[min2.index(min2.min)] if min2.size!=0
    end
    
    
    
   
    
    

    def start()
         
   
    s_date='2017-12-16'
    e_date='2017-12-31'
    period_start=8
    period_finish=15 	
    limit=1000000
    
    destination={}
    departure={}
    destination.merge!({"시드니": "SYD"})
    
    departure["INCHEON"] ="ICN"
    departure["GIMPO"]="GMP"
    departure["BUSAN"] ="PUS"
    departure["BANGKOK"] ="BKK"
    
    ps_date = Date.parse(s_date)
    pe_date = Date.parse(e_date)
    month_duration =  (pe_date.year - ps_date.year) * 12 + (pe_date.month - ps_date.month) + 1
    
    month_duration.times do |i|
        start_month = ps_date.to_s[0,7]
    
        departure.each do |dk,dv|
    	    p '='*30
    	    	p "Departure from" + dk.to_s 
    	    destination.each do |k,v|
    			 
    	        url = "https://www.skyscanner.co.kr/dataservices/browse/v3/mvweb/KR/KRW/ko-KR/calendar/#{dv}/#{v}/#{start_month}/#{start_month}/?profile=minimalmonthviewgrid&abvariant=GDT1606_ShelfShuffleOrSort:b|GDT1606_ShelfShuffleOrSort_V5:b|RTS2189_BrowseTrafficShift:b|RTS2189_BrowseTrafficShift_V8:b|rts_mbmd_anylegs:b|rts_mbmd_anylegs_V5:b|GDT1693_MonthViewSpringClean:b|GDT1693_MonthViewSpringClean_V13:b|GDT2195_RolloutMicroserviceIntegration:b|GDT2195_RolloutMicroserviceIntegration_V4:b"
    	        result=JSON.parse(RestClient.get(url, headers))
    	        search_start=17
    	        search_end=ps_date.end_of_month.day
    	        p "            " + k.to_s + ' ' + v.to_s + ' ' +start_month
    	        search(dk,k,search_start, search_end, period_start, period_finish, limit, result)
    	    end # destination
    	end #departure 
        ps_date = (((ps_date +1) >> 1 ) - 1)
    end #month

    end #start
    
    
    def read_csv
        array=[]
        CSV.foreach("file.csv") do |row|
            array << row
        end
        array
    end
    
    
    def seoul_search()
        
        headers = {
            "user-agent":"Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Safari/537.36"
        }
 
        
        
        @@departure="서울"
        array1=[]
    	min1=[]
        url = "https://www.skyscanner.co.kr/dataservices/browse/v3/mvweb/KR/KRW/ko-KR/calendar/ICN/BKK/2017-12/2017-12/?profile=minimalmonthviewgrid&abvariant=GDT1606_ShelfShuffleOrSort:b|GDT1606_ShelfShuffleOrSort_V5:b|RTS2189_BrowseTrafficShift:b|RTS2189_BrowseTrafficShift_V8:b|rts_mbmd_anylegs:b|rts_mbmd_anylegs_V5:b|GDT1693_MonthViewSpringClean:b|GDT1693_MonthViewSpringClean_V13:b|GDT2195_RolloutMicroserviceIntegration:b|GDT2195_RolloutMicroserviceIntegration_V4:b"
    	result=JSON.parse(RestClient.get(url, headers))
    	search_start=1
    	search_end=30
    	period = 14
    	limit=1000000
    	array=[]
        (search_start..search_end).to_a.each do |j|
            break if (j+period) >= search_end
            outbound = result['PriceGrids']['Grid'][0][j-1]['DirectOutboundPrice']
            inbound = result['PriceGrids']['Grid'][j-1+period][j-1]['DirectInboundPrice']
    		if  outbound && inbound && ((inbound + outbound) < limit)
    		    array1.push(["서울","방콕","direct",j,j+period, period, (outbound+inbound)])
    			min1.push(outbound+inbound)
    		end
        end #end of search_start
        array1[min1.index(min1.min)].to_s if min1.size!=0
    end #end of seoul_search
    
end #end of class 
end # end of module