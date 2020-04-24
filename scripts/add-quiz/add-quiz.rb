#!/usr/bin/env ruby
require 'optparse'
require "pp"

SPLITTER = /(\t)/

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
      answer: nil,
      quiz: nil,
      number_of_choice: 4,
      check: false,
    }

    op.banner = "Usage: add-quiz.rb [options] FILE"
    op.on('-a', '--answer-index VALUE', "Index of answer field. (default: #{opts[:answer]})") {|v| opts[:answer] = v.to_i }
    op.on('-q', '--quiz-index VALUE', "Index of quiz field to insert. (default: #{opts[:quiz]})") {|v| opts[:quiz] = v.to_i }
    op.on('-n', '--number-of-choice VALUE', "Number of choice. (default: #{opts[:number_of_choice]})") {|v| opts[:number_of_choice] = v.to_i }
    op.on('-c', '--check', "Check with first line. (default: #{opts[:check]})") {|v| opts[:check] = v }

    begin
      args = op.parse!(argv)
    rescue OptionParser::InvalidOption => e
      usage e.message
    end

    [opts, args]
  end

  def extract_meaning(s)
    # s.match(/【(.)】(.+?)(?:[、。]|(:?<br>)|$)/)
    s.match(/(.+?)(?:[、。]|(:?<br>)|$)/)
    $1
  end

  def get_choices(answer, choices, num_of_choice)
    result = choices.clone
    result.delete(answer)
    result = result.sample(num_of_choice - 1).map {|e| %!<li>#{e}</li>! }
    result.push %!<li id="quiz-answer">#{answer}</li>!
    %!<ul id="quiz">#{result.shuffle().join('')}</ul>!
  end


  def inspect_array_with_index(array)
    array.each_with_index do |e, idx|
      puts "%2d: #{e.inspect}" % idx
    end
  end

  def run
    opts, args = parse_options

    file = ARGV.pop

    unless File.exists?(file)
      usage "File does not exists #{file}"
    end

    lines = File.readlines(file)
    unless opts[:answer] and opts[:quiz]
      line = lines.shift
      self.inspect_array_with_index line.chomp.split(SPLITTER)
      puts <<~USAGE

      - Pick answer index, then pass it as -a options. e.g. -a 8
      - Pick quiz index(which should be empty field), then pass it as -q options. e.g. -q 10

      example: Check with a very first line
        $ ruby add-quiz.rb -a 8 -q 10 -c FILE

      example: Process all records
        $ ruby add-quiz.rb -a 8 -q 10 FILE > FILE-new

      USAGE
      exit 1
    end

    answers = []
    notes = []

    lines.each do |line|
      fields = line.chomp.split(/(\t)/)
      notes.push(fields)
      answers.push(self.extract_meaning(fields[opts[:answer]]))
    end

    all_choices = answers.uniq

    notes.each_with_index do |fields, idx|
      fields[opts[:quiz]] = self.get_choices(answers[idx], all_choices, opts[:number_of_choice])
      if (opts[:check])
        puts opts.inspect
        self.inspect_array_with_index fields
        break
      end
      puts fields.join('')
    end
  end
end

CLI.new.run
