require 'roo'
require 'csv'
raw = Roo::Spreadsheet.open('./ratings_data.xlsx')
cells = []
raw.each() do |cell|
    cells.push(cell.inspect)
end
def extract_name_and_rating(c)
    regexp_companyname = /(\w+)\]*?[-|\s|]*(?=A|B|C|D|M)/
    regexp_4 = /(\w+)\]*?[-|\s|]*(?=A|B|C|D|M)((MAAA|MAA\+|MAA-|A{3}\+|A{3}-|B{3}\+|B{3}-)(\s)?(\(.*\))?)?/
    regexp_3 = /(\w+)\]*?[-|\s|]*(?=A|B|C|D|M)((MAA|A{3}|B{3}|MB\+|MB-|BB\+|BB-|AA\+|AA-|MA\+|MA-|MD\+|MD-|MC\+|MC-|A1\+|A1-|A2\+|A2-|A3\+|A3-|A4\+|A4-)(\s)?(\(.*\))?)?/
    regexp_2a = /(\w+)\]*?[-|\s|]*(?=A|B|C|D|M)((MB|BB|AA|MA|MD|MC|A\+|A-|B\+|B-|C\+|C-|D\+|D-)(\s)?(\(.*\))?)?/
    regexp_2b = /(\w+)\]*?[-|\s|]*(?=A|B|C|D|M)((A1|A2|A3|A4)(\s)?(\(.*\))?)?/
    regexp_1 = /(\w+)\]*?[-|\s|]*(?=A|B|C|D|M)((A|B|C|D)(\s)?(\(.*\))?)?/
    name = ""
    rating = ""
    begin
        name = regexp_companyname.match(c).captures[0]
    rescue => exception
        puts c + " was defective"
        return c, "none"
    else
        name = regexp_companyname.match(c).captures[0]
    end
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
    return name, rating
end
# puts cells[0].class
# puts cells[45]
# puts cells[45].class

=begin 
cells.each() do |cell|
    regexp(cell.class)
end
all are strings with [] surroundings
=end

# splice first 2 and last two characters of each string

cells.each_with_index do |cell, index|
    cell = cell[2...-2]
    cells[index] = cell
end
data_final = []
cells.each do |cell|
    data_final.push(extract_name_and_rating(cell))
end
# data now form of Rating Organization delimiter Rating, now hv to identify different types/format of delimiters
# data_final.each do |company_rating|
#     puts company_rating[0] + ": " + company_rating[1]
# end
print "Enter name of output file: "
filename = gets.chomp()
filename += ".csv"
# File.write("final.csv", rows.map(&:to_csv).join)
CSV.open(filename, "w") do |csv|
    csv << ["Company", "Rating"]
    data_final.each do |data|
      csv << data
    end
end