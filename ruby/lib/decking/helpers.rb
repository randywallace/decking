require "ruby-progressbar"

module Kernel
  def with_progress(title, &block)
    import = fork(&block)

    progress = fork do
      progressbar = ProgressBar.create(title: title, total: nil)

      trap "INT" do
        progressbar.total = 100
        progressbar.finish
        exit
      end

      loop do
        progressbar.increment
        sleep 0.5
      end
    end

    Process.wait(import)
    Process.kill(2, progress)
  end
end
