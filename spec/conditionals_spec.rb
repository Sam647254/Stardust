require "rspec"

require_relative "../compiler/lexer"
require_relative "../compiler/exceptions"
include StardustCompiler

RSpec::describe(Lexer) do
	it "parses if and otherwise" do
		tokens = Lexer.tokenize("If x > y:\n\tSet z to 0.\nOtherwise:\n\tSet a to 0.")
		expect(tokens).to(eq([[:if, "If"], [:identifier, "x"],
			[:right_angle_bracket, ">"], [:identifier, "y"],
			[:colon, ":"], [:indent, nil], [:set, "Set"],
			[:identifier, "z"], [:to, "to"], [:integer, "0"],
			[:period, "."], [:outdent, nil], [:otherwise, "Otherwise"],
			[:colon, ":"], [:indent, nil], [:set, "Set"], [:identifier, "a"],
			[:to, "to"], [:integer, "0"], [:period, "."], [:outdent, nil]]))
	end

	it "parses nested if's" do
		tokens = Lexer.tokenize("If x > y:\n\tIf y > z:\n\t\tSet x to z.")
		expect(tokens).to((eq([[:if, "If"], [:identifier, "x"],
			[:right_angle_bracket, ">"], [:identifier, "y"],
			[:colon, ":"], [:indent, nil], [:if, "If"],
			[:identifier, "y"], [:right_angle_bracket, ">"],
			[:identifier, "z"], [:colon, ":"],
			[:indent, nil], [:set, "Set"], [:identifier, "x"],
			[:to, "to"], [:identifier, "z"], [:period, "."],
			[:outdent, nil], [:outdent, nil]])))
	end
end