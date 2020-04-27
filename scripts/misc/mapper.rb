# sample-1
def parentheses(item)
  "( " + item + " )"
end

# sample-2
def img_src(item)
  %!<img src="google-img--#{item}.jpg">!
end


# Sample-3: generate quiz
# - Read choices from "choices" generated in advance.
# - `extract_meaning` eliminate verbose text to make quiz choice simple.
def extract_meaning(s)
  # s.match(/【(.)】(.+?)(?:[、。]|(:?<br>)|$)/)
  s.match(/(.+?)(?:[、。]|(:?<br>)|$)/)
  $1
end


QUIZ_FILE = "./choices"
NUM_OF_CHOICE = 4

def init_choices
  File.readlines(QUIZ_FILE).uniq.map do |e|
    extract_meaning(e.chomp)
  end
end

def quiz(item)
  $choices ||= init_choices

  item = extract_meaning(item)
  choices = $choices.clone
  choices.delete(item)
  result = choices.sample(NUM_OF_CHOICE - 1).map {|e| %!<li>#{e}</li>! }
  result.push %!<li id="quiz-answer">#{item}</li>!
  %!<ul id="quiz">#{result.shuffle().join('')}</ul>!
end

ARGF.each do |e|
  # puts parentheses(e.chomp)
  # puts img_src(e.chomp)
  puts quiz(e.chomp)
end
