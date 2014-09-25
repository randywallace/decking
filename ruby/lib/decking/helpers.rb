require "thread"
require "ruby-progressbar"

module Decking
  extend self

  CONSOLE_LENGTH=80

  def run_with_progress(title, &block)
    command  = Thread.new(&block)

    progress = Thread.new do
      progressbar = ProgressBar.create title: title, 
                                       total: nil, 
                                       length: Decking::CONSOLE_LENGTH, 
                                       format: '%t%B', 
                                       progress_mark: ' ', 
                                       unknown_progress_animation_steps: ['..  .', '...  ', ' ... ', '  ...', '.  ..']

      begin
        loop do
          progressbar.increment
          sleep 0.5
        end
      rescue RuntimeError => e
        if e.message == 'Shutdown'
          progressbar.total = 100
          progressbar.format '%t ' + "\u2713".green
          progressbar.finish
        end
      rescue Exception => e
        puts e.class
        puts e.message
        puts e.backtrace.inspect
      end
    end

    command.join
    progress.raise 'Shutdown'
    progress.join
  end

  def clear_progressline
    $stdout.print " " * CONSOLE_LENGTH + "\r"
  end

end

class String
  def black;          "\033[30m#{self}\033[0m" end
  def red;            "\033[31m#{self}\033[0m" end
  def green;          "\033[32m#{self}\033[0m" end
  def brown;          "\033[33m#{self}\033[0m" end
  def blue;           "\033[34m#{self}\033[0m" end
  def magenta;        "\033[35m#{self}\033[0m" end
  def cyan;           "\033[36m#{self}\033[0m" end
  def gray;           "\033[37m#{self}\033[0m" end
  def bg_black;       "\033[40m#{self}\033[0m" end
  def bg_red;         "\033[41m#{self}\033[0m" end
  def bg_green;       "\033[42m#{self}\033[0m" end
  def bg_brown;       "\033[43m#{self}\033[0m" end
  def bg_blue;        "\033[44m#{self}\033[0m" end
  def bg_magenta;     "\033[45m#{self}\033[0m" end
  def bg_cyan;        "\033[46m#{self}\033[0m" end
  def bg_gray;        "\033[47m#{self}\033[0m" end
  def bold;           "\033[1m#{self}\033[22m" end
  def reverse_color;  "\033[7m#{self}\033[27m" end
end
