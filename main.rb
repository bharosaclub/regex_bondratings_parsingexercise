require 'roo'
require 'csv'
#access spreadsheet, need to have name of file
raw = Roo::Spreadsheet.open('./ratings_data.xlsx')

#create empty array "cells" to store data
cells = []

#extract the string from each cell from raw data(cell.inspect accesses the strings in array)
raw.each() do |cell|
    cells.push(cell.inspect)
end
def extract_name_and_rating(c)
    #\w+ accesses all characters until the last occurence of A,B,C,D,M(all possible rating prefixes)
    #positive lookahead ?= finds until A or B or C or D or M but does not include
    #\]* and [-|\s|]? access and exclude common delimiters such as ] and \s(whitespace) and - (hypen), allowing company name ONLY to be grouped
    regexp_companyname = /(\w+)\]*?[-|\s|]*(?=A|B|C|D|M)/

    #          FOUR REGULAR EXPRESSIONS, EACH FOLLOW SAME TEMPLATE

    # FIRST HALF UPTIL (?=A|B|C|D|M) MATCHES COMPANY NAME FROM EARLIER

    #SECOND HALF IS USED TO CAPTURE THE RATING ITSELF IN A GROUP
    #BRACKET STRUCTURE 
    #((company name checker)(lookaheads to bypass whitespace/delimiters)(all possible ratings of x character length separated by | "or" operator, quantifiers used to shorten length {3})(get items in brackets[optional]))
    #the regex (\s)?(\(.*\))?)?  is used to find what is in brackets: optional whitespace \s, ( \( \) ) to escape brackets, .* to get characters inside brackets
    #this ^ regex can be removed to exclude brackets from match
    regexp_4 = /(\w+)\]*?[-|\s|]*(?=A|B|C|D|M)((MAAA|MAA\+|MAA-|A{3}\+|A{3}-|B{3}\+|B{3}-)(\s)?(\(.*\))?)?/
    regexp_3 = /(\w+)\]*?[-|\s|]*(?=A|B|C|D|M)((MAA|A{3}|B{3}|MB\+|MB-|BB\+|BB-|AA\+|AA-|MA\+|MA-|MD\+|MD-|MC\+|MC-|A1\+|A1-|A2\+|A2-|A3\+|A3-|A4\+|A4-)(\s)?(\(.*\))?)?/
    regexp_2a = /(\w+)\]*?[-|\s|]*(?=A|B|C|D|M)((MB|BB|AA|MA|MD|MC|A\+|A-|B\+|B-|C\+|C-|D\+|D-)(\s)?(\(.*\))?)?/
    regexp_2b = /(\w+)\]*?[-|\s|]*(?=A|B|C|D|M)((A1|A2|A3|A4)(\s)?(\(.*\))?)?/
    regexp_1 = /(\w+)\]*?[-|\s|]*(?=A|B|C|D|M)((A|B|C|D)(\s)?(\(.*\))?)?/
    #separated into four reguler expressions so that for rating AAA, regex does not ony match "AA" as it checks the four character long ratings first
    
    #variables initiliazed for function output data
    name = ""
    rating = ""

    #determines whether there is a valid company rating pair or not by escaping the "no match found" exception
    begin
        name = regexp_companyname.match(c).captures[0]
    rescue => exception
        puts c + " was defective"
        return c, "none"
    else
        name = regexp_companyname.match(c).captures[0]
    end

    #checks from longest rating character length to lowest rating character length to ensure correct rating is extracted
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
        #via testing this exception has been unreachable, only spikes if string bypasses initial test using "rescue" parameter above and has no valid rating
        puts "sm went wrong"
    end

    #return the extracted data
    return name, rating
end

#fixed pattern with roo had fixed first two and last two characters in string, so loop through each item in data array and remove
#each_with_index to avoid creating new array
cells.each_with_index do |cell, index|
    cell = cell[2...-2]
    cells[index] = cell
end

#create final array to be exported into any file format
data_final = []

#iterates through data and pushes the extracted name rating pair for every company to final output array
#simple validation to not push invalid companies can be added easily too by control flow of what the function returns
cells.each do |cell|
    data_final.push(extract_name_and_rating(cell))
end

# command line integration for testing
print "Enter name of output file: "

#ruby adds \n after every input
filename = gets.chomp()
filename += ".csv"

#using CSV library in ruby, define headings, uses filename and writes every data cell in data to csv format
CSV.open(filename, "w") do |csv|
    csv << ["Company", "Rating"]
    data_final.each do |data|
      csv << data
    end
end