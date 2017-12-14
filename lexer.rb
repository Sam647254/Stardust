require "logger"
require "pry"

require "./helper"
include StardustCompiler

$logger = Logger.new(STDERR)

module StardustCompiler
	class Lexer
		def self.tokenize(string)
			input = StringIO.new(string)
			current_state = :start
			position = 0
			tokens = []
			current_token = nil

			while !input.eof?
				next_char = input.readchar
				new_tokens, characters_consumed, new_state, next_token_accumulator =
					transition(current_state, next_char, current_token, input)

				if new_state == :error
					puts("Unexpected \"#{next_char || "EOF"}\" at position #{position}")
					return
				end

				current_state = new_state
				current_token = next_token_accumulator
				tokens.push(*new_tokens)
				position += characters_consumed
				position += 1
			end

			# Final transition on EOF
			new_tokens, characters_consumed, next_state =
				transition(current_state, nil, current_token, input)
			tokens.push(*new_tokens)
			return tokens
		end

		def self.transition(current_state, next_char, current_token, input)
			next_state = :error
			characters_consumed = 0
			new_tokens = []
			next_token_accumulator = nil

			if next_char == " " && current_state != :start
				new_tokens.push([current_state, current_token])
				next_state = :start
			else
				case current_state
				when :start
					if Helper::number?(next_char)
						next_state = :integer
						next_token_accumulator = next_char
					end
				when :integer
					if Helper::number?(next_char)
						next_state = :integer
						next_token_accumulator = current_token + next_char
					elsif next_char == "."
						second_char = input.eof? ? nil : input.readchar
						characters_consumed += 1
						if Helper::number?(second_char)
							next_token_accumulator = current_token + next_char + second_char
							next_state = :decimal
						elsif [" ", "\n", nil].include?(second_char)
							new_tokens << [:integer, current_token]
							new_tokens << [:period, next_char]
							next_state = :start
						end	
					end
				when :decimal
					if Helper::number?(next_char)
						next_state = :decimal
						next_token_accumulator = current_token + next_char
					elsif next_char == "."
						next_state = :period
						new_tokens << [:decimal, current_token]
						current_token = next_char
					end
				when :period
					if [" ", "\n", nil].include?(next_char)
						next_state = :start
						new_tokens << [:period, current_token]
					end
				end
			end

			$logger.debug("#{current_state} - transitioning to #{next_state} on #{next_char}")
			return new_tokens, characters_consumed, next_state, next_token_accumulator
		end
	end
end