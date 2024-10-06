#!/usr/bin/ruby

# write pixel art in the 'Contributions' panel of github
# 52x7, tiled horizontal

# PATCHME c===8  

word = <<EOS
        6  3         
           3         
331 131 3  3         
3 3 3 3 3  3         
331 131 13 13        
3                    
3                    
EOS

start_date = Time.mktime(Time.now.year-1, 1, 1, 10, 0, 0)
start_date += 24*3600 until start_date.wday == 0

Dir.chdir(File.dirname(__FILE__))
me = File.basename(__FILE__)

if not File.directory?('.git')
	# create history from start_date
	system 'git', 'init'
	system 'git', 'add', '.'
	commit_date = start_date + 3600 + rand(3600)
else
	# add new patches to existing history
	raise 'nope' unless `git log --format='%ci' -n 1` =~ /(\d+)-(\d+)-(\d+) (\d+):(\d+):(\d+)/
	commit_date = Time.mktime($1, $2, $3, $4, $5, $6)

	# commits at ~12:00 to avoid GMT etc issues
	if commit_date.hour <= 10
		commit_date += (12-commit_date.hour)*3600
	else
		commit_date += (36-commit_date.hour)*3600
	end
end

now = Time.now
pixels = word.split(/\n/)
nr_weeks = pixels.map { |l| l.length }.max

patch_off = nil
while commit_date < now
	col = ((commit_date - start_date) / (7*24*3600)) % nr_weeks
	row = commit_date.wday

	if pixels[row][col, 1] =~ /[0-9a-f]/i
		pixels[row][col, 1].to_i(16).times {
			# change current file
			File.open(me, 'rb+') { |fd|
				patch_off ||= fd.read.index('PATCHME ') + 8
				fd.pos = patch_off
				if fd.read(1) == 'c'
					fd.pos = patch_off
					fd.write(' c===8')
				else
					fd.pos = patch_off
					fd.write('c===8 ')
				end
			}
			# commit to date
			commit_date_fmt = commit_date.strftime('%Y-%m-%dT%H:%M:%S')
			puts commit_date_fmt
			system 'git', 'commit', '-q', '-m', 'moo', '--date', commit_date_fmt, '.'
		}
	end

	commit_date += 24*3600 + rand(41) - 20
end

system 'git', 'gc', '-q'
