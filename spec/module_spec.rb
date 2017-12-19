require "rspec"

require_relative "../compiler/lexer"
require_relative "../compiler/exceptions"
include StardustCompiler

RSpec::describe(Lexer) do
	it "parses import statements" do
		tokens = Lexer.tokenize("Import f from utils.")
		expect(tokens).to(eq([[:import, "Import"], [:identifier, "f"],
			[:from, "from"], [:identifier, "utils"], [:period, "."]]))
	end

	it "parses export statements" do
		tokens = Lexer.tokenize("Export f, g in utils.")
		expect(tokens).to(eq([[:export, "Export"], [:identifier, "f"],
			[:comma, ","], [:identifier, "g"], [:in, "in"], [:identifier, "utils"],
			[:period, "."]]))
	end

	it "parses module declarations" do
		tokens = Lexer.tokenize("Define utils as module:\n\tDefine f as function(number x, returning number y):\n\t\tSet y to x * 2.\n\nExport f in utils.")
		expect(tokens).to(eq([[:define, "Define"], [:identifier, "utils"], [:as, "as"], [:module, "module"],
			[:colon, ":"], [:indent, nil], [:define, "Define"], [:identifier, "f"], [:as, "as"],
			[:function, "function"], [:open_parenthesis, "("], [:identifier, "number"], [:identifier, "x"],
			[:comma, ","], [:returning, "returning"], [:identifier, "number"], [:identifier, "y"],
			[:close_parenthesis, ")"], [:colon, ":"], [:indent, nil], [:set, "Set"],
			[:identifier, "y"], [:to, "to"], [:identifier, "x"], [:times, "*"], [:integer, "2"],
			[:period, "."], [:outdent, nil], [:outdent, nil], [:export, "Export"], [:identifier, "f"],
			[:in, "in"], [:identifier, "utils"], [:period, "."]]))
	end
end