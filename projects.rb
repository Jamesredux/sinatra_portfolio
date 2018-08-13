
require 'sinatra'
require "sinatra/reloader" if development?

enable :sessions

get '/' do 
	erb :contents
end	

#hangman
get '/hangman' do 
	erb :intro
end	

get '/easy_game' do 
	session[:game] = Game.new("dict3000")
	session[:progess] = session[:game].progress.join
	session[:answer] = session[:game].word
	session[:guess_count] = session[:game].guess_count
	@message_1 = "You have #{6-session[:guess_count]} guesses left."
	erb :index		
end	

get '/hard_game' do 
	session[:game] = Game.new("dict")
	session[:progess] = session[:game].progress.join
	session[:answer] = session[:game].word
	session[:guess_count] = session[:game].guess_count
	@message_1 = "You have #{6-session[:guess_count]} guesses left."
	erb :index		
end	

post '/guess' do 
	@guess = params["guess"]
	@past_letters = session[:game].past_letters
	checker = Validator.new(@guess, @past_letters)
		if checker.valid?
			session[:game].past_letters<<@guess
			session[:game].check_guess(session[:game].word_array, @guess)
				if session[:game].solved?
					redirect "/win"
				else
					if session[:game].time_up?
						redirect "/gameover"
					else		
						redirect "/guess"
					end		
				end
		else
		@message_1 = checker.message
		erb :index
	end		
end	

get '/guess' do 
	session[:guess_count] = session[:game].guess_count
	session[:progess] = session[:game].progress.join
	@message_1 = "You have #{6-session[:guess_count]} guesses left."
	erb :index
end	

get '/win' do 
	@pic = "safe"
	@message_1 = "Congratulations. You Survived. The word was - #{session[:answer].upcase}"
	erb :endgame
end	

get '/gameover' do 
	@pic = "6"
	@message_1 = "You lose. The word was #{session[:answer].upcase}"
	erb :endgame
end

#ceasar_cypher

get '/caesar_cypher' do 
	erb :cypher 
end	

post '/result' do 
	@string = params['string']
	@key = params['shift']
	validator = InputValidator.new(@string, @key)
	if validator.valid?
		@shift = @key.to_i
			@result = encrypt(@string, @shift)
			erb :result
	else
			@message = validator.message
			erb :index
	end				
end	




helpers do 

	class Game

	attr_accessor :progress, :guess_count, :past_letters, :word, :word_array

		def initialize(difficulty)
			dictionary = difficulty
			@word = get_word(difficulty) 
			@word_array = @word.chars
			@guess_count = 0
			@progress = Array.new(@word_array.size) {"_"}
			@past_letters = []			
		end

		def get_word(difficulty)
			words = File.readlines("./data/#{difficulty}.txt")   #there are 2 dics the one suggested has a lot of wierd words so i just used the 3000 most common english words
			word = words.select { |w| w.size > 4 && w.size <  13 }.sample
			word = word.downcase.chomp
		end	

		def check_guess(word_array, guess='$')
			@correct_guess = false
			x = 0
			word_array.each do |l|
				if guess.include? l
						@progress[x] = l
						x += 1				
						@correct_guess = true
				else
					x += 1
				end
			end

			@guess_count += 1 if @correct_guess == false

		end

		def solved?
			if @progress.include? "_"
				false
			else
				true
			end		

		end

		def time_up?
			if @guess_count > 5
				true
			end			
		end	
	end	

end	


class Validator

	def initialize(guess, past_letters)
		@guess = guess.downcase
		@past_letters = past_letters	
	end

	def valid?
		validate
		@message.nil?
	end

	def message
		@message
	end

	def validate
		if @guess.empty?
			@message = "Please put a guess in the field"
		elsif invalid_input?(@guess) == true
			@message = "I did not understand that choice, please try again."
		elsif already_tried?(@guess) == true			
			@message = "You have already tried that letter"
		end			
		
	end

	def invalid_input?(guess)
		(guess.match  /^[a-z]{1}$/).nil?		
	end

	def already_tried?(guess)
		@past_letters.include? guess	
	end
end	

##caesar cypher helpers

helpers do 


 def encrypt(string, shift)
 	 code = []  #create the array that  the code will be put in
   text = string.split('')  #turn string into array of characters

    #iterate through the characters "x" one character at a time
    text.each do |x|  
     x = x.ord #convert to ascii

     	if (95..122).include?(x) #lower case letters
     		x += shift
     			if x>122  #wraparound!
     				x -= 26
     			end
     		x = x.chr
     		code<<x
   		elsif (65..90).include?(x) #upper case letters
   		 	x += shift
   		 		if x > 90
   		 			x -= 26
   		 		end
   	 		x = x.chr
   	 		code <<x
   		else    #leave all other characters eg space/!!? as they are
   	 		x = x.chr
   	 		code<<x
     	end 
    end  
      code = code.join 
      return code	
 end  


class InputValidator

	def initialize(string, key)
		@string = string
		@key = key	
	end

	def valid?
		validate
		@message.nil?
	end
	
	def message
		@message
	end	

	def validate
		if @string.empty? || @key.empty?
			@message = "You need to complete both fields"
		elsif is_int?(@key) == false
			@message = "Please input a number in the key field."
		end		
	end	


	def is_int?(key)
		key.to_s == key.to_i.to_s
	end	
end 

end

