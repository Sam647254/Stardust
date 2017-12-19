require "rspec"

require_relative "../compiler/lexer"
require_relative "../compiler/exceptions"
include StardustCompiler

RSpec::describe(Lexer) do
	it "parses function calls" do
		tokens = Lexer.tokenize("Define result as number f(x).")
		expect(tokens).to(eq([[:define, "Define"], [:identifier, "result"],
			[:as, "as"], [:identifier, "number"], [:identifier, "f"],
			[:open_parenthesis, "("], [:identifier, "x"], [:close_parenthesis, ")"],
			[:period, "."]]))
	end

	it "parses main function signature" do
		tokens = Lexer.tokenize("Define main function(array(string) arguments):")
		expect(tokens).to(eq([[:define, "Define"], [:main, "main"], [:function, "function"],
			[:open_parenthesis, "("], [:identifier, "array"], [:open_parenthesis, "("],
			[:identifier, "string"], [:close_parenthesis, ")"],[:identifier, "arguments"],
			[:close_parenthesis, ")"], [:colon, ":"]]))
	end

	it "parses functions" do
		tokens = Lexer.tokenize("Define f as function(number x, returning number y):\n\tSet y to x*2.")
		expect(tokens).to(eq([[:define, "Define"], [:identifier, "f"], [:as, "as"],
			[:function, "function"], [:open_parenthesis, "("], [:identifier, "number"],
			[:identifier, "x"], [:comma, ","], [:returning, "returning"],
			[:identifier, "number"], [:identifier, "y"],
			[:close_parenthesis, ")"], [:colon, ":"], [:indent, nil],
			[:set, "Set"], [:identifier, "y"], [:to, "to"], [:identifier, "x"],
			[:times, "*"], [:integer, "2"],
			[:period, "."], [:outdent, nil]]))
	end
end