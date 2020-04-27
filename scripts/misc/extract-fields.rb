#!/usr/bin/env ruby
require 'optparse'
require "pp"

class CLI
  def parse_options(argv = ARGV)
    op = OptionParser.new

    self.class.module_eval do
      define_method(:usage) do |msg = nil|
        puts op.to_s
        puts "error: #{msg}" if msg
        exit 1
      end
    end

    # default value
    opts = {
      report: false,
      split: "\t",
      join: "\t",
      fields: [],
      keep: false,
    }

    op.on('-r', '--report', "Report field configuration from very 1st line. (default: #{opts[:report]})") {|v| opts[:report] = v }
    op.on('-s', '--split VALUE', "string value (default: #{opts[:split].inspect})") {|v|
      opts[:split] = v.gsub('\\t', "\t")
    }
    op.on('-j', '--join VALUE', "string value (default: #{opts[:join].inspect})") {|v|
      opts[:join] = v.gsub('\\t', "\t")
    }
    op.on('-k', '--keep', "Keep separator. (default: #{opts[:keep]})") {|v|
      opts[:keep] = v
    }
    op.on('-f', '--fields to extract index starting with zero', Array, "fields to extract (default: #{opts[:fields]})") {|v| opts[:fields] = v }

    begin
      args = op.parse!(argv)
    rescue OptionParser::InvalidOption => e
      usage e.message
    end

    [opts, args]
  end

  def run
    opts, args = parse_options
    splitter = opts[:split]
    if (opts[:keep])
      splitter = /(#{splitter})/
    end

    if (opts[:report] or opts[:fields].empty?)
      puts "opts: #{opts.to_s}"
      puts "args: #{args.to_s}"
      puts

      ARGF.each do |line|
        line.chomp.split(splitter, -1).each_with_index do |e, idx|
          puts "%2d: #{e.inspect}" % idx
        end
        if opts[:fields].empty?
          puts <<~USAGE

          example:
            $ extract-fields.rb -f 3,6 FILE
            $ extract-fields.rb -f 3,6 -s : -j :: FILE
            $ extract-fields.rb -f 6,5,4 FILE
            $ cat FILE | extract-fields.rb -f 1,5
          USAGE
        end
        break
      end
      puts
      return
    end

    fields_to_extract = opts[:fields].map {|n| n.to_i }
    ARGF.each do |line|
      split = line.chomp.split(splitter, -1)
      extracted = fields_to_extract.map {|n| split.values_at(n) }
      puts extracted.join(opts[:join])
    end
  end
end

CLI.new.run
