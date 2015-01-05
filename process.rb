require "fileutils"

process_path = ARGV.first

unless File.exists?(process_path)
  puts "Error: path does not exist (#{process_path})"
  exit
end

def is_thumb?(path)
  path.include?('/Thumbnail') || path.include?('/Preview')
end

desired_exts = ['.CR2', '.JPG', '.PNG', '.NEF', '.PSD', '.TIFF', '.MTS', '.RW2', '.MOV', '.DNG']

files = Dir.glob(File.join(process_path, "**/*")).select { |f|
  desired_exts.include?(File.extname(f).upcase)
}

puts "Found #{files.count} files"

skipped = []
files.each do |file|
  last_mod_date = File.mtime(file)
  start_dir = is_thumb?(file) ? './processed/thumbs' : './processed/photos'
  photo_dir = File.join(last_mod_date.year.to_s, last_mod_date.month.to_s.rjust(2, "0"), last_mod_date.day.to_s.rjust(2, "0"))
  processed_dir = File.join(start_dir, photo_dir)
  processed_path = File.join(processed_dir, File.basename(file))

  if File.exists?(processed_path)
    skipped << process_path
    print 'x'
    next
  end

  FileUtils.mkdir_p(processed_dir)
  begin
    FileUtils.cp(file, processed_path)
    print '.'
  rescue Errno::EISDIR
  end
end

puts
puts "Skipped #{skipped.count}"
