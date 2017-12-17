require "rspec"

require_relative "../compiler/lexer"
require_relative "../compiler/exceptions"
include StardustCompiler

RSpec::describe(Lexer) do
	it "parses string literals" do
		tokens = Lexer.tokenize("\"Alum\".")
		expect(tokens).to(eq([[:string_literal, "Alum"], [:period, "."]]))
		tokens = Lexer.tokenize("\"Alum yay moe yeh\".")
		expect(tokens).to(eq([[:string_literal, "Alum yay moe yeh"], [:period, "."]]))
	end

	it "handles empty strings" do
		tokens = Lexer.tokenize("\"\".")
		expect(tokens).to(eq([[:string_literal, ""], [:period, "."]]))
	end
end