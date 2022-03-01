#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'

$white_list = %w[.m .mm .swift]

def cc_puts msg
  puts '<==== Code Coverage Log ===>'
  puts msg
  puts '<==========================>'
end

def create_diff_json(diff_file, file_map)
  diff_file_dir = File.dirname(diff_file)
  diff_file_name = File.basename(diff_file, '.*')
  diff_json_file = File.new("#{diff_file_dir}/#{diff_file_name}.json", 'w+')
  diff_json_file.syswrite(file_map.to_json)
end

def code_diff_map(diff_file)
  file_map = {}
  current_file = nil
  white_list_file = false

  File.open(diff_file).each do |line|
    # 只需要获取白文件中的修改即可
    if line.start_with? 'diff --git'
      extname = File.extname(line).chomp!
      white_list_file = $white_list.include?(extname)
      next
    end

    next if white_list_file == false

    if line.start_with? '+++'
      # 提取文件路径
      file_path = line[/\/.*/, 0][1..-1]
      if file_path
        current_file = file_path
        file_map[current_file] = []
      end
    end

    next unless line.start_with? '@@'

    # 提取新增代码行，格式为 “+66,5”
    change = line[/\+.*?\s{1}/, 0]
    # 消除“+”
    change = change[1..-1]
    # flat
    if change.include? ','
      base_line = change.split(',')[0].to_i
      delta = change.split(',')[1].to_i
      delta.times { |i| file_map[current_file].push(base_line + i) if current_file}
    else
      file_map[current_file].push(change.to_i) if current_file
    end
  end

  file_map
end

def diff_based_coverage_info(coverage_info_file, file_map)
  is_diff_file = false
  diff_file_lines = []
  coverage_info_dir = File.dirname(coverage_info_file)
  coverage_file_name = File.basename(coverage_info_file, '.*')
  diff_coverage_info_file_path = "#{coverage_info_dir}/#{coverage_file_name}_diff.info"
  cc_puts "diff info path: #{diff_coverage_info_file_path}"
  
  diff_coverage_info_file = File.new(diff_coverage_info_file_path, 'w+')
  File.open(coverage_info_file).each do |line|
    # 代码覆盖率info的文件开头标识以开头
    if line.start_with? 'SF:'
      is_diff_file = false
      basename = File.basename(line).chomp!
      # puts "basename:#{basename}"
      file_map.each_key do |key|
        next unless key.include?(basename)

        is_diff_file = true
        diff_file_lines = file_map[key]
        diff_coverage_info_file.syswrite(line)
        # puts "is_diff_file:#{is_diff_file}"
        # puts "diff_file_lines:#{diff_file_lines}"
        next
      end
    end

    next if is_diff_file == false

    # 该类中的每一行信息的标识
    # DA:20,1
    if line.start_with? 'DA:'
      line_number = line.split('DA:')[1]
      real_line = line_number.split(',')[0].to_i
      # puts "diff_file_lines:#{diff_file_lines}"
      # puts "real_line: #{real_line}"
      diff_coverage_info_file.syswrite(line) if diff_file_lines.include?(real_line)
    else
      diff_coverage_info_file.syswrite(line)
    end
  end

  diff_coverage_info_file
end

def diff_parser(diff_file, coverage_info_file)
  file_map = code_diff_map(diff_file)
  return false if file_map.empty?

  create_diff_json(diff_file, file_map)
  diff_based_coverage_info(coverage_info_file, file_map)
  true
end
