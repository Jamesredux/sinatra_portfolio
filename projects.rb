
require 'sinatra'
require "sinatra/reloader" if development?
require './helpers/hangman.rb'
require './helpers/caesar_cypher.rb'


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




