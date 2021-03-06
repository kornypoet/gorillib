# -*- ruby -*-

def run_spec(file)
  unless File.exist?(file)
    puts "#{file} does not exist"
    return
  end

  puts   "Running #{file}"
  system "bundle exec rspec #{file}"
  puts
end

watch("spec/.*/*_spec\.rb") do |match|
  run_spec match[0]
end

watch("lib/gorillib/(.*)\.rb") do |match|
  Dir[%{spec/#{match[1]}*_spec.rb}].each do |f|
    run_spec f
  end
end
