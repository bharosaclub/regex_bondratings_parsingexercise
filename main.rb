require 'roo'
raw = Roo::Spreadsheet.open('./ratings_data.xlsx')
cells = []
raw.each() do |cell|
    cells.push(cell.inspect)
    # => { id: 1, name: 'John Smith' }
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

# data now form of Company delimiter Rating, now hv to identify different types/format of delimiters
