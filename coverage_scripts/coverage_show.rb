#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative './utils/trollop'
require File.join(File.dirname(__FILE__), 'diff_parser.rb')

def cc_puts msg
  puts '<==== Code Coverage Log ===>'
  puts msg
  puts '<==========================>'
end

def check_finder
  exist = File.exist?($cc_root_path)
  cc_puts "#{$cc_root_path} not exist." unless exist

  exist
end

def git_diff_parse(git_commits, info_file_path)
  diff_file_name = git_commits.join('_')
  diff_file_name = 'default' if diff_file_name == ''
  diff_file_path = "#{$cc_git_diff_path}/#{diff_file_name}.diff"
  cc_puts("diff file: #{diff_file_path}")

  `cd #{$project_dir} && git diff #{git_commits[0]} #{git_commits[1]} --unified=0 > #{diff_file_path}`
  result = diff_parser(diff_file_path, info_file_path)

  cc_puts "#{diff_file_path} has no content" unless result
  result
end

def code_coverage_show(original_profraw, git_commits)
  # copy profraw
  `cp #{original_profraw} #{$cc_resources_path}`

  # get profraw name
  profraw_name = ''
  Dir[File.join($cc_resources_path, '*.profraw')].each do |file|
    profraw_name = File.basename(file, '.profraw')
  end

  profraw_path = "#{$cc_resources_path}/#{profraw_name}.profraw"
  profdata_path = "#{$cc_resources_path}/#{profraw_name}.profdata"

  # generate profdata file
  `xcrun llvm-profdata merge -sparse #{profraw_path} -o #{profdata_path}`

  # get Mach-O file name
  macho_path = `find #{$cc_resources_path} -name #{profraw_name}`.to_s.chomp!

  `xcrun llvm-cov show #{macho_path} -instr-profile=#{profdata_path} -use-color -format=html -output-dir=#{$cc_result_path2}`

  # generate info file
  info_path = "#{$cc_resources_path}/#{profraw_name}.info"
  `xcrun llvm-cov export #{macho_path} -instr-profile=#{profdata_path} -format=lcov > #{info_path}`

  final_info_path = git_diff_parse(git_commits, info_path) ? "#{$cc_resources_path}/#{profraw_name}_diff.info" : info_path
  `genhtml -o #{$cc_result_path1} #{final_info_path}`
  `open #{$cc_result_path1}/index.html`
end

if __FILE__ == $PROGRAM_NAME
  opts = Trollop.options do
    opt :project_dir, 'Path for project directory', type: :string
    opt :profraw_path, 'Path for profraw file', type: :string
    opt :git_diff_commit, 'git commit string, default is nil', defualt: '', type: :string
  end

  project_dir = opts[:project_dir]
  profraw_path = opts[:profraw_path]
  commit_str = opts[:git_diff_commit]
  git_commits = commit_str.nil? ? [] : commit_str.split(',')

  Trollop.die :project_dir, 'must be provided' if project_dir.nil?
  Trollop.die :profraw_path, 'must be provided' if profraw_path.nil?
  Trollop.die :git_diff_commit, 'is invalid' if git_commits.length > 2

  $scrpit_dir = File.dirname(File.expand_path(__FILE__))
  $project_dir = File.expand_path(project_dir)
  profraw_path = File.expand_path(profraw_path)

  Trollop.die :project_dir, "#{project_dir} No such file or directory" unless File.exist?($project_dir)
  Trollop.die :profraw_path, "#{profraw_path} No such file or directory" unless File.exist?(profraw_path)

  $cc_root_path = "#{$project_dir}/CodeCoverage"
  $cc_resources_path = "#{$cc_root_path}/resources"
  $cc_git_diff_path = "#{$cc_root_path}/git_diff"
  $cc_result_path1 = "#{$cc_root_path}/lcov_html"
  $cc_result_path2 = "#{$cc_root_path}/llvm_cov_html"

  code_coverage_show(profraw_path, git_commits) if check_finder
end
