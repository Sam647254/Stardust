require "rspec"

require_relative "../compiler/lexer"
require_relative "../compiler/exceptions"
include StardustCompiler

RSpec::describe(Lexer) do
	it "parses single numbers" do
		tokens = Lexer.tokenize("123.")
		expect(tokens).to(eq([[:integer, "123"], [:period, "."]]))
	end

	it "parses multiple numbers" do
		tokens = Lexer.tokenize("123. 456.")
		expect(tokens).to(eq([[:integer, "123"], [:period, "."],
			[:integer, "456"], [:period, "."]]))
	end

	it "parses single decimal" do
		tokens = Lexer.tokenize("123.456.")
		expect(tokens).to(eq([[:decimal, "123.456"], [:period, "."]]))
	end

	it "parses multiple decimals" do
		tokens = Lexer.tokenize("123.456. 123.456.")
		expect(tokens).to(eq([[:decimal, "123.456"], [:period, "."],
			[:decimal, "123.456"], [:period, "."]]))
	end

	it "parses negative numbers" do
		tokens = Lexer.tokenize("-1. -2.3. -1'234.567.")
		expect(tokens).to(eq([[:minus, "-"], [:integer, "1"], [:period, "."],
			[:minus, "-"], [:decimal, "2.3"], [:period, "."], [:minus, "-"],
			[:decimal, "1'234.567"], [:period, "."]]))
	end

	it "parses numbers with digit separators" do
		tokens = Lexer.tokenize("123'456.")
		expect(tokens).to(eq([[:integer, "123'456"], [:period, "."]]))
		tokens = Lexer.tokenize("123'456'789.")
		expect(tokens).to(eq([[:integer, "123'456'789"], [:period, "."]]))
	end

	it "parses decimals with digit separators" do
		tokens = Lexer.tokenize("123.456'789.")
		expect(tokens).to(eq([[:decimal, "123.456'789"], [:period, "."]]))
		tokens = Lexer.tokenize("123'456.78'9.")
		expect(tokens).to(eq([[:decimal, "123'456.78'9"], [:period, "."]]))
	end

	it "captures numbers without period" do
		expect(Lexer.tokenize("123")).to(eq([[:integer, "123"]]))
		expect(Lexer.tokenize("123.456")).to(eq([[:decimal, "123.456"]]))
	end

	it "captures numbers with consecutive separators" do
		expect {Lexer.tokenize("1''2")}.to(raise_error(StardustCompiler::SyntaxError))
	end
end