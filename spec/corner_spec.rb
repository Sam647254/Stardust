require "rspec"

require_relative "../compiler/lexer"
require_relative "../compiler/exceptions"
include StardustCompiler

RSpec::describe(Lexer) do
	it "handles empty string" do
		tokens = Lexer.tokenize("")
		expect(tokens).to(eq([]))
	end

	it "prevents starting a line with a period" do
		expect() {Lexer.tokenize("123\n.")}.to(raise_error(StardustCompiler::SyntaxError))
	end

	it "handles statments spanning more than one line" do
		expect(Lexer.tokenize("Define x\nas number 3.")).to(eq([
			[:define, "Define"], [:identifier, "x"], [:as, "as"],
			[:identifier, "number"], [:integer, "3"], [:period, "."]
		]))
	end
end