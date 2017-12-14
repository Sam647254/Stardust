require "optparse"

require "./lexer"
include StardustCompiler

options = {}

ARGV.options do |opts|
	opts.banner = "Usage:  #{File.basename($PROGRAM_NAME)} [OPTIONS]"
	opts.separator ""

	opts.on("-h", "--help", "Show this message.") do
		puts opts
		exit
	end

	opts.on("-t", "--tokenize-only", "Output tokens only") do |opt|
		options[:tokenize] = true
	end
	
	begin
		opts.parse!
	rescue
		puts opts
		exit
	end
end

if options[:tokenize]
	puts("Running tokenizer only")
end

print("Stardust> ")
line = gets().chomp
while line != nil
	puts(Lexer.tokenize(line))
	print("Stardust> ")
	line = gets().chomp
end