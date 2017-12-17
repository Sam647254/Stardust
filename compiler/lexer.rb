require "logger"
require "pry"
require "set"

require_relative "./helper"
require_relative "./exceptions"
include StardustCompiler

$logger = Logger.new(STDERR)
$logger.level = Logger::DEBUG

module StardustCompiler
	KEYWORDS = [
		"array",
		"as",
		"define",
		"function",
		"main",
		"number",
		"string"
	].to_set

	class Lexer
		def self.tokenize(string)
			input = StringIO.new(string)
			current_state = :sentence_start
			position = 0
			indentation_level = 0
			tokens = []
			current_token = nil
			repeat_character = false

			while !input.eof? || repeat_character
				unless repeat_character
					next_char = input.readchar
				end
				new_tokens, characters_consumed, new_state, next_token_accumulator, new_indentation_level, repeat_character,
					error_reason = transition(current_state, indentation_level, next_char, current_token, input)
				if new_state == :error
					raise StardustCompiler::SyntaxError.new(
						"Unexpected \"#{next_char || "EOF"}\" at position #{position}#{": #{error_reason}" unless error_reason.nil?}"
					)
				end

				current_state = new_state
				current_token = next_token_accumulator
				tokens.push(*new_tokens)
				position += characters_consumed
				position += 1
				indentation_level = new_indentation_level
			end

			# Final transition on EOF
			new_tokens, characters_consumed, next_state, new_indentation_level, error_reason =
				transition(current_state, indentation_level, nil, current_token, input)
			if next_state == :error
				raise StardustCompiler::SyntaxError.new(
					"Unexpected EOF after #{current_token}"
				)
			end
			tokens.push(*new_tokens)
			return tokens
		end

		def self.transition(current_state, indentation_level, next_char, current_token, input)
			next_state = :error
			error_reason = nil
			characters_consumed = 0
			new_tokens = []
			next_token_accumulator = nil
			new_indentation_level = indentation_level
			repeat_character = false

			if [" ", "\n", nil].include?(next_char) \
				&& ![:start, :sentence_start, :string_start, :comment].include?(current_state)
				if current_state == :identifier &&
					Helper::lowercase?(current_token[1..-1]) && KEYWORDS.include?(current_token.downcase)
					# Test for keyword
					new_tokens << [current_token.downcase.to_sym, current_token]
				else
					new_tokens << [current_state, current_token]
				end
				next_state = :start
			elsif next_char == nil && [:sentence_start, :start].include?(current_state)
				next_state = :eof
			else
				case current_state
				when :start, :sentence_start
					next_token_accumulator = next_char
					if Helper::number?(next_char)
						next_state = :integer
					elsif next_char == "\""
						next_state = :string_start
						next_token_accumulator = ""
					elsif !(operator = ["+", "-", "*", "/", "^"].index(next_char)).nil?
						next_state = [:plus, :minus, :times, :divide, :exponent][operator]
					elsif next_char == "("
						new_tokens << [:open_parenthesis, next_char]
						next_state = :start
					elsif next_char == ")"
						new_tokens << [:close_parenthesis, next_char]
						next_state = :space_or_punctuation
					elsif Helper::letter?(next_char)
						if current_state == :sentence_start && Helper::lowercase?(next_char)
							error_reason = "should be capitalized"
						else
							next_state = :identifier
							next_token_accumulator = next_char
						end
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
					elsif !(operator = ["+", "-", "*", "/", "^"].index(next_char)).nil?
						next_state = [:plus, :minus, :times, :divide, :exponent][operator]
						new_tokens << [current_state, current_token]
						next_token_accumulator = next_char
					elsif Helper::valid_id_character?(next_char) && current_state == :integer
						next_state = :identifier
						next_token_accumulator = current_token + next_char
					end
				when :period
					if [" ", "\n", nil].include?(next_char)
						next_state = :sentence_start
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
						next_state = :string_literal
						next_token_accumulator = current_token
					else
						next_token_accumulator = current_token + next_char
						next_state = :string_start
					end
				when :string_literal
					if next_char == "."
						next_state = :period
						next_token_accumulator = next_char
						new_tokens << [:string_literal, current_token]
					end

				when :identifier
					if Helper::valid_id_character?(next_char)
						next_state = :identifier
						next_token_accumulator = current_token + next_char
					else
						if Helper::lowercase?(current_token[1..-1]) && KEYWORDS.include?(current_token.downcase)
							new_tokens << [current_token.downcase.to_sym, current_token]
						else
							new_tokens << [:identifier, current_token]
						end
						case next_char
						when "."
							next_token_accumulator = next_char
							next_state = :period
						else
							next_state = :start
							repeat_character = true
						end
					end

				# Operators
				when :plus, :minus, :times
					if Helper::number?(next_char)
						next_state = :integer
						new_tokens << [current_state, current_token]
						next_token_accumulator = next_char
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
				when :space_or_punctuation
					case next_char
					when "."
						next_state = :period
						next_token_accumulator = next_char
					when ":"
						next_state = :colon
						next_token_accumulator = next_char
					when " ", "\n"
						next_state = :start
					end
				end
			end
			return new_tokens, characters_consumed, next_state, next_token_accumulator,
				new_indentation_level, repeat_character, error_reason
		end
	end
end