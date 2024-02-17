#!/usr/bin/env ruby

require 'fileutils'
require 'pathname'

def run(*args)
    cmd = args.map { |a| "\"#{a}\"" }.join(' ')
    puts "Running: #{cmd}"
    `#{cmd}`.tap do |output|
        raise $! if $!
    end
end

output_dir = ARGV.first

pp output_dir

raise "Must provide output_dir" if output_dir.nil? || output_dir.empty?

working_dir = Pathname.pwd
output_dir = Pathname(output_dir)
output_dir = working_dir + output_dir if output_dir.relative?

FileUtils.mkdir_p(output_dir)

puts "\nFinding .kzip files\n"
files = run('find', '-L', (working_dir + 'bazel-out').to_s, '-name', '*.kzip')
    .split("\n")
    .map { |p| Pathname(p).relative_path_from(working_dir).to_s }
puts files

puts "\nMerging .kzip files\n"
run("#{ENV['KYTHE_RELEASE']}/tools/kzip", 'merge', '--output', 'merged.kzip', *files)
puts "\nRunning cxx_indexer\n"
run("#{ENV['KYTHE_RELEASE']}/indexers/cxx_indexer", 'merged.kzip', '-o', 'entries.kythe')
puts "\n Writing tables\n"
run("#{ENV['KYTHE_RELEASE']}/tools/write_tables", '--entries', 'entries.kythe', '--out', output_dir.to_s)
