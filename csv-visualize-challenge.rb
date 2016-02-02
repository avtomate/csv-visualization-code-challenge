require 'csv'
require 'gchart'

#figure out number of columns so we know how many times to iterate later; get column names
numberOfColumns = nil
col_names = []
#ensure the following line's argument string matches the csv's file name
CSV.foreach("data.csv") do |row|
  numberOfColumns = row.length
  row.each { |var| col_names << var }
  break
end

#find daily avg when passed array
def find_avg(vals)
  sum = 0
  vals.each { |n| sum += n }
  (sum / vals.length).round(2)
end

(col_names.length-1).times do |n|
  data = []
  day_vals = []
  current_day = nil
  CSV.foreach("data.csv", headers: true) do |row|
    #skip if empty row
    next if row.length == 0

    #check if new day has begun; shovel day avg into data if we've started a new day
    if row[0][8,2] != current_day
      #skip the data shovel if we've just begun and day_vals is empty
      data << find_avg(day_vals) unless day_vals.empty?
      day_vals = []
      current_day = row[0][8,2]
    end
    day_vals << row[n+1].to_f
  end

  axis_label_string = ""
  15.times { |n| axis_label_string << "#{n*2+1}"; break if n == 14; axis_label_string << "|" }
  chart = Gchart.new(
              :type => 'line',
              :size => '540x540',
              :title => "#{col_names[n+1]} Over Time",
              :bg => 'efefef',
              :legend => "#{col_names[n+1]}",
              :axis_with_labels => ['x', 'y'],
              :axis_labels => [[axis_label_string], ["#{col_names[n+1]}"]],
              :axis_range => [nil, [data.min, data.max, ((data.max-data.min)/5).round(4)]],
              :max_value => data.max,
              :min_value => data.min,
              :data => data,
              :filename => "data-#{col_names[n+1].downcase.split(' ').join('-')}.png")
  chart.file
end
