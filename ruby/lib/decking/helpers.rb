require "thread"
require "ruby-progressbar"

module Decking
  module Helpers
    extend self

    CONSOLE_LENGTH=80

    def run_with_progress(title, &block)
      command  = Thread.new(&block).tap{ |t| t.abort_on_exception = true}

      progress = Thread.new do
        opts = { title: title, 
                 total: nil, 
                 length: CONSOLE_LENGTH, 
                 format: '%t%B', 
                 progress_mark: ' ', 
                 unknown_progress_animation_steps: ['..  .', '...  ', ' ... ', '  ...', '.  ..'] }
        progressbar = ProgressBar.create opts

        begin
          loop do
            progressbar.increment
            sleep 0.5
          end
        rescue RuntimeError => e
          unless e.message == 'Shutdown'
            raise RuntimeError e
          else
            progressbar.total = 100
            progressbar.format '%t ' + "\u2713".green
            progressbar.finish
          end
        end
      end.tap {|t| t.abort_on_exception = true }

      command.join
      progress.raise 'Shutdown'
      progress.join
      finished = true
    rescue Interrupt 
      clear_progressline
      puts "I know you did't mean to do that... try again if you really do".yellow
    rescue Exception => e
      clear_progressline
      puts e.class
      puts e.message
      puts e.backtrace.inspect
      exit
    ensure
      begin
        unless finished
          command.join
          progress.raise 'Shutdown'
          progress.join
        end
      rescue Interrupt
        puts "Caught second interrupt, exiting...".red
        exit
      rescue SystemExit
        puts "Caught SystemExit. Exiting...".red
        exit
      end
    end

    def run_with_threads_multiplexed method, containers
      clear_progressline
      threads = Array.new 
      containers.map do |name, container|
        threads << Thread.new do
          container.method(method).call
        end
      end
      threads.map { |thread| thread.join }
    rescue Interrupt
      threads.map { |thread| thread.kill }
    end

    def clear_progressline
      $stdout.print " " * CONSOLE_LENGTH + "\r"
      #$stdout.print "\n"
    end
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
