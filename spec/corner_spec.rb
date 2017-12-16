require "rspec"

require_relative "../compiler/lexer"
require_relative "../compiler/exceptions"
include StardustCompiler

RSpec::describe(Lexer) do
	it "handles empty string" do
		tokens = Lexer.tokenize("")
		expect(tokens).to(eq([]))
	end
end