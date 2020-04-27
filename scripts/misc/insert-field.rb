#!/usr/bin/env ruby
require 'optparse'
require "pp"

SPLITTER = /\t/

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
      index: nil,
      replace: false,
      check: false,
    }

    op.banner = "Usage: add-quiz.rb [options] TARGET_FILE FROM_FILE"
    op.on('-i', '--index VALUE', "Index to insert/replace(-r) field. (default: #{opts[:index]})") {|v| opts[:index] = v.to_i }
    op.on('-r', '--replace', "Replace field insetead of insert(default behavior). (default: #{opts[:replace]})") {|v| opts[:replace] = v }
    op.on('-c', '--check', "Check with first line. (default: #{opts[:check]})") {|v| opts[:check] = v }

    begin
      args = op.parse!(argv)
    rescue OptionParser::InvalidOption => e
      usage e.message
    end

    [opts, args]
  end

  def inspect_array_with_index(array)
    array.each_with_index do |e, idx|
      puts "%2d: #{e.inspect}" % idx
    end
  end

  def run
    opts, args = parse_options

    from_file = ARGV.pop
    target_file = ARGV.pop

    unless File.exists?(target_file.to_s)
      usage "File does not exists #{target_file}"
    end
    unless File.exists?(from_file.to_s)
      usage "File does not exists #{from_file}"
    end

    lines = File.readlines(target_file)
    items_to_insert = File.readlines(from_file).map {|e| e.chomp }

    lines.each_with_index do |line, idx|
      fields = line.chomp.split(SPLITTER, -1)

      item = items_to_insert[idx]

      if (opts[:check])
        item = item + " <---- Inserted"
      end

      unless (opts[:index] and opts[:index])
        self.inspect_array_with_index fields
        puts
        usage
        exit 1
      end

      if opts[:replace]
        fields[opts[:index]] = item
      else
        fields.insert(opts[:index], item)
      end


      if (opts[:check])
        puts opts.inspect
        self.inspect_array_with_index fields
        break
      end
      puts fields.join("\t")
    end
  end
end

CLI.new.run
