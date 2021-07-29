print "enter phone number: "
str_to_check = gets
=begin
format = 123.456.7890 or 123,456,7890 or 123 456 7890 or 123-456-7890
=end
regexp = /\d\d\d.\d\d\d.\d\d\d\d/
regexp =~ str_to_check ? begin p "valid number" end : begin p "invalid number" end