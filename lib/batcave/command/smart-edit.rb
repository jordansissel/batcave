require "clamp"
require "batcave/namespace"
require "stud/temporary"

class BatCave::Command::SmartEdit < Clamp::Command
  def execute
    rspec_failure = /^ *Failure\/Error/
    rspec_stack_trace = /^ *# (?<path>[^:]+):(?<line>[0-9]+):/
    text = capture_tmux
    if text =~ rspec_failure
      lines = text.split("\n")
      # first failure/error
      index = lines.find_index { |l| l =~ rspec_failure }
      # then find all lines that look like stack traces.
      traces = []
      last_line = index
      lines[index..-1].each_with_index do |line, i| 
        m = rspec_stack_trace.match(line)
        if m
          traces << Hash[m.names.zip(m.captures)]
        elsif traces.count > 0 && line =~ /^ *$/
          # already found traces, and a blank line means the end of the trace.
          last_line = i
          break
        end
      end

      if traces.any?
        # Find the most-recently modified file.
        candidate = traces.sort_by { |t| File.stat(t["path"]).mtime }.reverse.first
        Stud::Temporary.file do |fd|
          lines[index .. last_line + index].each do |line|
            fd.puts(line)
          end
          fd.flush

          system("tmux split-window -l 7 'cat #{fd.path}; sleep 3000 ' \\; last-pane")
          system("#{ENV["EDITOR"]} #{candidate["path"]} +#{candidate["line"]}")
          system("tmux last-pane \\; kill-pane")
        end
      end
    end

    return 0
  end

  def tmux?
    return ENV["TMUX"]
  end

  def screen?
    return ENV["STY"]
  end

  def capture_tmux
    Stud::Temporary.file do |fd|
      # Capture the current screen plus 50 lines of history
      system("tmux capture-pane -S -50")
      system("tmux save-buffer -b 0 #{fd.path}")
      return fd.read
    end
  end
end
