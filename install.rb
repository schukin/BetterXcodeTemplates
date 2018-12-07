require 'highline/import'
require 'fileutils'

# This is an array because you may have more than one instance
# of Xcode installed. Add additional paths to this array
DEST_PATHS = ['/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/Library/Xcode']
SRC_PATH = 'Templates' # The top-level directory in this repo

class CopyJob
	attr_accessor :source_file_path
	attr_accessor :dest_file_path
end

files_to_copy = Dir.glob("#{SRC_PATH}/**/*.swift")
copy_jobs = []

puts "Copying the following files:\n\n"

files_to_copy.each do |file|
	puts "• #{file}"

	DEST_PATHS.each do |dest_path|
		full_dest_path = File.join(dest_path, file)

		unless File.file?(full_dest_path)
			puts "\n\n⚠️  Destination path does not exist: #{full_dest_path}\n\n"
			raise "Unable to find one or more files in Xcode target path. Bailing"
		end

		copy_job = CopyJob.new
		copy_job.source_file_path = file
		copy_job.dest_file_path = full_dest_path
		copy_jobs << copy_job
	end
end

exit unless HighLine.agree("\nCopy #{copy_jobs.count} files? y/n")

begin
	copy_jobs.each do |copy_job|	
		FileUtils.cp(copy_job.source_file_path, copy_job.dest_file_path)
	end
rescue Errno::EACCES
	puts "\n\n⚠️  Error: insufficient permissions. Try running with `sudo`\n\n"
	exit
end

puts "✅  Copied #{copy_jobs.count} files."
