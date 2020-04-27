# def map(item)
#   "( " + item + " )"
# end

def map(item)
  %!<img src="google-img--#{item}.jpg">!
end

ARGF.each do |e|
  puts map(e.chomp)
end
