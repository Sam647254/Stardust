require "rspec"

require_relative "../compiler/lexer"
require_relative "../compiler/exceptions"
include StardustCompiler

RSpec::describe(Lexer) do
	it "parses number declarations" do
		tokens = Lexer.tokenize("Define x as 3.")
		expect(tokens).to(eq([[:define, "Define"], [:identifier, "x"],
			[:as, "as"], [:integer, "3"], [:period, "."]]))
	end

	it "parses variable declarations" do
		tokens = Lexer.tokenize("Define x as y.")
		expect(tokens).to(eq([[:define, "Define"], [:identifier, "x"],
			[:as, "as"], [:identifier, "y"], [:period, "."]]))
	end

	it "handles semi-case-sensitive identifiers" do
		tokens = Lexer.tokenize("Define dEfine as \"123\".")
		expect(tokens).to(eq([[:define, "Define"], [:identifier, "dEfine"],
			[:as, "as"], [:string_literal, "123"],
			[:period, "."]]))
	end

	it "parses array declarations" do
		tokens = Lexer.tokenize("Define number_array as array(number)(1, 2, 3).")
		expect(tokens).to(eq([[:define, "Define"], [:identifier, "number_array"],
			[:as, "as"], [:identifier, "array"], [:open_parenthesis, "("],
			[:identifier, "number"], [:close_parenthesis, ")"], [:open_parenthesis, "("],
			[:integer, "1"], [:comma, ","], [:integer, "2"], [:comma, ","], [:integer, "3"],
			[:close_parenthesis, ")"], [:period, "."]]))
	end
end