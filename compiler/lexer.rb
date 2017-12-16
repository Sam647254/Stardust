require "logger"
require "pry"

require_relative "./helper"
require_relative "./exceptions"
include StardustCompiler

$logger = Logger.new(STDERR)
$logger.level = Logger::DEBUG

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
					raise StardustCompiler::SyntaxError.new(
						"Unexpected \"#{next_char || "EOF"}\" at position #{position}"
					)
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
			if next_state == :error
				raise StardustCompiler::SyntaxError.new(
					"Unexpected EOF after #{current_token}"
				)
			end
			tokens.push(*new_tokens)
			return tokens
		end

		def self.transition(current_state, next_char, current_token, input)
			next_state = :error
			characters_consumed = 0
			new_tokens = []
			next_token_accumulator = nil

			if next_char == " " && ![:start, :string_start, :comment].include?(current_state)
				new_tokens << [current_state, current_token]
				next_state = :start
			elsif next_char == nil && current_state == :start
				next_state = :eof
			else
				case current_state
				when :start
					next_token_accumulator = next_char
					if Helper::number?(next_char)
						next_state = :integer
					elsif next_char == "\""
						next_state = :string_start
						next_token_accumulator = ""
					elsif next_char == "/"
						next_state = :divide
					end
				when :integer, :decimal
					if Helper::number?(next_char)
						next_state = current_state
						next_token_accumulator = current_token + next_char
					elsif next_char == "."
						if current_state == :integer
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
						elsif current_state == :decimal
							next_state = :period
							next_token_accumulator = next_char
							new_tokens << [:decimal, current_token]
						end
					elsif next_char == "'"
						next_state = :"#{current_state}_separator"
						next_token_accumulator = current_token + next_char
					elsif next_char == "/"
						new_tokens << [current_state, current_token]
						next_state = :divide
						next_token_accumulator = next_char
					end
				when :period
					if [" ", "\n", nil].include?(next_char)
						next_state = :start
						new_tokens << [:period, current_token]
					end
				when :integer_separator
					if Helper::number?(next_char)
						next_state = :integer
						next_token_accumulator = current_token + next_char
					end
				when :decimal_separator
					if Helper::number?(next_char)
						next_state = :decimal
						next_token_accumulator = current_token + next_char
					end
				when :string_start
					if next_char == "\""
						next_state = :string
						next_token_accumulator = current_token
					else
						next_token_accumulator = current_token + next_char
						next_state = :string_start
					end
				when :string
					if next_char == "."
						next_state = :period
						next_token_accumulator = next_char
						new_tokens << [:string, current_token]
					end
				when :divide
					if next_char == "/"
						next_state = :comment
						next_token_accumulator = nil
					end
				when :comment
					unless ["\n", nil].include?(next_char)
						next_state = :comment
					else
						next_state = :start
					end
				end
			end
			return new_tokens, characters_consumed, next_state, next_token_accumulator
		end
	end
end