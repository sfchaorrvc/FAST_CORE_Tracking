task :bamboo do
  Rake::Task["db:reset"].invoke
  Rake::Task["ci:setup:testunit"].invoke
  Rake::Task["test:test:rcov"].invoke


  begin
    copy_to_success_tag(ENV['CC_BUILD_REVISION'])
  rescue Exception => e
    puts "unable to tag in SVN"
    puts $!
    puts e.backtrace[1..-1]
  end

end

def copy_to_success_tag(rev)
  puts "tagging revision #{rev} as successful build in SVN"
  dst = get_svn_base + "/tags/successful_build_" + get_current_revision_datetime
  cmd = "svn copy -r #{rev} #{get_repo_url} #{dst} -m 'successful build'"
  puts cmd
  puts `#{cmd}`
end

def get_svn_base
  puts "getting SVN base"
  repo_url = get_repo_url
  puts repo_url
  last_slash = repo_url.rindex('/')
  repo_url[0, last_slash]
end

def get_current_revision_datetime
  puts "getting revision datetime"
  svn_info = `svn info`
  svn_info.each_line do |line|
    if (line.include?("Last Changed Date:"))
      line.slice!("Last Changed Date:")
      line.slice!(/\(.*\)/)
      datetime = line[0, line.rindex(/[+-]/)]
      datetime.delete!(" :-")
      return datetime.strip
    end
  end
end

def get_repo_url
  puts "getting SVN URL"
  svn_info = `svn info`
  puts svn_info
  svn_info.each_line do |line|
    if (line.include?("URL:"))
      line.slice!("URL:")
      return line.strip!
    end
  end
end
