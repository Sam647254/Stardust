require "rspec"

require_relative "../compiler/lexer"
require_relative "../compiler/exceptions"
include StardustCompiler

RSpec::describe(Lexer) do
	it "handles addition" do
		tokens = Lexer.tokenize("Define x as number 3 + 4.")
		expect(tokens).to(eq([[:define, "Define"], [:identifier, "x"],
			[:as, "as"], [:number, "number"], [:integer, "3"], [:plus, "+"],
			[:integer, "4"], [:period, "."]]))
		tokens = Lexer.tokenize("Define x as number 3+4.")
		expect(tokens).to(eq([[:define, "Define"], [:identifier, "x"],
			[:as, "as"], [:number, "number"], [:integer, "3"], [:plus, "+"],
			[:integer, "4"], [:period, "."]]))
	end

	it "handles subtraction" do
		tokens = Lexer.tokenize("Define x as number 4 - 3.")
		expect(tokens).to(eq([[:define, "Define"], [:identifier, "x"],
			[:as, "as"], [:number, "number"], [:integer, "4"], [:minus, "-"],
			[:integer, "3"], [:period, "."]]))
		tokens = Lexer.tokenize("Define x as number 4-3.")
		expect(tokens).to(eq([[:define, "Define"], [:identifier, "x"],
			[:as, "as"], [:number, "number"], [:integer, "4"], [:minus, "-"],
			[:integer, "3"], [:period, "."]]))
	end

	it "handles multiplication" do
		tokens = Lexer.tokenize("Define x as number 4 * 3.")
		expect(tokens).to(eq([[:define, "Define"], [:identifier, "x"],
			[:as, "as"], [:number, "number"], [:integer, "4"], [:times, "*"],
			[:integer, "3"], [:period, "."]]))
		tokens = Lexer.tokenize("Define x as number 4*3.")
		expect(tokens).to(eq([[:define, "Define"], [:identifier, "x"],
			[:as, "as"], [:number, "number"], [:integer, "4"], [:times, "*"],
			[:integer, "3"], [:period, "."]]))
	end
end