require "rspec"

require_relative "../compiler/lexer"
require_relative "../compiler/exceptions"
include StardustCompiler

RSpec::describe(Lexer) do
	it "ignores comments" do
		expect(Lexer.tokenize("// This is a comment")).to(eq([]))
		expect(Lexer.tokenize("123. // 123\n456. // 456")).to(
			eq([[:integer, "123"], [:period, "."], [:integer, "456"], [:period, "."]])
		)
	end
end