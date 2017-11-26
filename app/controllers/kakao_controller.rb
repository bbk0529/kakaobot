require 'msgmaker'
require 'parser'

class KakaoController < ApplicationController
  
  @@keyboard = Msgmaker::Keyboard.new ##@@ 클래스 변수 선언, Msgmaker(Module), Keyboard(Class)
  @@message = Msgmaker::Message.new
  @@ticket = Ticket::Skyscanner.new


  @@btnkeyboard = @@keyboard.getBtnKey(["서울출발","부산출발", "방콕도착", "하노이도착", "현재상태", "출발"])

  def keyboard
    render json:  @@btnkeyboard
    #render json: @@keyboard.getTextKey()
  end

  def message
    basic_keyboard =  @@keyboard.getTextKey()
    input = params[:content]
    
    # # if input =="고양이"
    # #   parse = Parser::Animal.new
    # #   message=@@message.getPicMessage("나도 없지롱고양이 없지롱", parse.cat)
      
    # # elsif input =="영화"
    # #   parse = Parser::Movie.new
    # #   message=@@message.getMessage(parse.naver + ["재밌다고 합니다", "볼만하다고 합니다"].sample)
    # # elsif input=="악뮤"
    # #   parse = Parser::Akmu.new
    # #   message=@@message.getMessage(parse.get_news)
    # # else 
    # #   message=@@message.getMessage("없는 명령어 입니다.")
    # # end
    # parse = Parser::Akmu.new
    # message=@@message.getMessage(parse.get_news(input))
    
    
    
     if input=="출발"
      
       result = {
          message: @@message.getMessage(@@ticket.start_search),
          keyboard:  @@btnkeyboard
        }
     
    end
    
    if input=="서울출발"
      
       @@ticket.setDeparture("서울")
       result = {
          message: @@message.getMessage(@@ticket.getDeparture + "출발"),
          keyboard:  @@btnkeyboard
        }
     
    end
    
     if input=="부산출발"
       @@ticket.setDeparture("부산")
       result = {
          message: @@message.getMessage(@@ticket.getDeparture + "출발"),
          keyboard:  @@btnkeyboard
        }
    end
    
    
    if input=="방콕도착"
       @@ticket.setArrival("방콕")
       result = {
          message: @@message.getMessage(@@ticket.getArrival + "도착"),
          keyboard:  @@btnkeyboard
        }
    end
    
      if input=="하노이도착"
       @@ticket.setArrival("하노이")
       result = {
          message: @@message.getMessage(@@ticket.getArrival + "도착"),
          keyboard:  @@btnkeyboard
        }
    end
    
    
    if input=="현재상태"
       result = {
          message: @@message.getMessage(@@ticket.getStatus),
          keyboard:  @@btnkeyboard
        }
    end
    
    render json: result    
  end

  
  def friend_add
    user_key=params[:user_key]
    User.create(
      user_key:user_key,
      chat_room: 0
    )
    render nothing:true
    
  end 
  
  def friend_del
    user_key=params[:user_key]
    user=User.find_by(user_key: user_key)
    user.destroy  
    render nothing:true
    
  end 
  
  def chat_room
    user_key=params[:user_key]
    user=User.find_by(user_key: user_key)
    
    user.update(chat_room: user.chat_room+1)
    
    render nothing:true
  end 

  
end
