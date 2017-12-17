require "rspec"

require_relative "../compiler/lexer"
require_relative "../compiler/exceptions"
include StardustCompiler

RSpec::describe(Lexer) do
	it "parses function calls" do
		tokens = Lexer.tokenize("Define result as f(x).")
		expect(tokens).to(eq([[:define, "Define"], [:identifier, "result"],
			[:as, "as"], [:identifier, "f"], [:open_parenthesis, "("],
			[:identifier, "x"], [:close_parenthesis, ")"],
			[:period, "."]]))
	end

	it "parses main function signature" do
		tokens = Lexer.tokenize("Define main function(string array arguments):")
		expect(tokens).to(eq([[:define, "Define"], [:main, "main"], [:function, "function"],
			[:open_parenthesis, "("], [:string, "string"], [:array, "array"],
			[:identifier, "arguments"], [:close_parenthesis, ")"], [:colon, ":"]]))
	end
end