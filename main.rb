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

def extract_name_and_rating(raw_string)  
  # First we note that in the sample data two ratings are sometimes clubbed together and separated 
  # by a "/". Theoretically, it is possible that we may even have a situation where we have three ratings
  # for one entry. So we will always return a collectoin of results per row. Usually this will be just one entry, but sometimes maybe not
  
  # Declare the return arrays 
  successes = []
  failures = []

  # Next we split the raw_string by any "/"
  raw_strings = raw_string.split("/")

  # We further recognize that the agency names have only a finite set of possible values...let's store these 
  # And also it seems like there are multiple variantions for a single agency...let's map these to a single agency name
  # That's consistent for us

  # We group agency tags in two categories...first those that are specific enough that we are confident that if they occur
  # anywhere in the string they are guaranteed to represent the agency name 
  agency_mappings_specific = { 
    "ACUITE" => "ACUITE", 
    "BRICKWORK" => "BRICKWORK", 
    "BRICKWORKS" => "BRICKWORKS",
    "BWR" => "BRICKWORK",
    "CRISIL" => "CRISIL",
    "FITCH"=> "FITCH",
    "ICRA" => "ICRA"
  }

  # And second those that are not specific enough, where we want to be a little more careful
  agency_mappings_generic = { 
    "IND" => "IND", 
    "FIT" => "FITCH",
    "CARE" => "CARE"
  }

  # Since we only have a handful of agency names, we are going to employ a direct match on these agency strings v.s. try to 
  # identify an agency based on a generic pattern matching. This has the advantage of ensuring quality agnecy mappings. 
  # For example, if there is a typo in the data, and we have an agency mapping name of "ICMA" we don't want the regex to 
  # Store that as a new agency. WE know there isn't an agency called ICMA. We'd rather have this flagged for manual review

  # Let's create a regex expression to match these potential agency keywords. I want these matches to occur in a very 
  # specific order...i.e., i want BRICKWORKS to be matched before BRICKWORK...so I do a reverse alphabetical stort.

  regex_agency_specific = agency_mappings_specific.keys.sort.reverse
  # True gives me case insensitivity
  regex_agency_specific = Regexp.new(regex_agency_specific.join('|'), true)  

  # Let's create the regex for generic names...here since I'm not so confident I want to stay case sensitive to upper case
  regex_agency_generic = agency_mappings_generic.keys
  regex_agency_generic = regex_agency_generic.join('|')
  # This regex is going to be case sensitive and include a boundary condition - which we didn't have in the specific version
  regex_agency_generic = /#{regex_agency_generic}\b/

  # Now let's parse for every member of our raw array
  raw_strings.each do |raw_string|
    # First let's try to identify the agency 
    agency = regex_agency_specific.match(raw_string)
    # If we matched no need to do anything else...else try generic matchers
    agency ||= regex_agency_generic.match(raw_string)
    #If we don't have a matched agency, log as a failure and move on
    if agency.nil?
      failures << raw_string
      next 
    end
    # Now we need to lookup the right agency name that we use internally
    bharosa_agency = agency_mappings_specific[agency[0].upcase]
    bharosa_agency ||= agency_mappings_generic[agency[0]]

    # Okay, now we try to extract the rating 
    # First let's strip out the agency from our raw string
    raw_string_adjusted = raw_string.gsub(agency[0],"") 

    # Now we want our rating to be either at the beginning of the adjusted string or preceded by a word boundary and followed by a word 
    # boundary or end of string or space so we don't pick up a random "A" that's not actually a rating
    rating_regex = /(?:^|\b|\s)(AAA)|(?:A{1,2}|B{1,3}|C{1,3}|D)[-+]?(?:\b|\s|$)/ 
    #Now the alternate rating format
    rating_regex_alt = /(?:^|\b|\s)(?:A|B|C)[1-3][-+]?(?:\b|\s|$)/ 

    rating = rating_regex.match(raw_string_adjusted)
    rating ||= rating_regex_alt.match(raw_string_adjusted)

    if rating.nil? 
      failures << raw_string
      next
    end
    bharosa_rating = rating[0].strip
    successes << [bharosa_agency, bharosa_rating, raw_string]
  end
  return successes, failures
end

#fixed pattern with roo had fixed first two and last two characters in string, so loop through each item in data array and remove
#each_with_index to avoid creating new array
cells.each_with_index do |cell, index|
  cell = cell[2...-2]
  cells[index] = cell
end

#create final array to be exported into any file format
successes = []
failures = []


#iterates through data and pushes the extracted name rating pair for every company to final output array
#simple validation to not push invalid companies can be added easily too by control flow of what the function returns
cells.each do |cell|
  success = []
  failure = []
  success, failure = extract_name_and_rating(cell)
  successes += success
  failures += failure
end

# command line integration for testing
print "Enter name of output file: "

#ruby adds \n after every input
filename = gets.chomp()
filename += ".csv"

#using CSV library in ruby, define headings, uses filename and writes every data cell in data to csv format
CSV.open(filename, "w") do |csv|
  csv << ["Company", "Rating", "Raw String"]
  successes.each do |data|
    csv << data
  end
  csv << ["**********Failures*************"]
  failures.each do |data|
    csv << [data, "", ""]
  end
end
