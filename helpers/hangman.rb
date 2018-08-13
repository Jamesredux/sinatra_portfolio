
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
