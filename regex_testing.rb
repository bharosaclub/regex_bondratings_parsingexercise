# case_1 = "[ICRA]AAA"
# case_2 = "[ICRA] BB"
# c= "BRICKWORK A1"
=begin
bond rating list
/(parameters to single out company name)\.?(parameters to single out bond rating)/

=end 
# regexp = /(\[?\w+\]?)/
# regexp = /\[?(.+(?=.+A+))\]?/
# regexp = /(.+(?= A1\+))/
# regexp = /(^\[?.+\]?)/ captures both [] and non [] bond rating commitees
# regexp = /(^\[?.+\]?)/
# regexp = /^(.*?)[AAB]/
# regexp = /(.+)(?=A1\+|B)/
# regexp = /\[?(\w.+)(?=A1\+|BB|AAA)/
# regexp = /\[?(\w.+)(?=AAA|AA\+|AA|AA−|A\+|A|A−|BBB\+|BBB|BBB−|BB\+|BB|BB−|B\+|B|B-|CCC|CC|C|D|SD|NR).+(AAA|AA\+|AA|AA−|A\+|A|A−|BBB\+|BBB|BBB−|BB\+|BB|BB−|B\+|B|B-|CCC|CC|C|D|SD|NR)/
# regexp = /(.+)(?=A1\+|A)((A1\+|A)(\(.*\))?)/
# regexp = /(.+)(?=A|B|C)/
# regexp = /(.+)(?=A(-)?(\+)?(A)?(A\+)?(A-)?(AAA)?)/
# regexp = /(.+(?=AAA(-)(\+)?|BBB|CCC|DDD))(AAA(-)?|BBB|CCC|DDD)/
# regexp = /(.+(?=AAA(-)?(\+)?|BBB|CCC|DDD))(AAA(-)?|BBB|CCC|DDD)/
# regexp = /(\w+)\]?[-|\s|]*(?=AAA)/ 
#CAPTURES WORD PART OF COMPANY ONLY
# have to either make layered regex starting from longest ratings and working downwards or find a way to include into one
regexp_companyname = /(\w+)\]*?[-|\s|]*(?=A|B|C|D|M)/
regexp_4 = /(\w+)\]*?[-|\s|]*(?=A|B|C|D|M)((MAAA|MAA\+|MAA-|A{3}\+|A{3}-|B{3}\+|B{3}-)(\s)?(\(.*\))?)?/
regexp_3 = /(\w+)\]*?[-|\s|]*(?=A|B|C|D|M)((MAA|A{3}|B{3}|MB\+|MB-|BB\+|BB-|AA\+|AA-|MA\+|MA-|MD\+|MD-|MC\+|MC-|A1\+|A1-|A2\+|A2-|A3\+|A3-|A4\+|A4-)(\s)?(\(.*\))?)?/
regexp_2a = /(\w+)\]*?[-|\s|]*(?=A|B|C|D|M)((MB|BB|AA|MA|MD|MC|A\+|A-|B\+|B-|C\+|C-|D\+|D-)(\s)?(\(.*\))?)?/
regexp_2b = /(\w+)\]*?[-|\s|]*(?=A|B|C|D|M)((A1|A2|A3|A4)(\s)?(\(.*\))?)?/
regexp_1 = /(\w+)\]*?[-|\s|]*(?=A|B|C|D|M)((A|B|C|D)(\s)?(\(.*\))?)?/
#CAPTURES AS MANY SQUARE BRACKETS AS IT NEEDS TO, BUT IF RATING IS DIRECTLY NEXT TO COMPANY NAME WITH NULL DELIMITER IT MALFUNCTIONS
#HAVE TO PREPROCESS REMOVAL OF NON RATING ONES

print "Enter test company name / rating pair: "
c = gets.chomp()
name = regexp_companyname.match(c).captures[0]
if regexp_4.match(c).captures[1] != nil
    rating = regexp_4.match(c).captures[1]
elsif regexp_3.match(c).captures[1] != nil
    rating = regexp_3.match(c).captures[1]
elsif regexp_2a.match(c).captures[1] != nil
    rating = regexp_2a.match(c).captures[1]
elsif regexp_2b.match(c).captures[1] != nil
    rating = regexp_2b.match(c).captures[1]
elsif regexp_1.match(c).captures[1] != nil
    rating = regexp_1.match(c).captures[1]
else
    puts "sm went wrong"
end
print "Company name: "
print name
puts "\n"
print "Company bond rating: "
print rating
# GETTING THE COMPANY NAME
# its either surrounded by [] or not
# its delimited to the rating by "-", "", " " or a combination of all three
# its at the beginning of the string
