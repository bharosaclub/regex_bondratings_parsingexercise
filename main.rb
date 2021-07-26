require 'roo'
raw = Roo::Spreadsheet.open('./ratings_data.xlsx')
print raw.row(1)
cells = []
raw.each() do |cell|
    cells.push(cell.inspect)
    # => { id: 1, name: 'John Smith' }
end

def regexp(data)
    puts data
end

# puts cells

=begin 
cells.each() do |cell|
    regexp(cell.class)
end
all are strings with [] surroundings
=end