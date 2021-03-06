require 'rbconfig'
require 'fattr'

#=Terminator
#
#==Synopsis
#
#An external timeout mechanism based on processes and signals.  Safe for 
#system calls.  Safe for minors.  but not very safe for misbehaving, 
#downtrodden zombied out processes.
#
#==Description
#
#Terminator is a solution to the problem of 'how am I meant to kill a
#system call in Ruby!?'
#
#Ruby (at least MRI) uses green threads to "multitask".  This means that
#there is really only ever one ruby process running which then splits up
#it's processor time between all of it's threads internally.
#
#The processor then only has to deal with one ruby process and the ruby 
#process deals with all it's threads.  There are pros and cons to this
#method, but that is not the point of this library.
#
#The point is, that if you make a system call to an external resource from
#ruby, then the kernel will go and make that call for ruby and NOT COME BACK
#to ruby until that system call completes or fails.  This can take a very 
#long time and is why your feeble attempts at using ruby's internal "Timeout"
#command has failed miserably at timing out your external web service, database
#or network connections.
#
#You see, Ruby just doesn't get a chance to do anything as the kernel goes
#"I'm not going to talk to you again until your system calls complete". Sort
#of a no win situation for Ruby.
#
#That's where Terminator comes in.  Like Arnie, he will come back.  No matter
#what, and complete his mission, unless he gets aborted before his timeout,
#you can trust Terminator to thoroughly and without remorse, nuke your 
#misbehaving and timing out ruby processes efficiently, and quickly.
#
#==How it Works
#
#Basically we create a new terminator ruby process, separate to the existing
#running ruby process that has a simple command of sleep for x seconds, and then
#do a process TERM on the PID of the original ruby process that created it.
#
#If your process finishes before the timeout, it will kill the Terminator first.
#
#So really it is a race of who is going to win?
#
#Word of warning though.  Terminator is not subtle.  Don't expect it to split
#hairs.  Trying to give a process that takes about 1 second to complete, a
#2 second terminator... well... odds are 50/50 on who is going to make it.
#
#If you have a 1 second process, give it 3 seconds to complete.  Arnie doesn't
#much care for casualties of war.
#
#Another word of warning, if using Terminator inside a loop, it is possible
#to exceed your open file limit.  I have safely tested looping 1000 times
#
#==URIS
#
#* http://codeforpeople.com/lib/ruby
#* http://rubyforge.org/projects/codeforpeople
#
#==Usage
#
#The terminator library is simple to use.
#
# require 'terminator'
# Terminator.terminate(1) do
#   sleep 4
#   puts("I will never print")
# end
# #=> Terminator::Error: Timeout out after 1s
#
#The above code snippet will raise a Terminator::Error as the terminator's timeout is 
#2 seconds and the block will take at least 4 to complete.
#
#You can put error handling in with a simple begin / rescue block:
#
# require 'terminator'
# begin
#   Terminator.terminate(1) do
#     sleep 4
#     puts("I will never print")
#   end
# rescue
#   puts("I got terminated, but rescued myself.")
# end
# #=> I got terminated, but rescued myself.
#
#The standard action on termination is to raise a Terminator::Error, however, this is
#just an anonymous object that is called, so you can pass your own trap handling by
#giving the terminator a lambda as an argument.
#
# require 'terminator'
# custom_trap = lambda { eval("raise(RuntimeError, 'Oops... I failed...')") }
# Terminator.terminate(:seconds => 1, :trap => custom_trap) do
#   sleep 10
# end
# #=> RuntimeError: (eval):1:in `irb_binding': Oops... I failed...
module Terminator
  Version = "1.0.0"

  def Terminator.version
    Terminator::Version
  end

  def Terminator.description
    "an external timeout mechanism based on processes and signals"
  end

  def Terminator.license
    "same as ruby's"
  end

  def Terminator.dependencies
    {
      'fattr'             => [ 'fattr'             , ' >= 2.2'   ] ,
    }
  end

  # Terminator.terminate has two ways you can call it.  You can either just specify:
  #
  #  Terminator.terminate(seconds) { code_to_execute }
  #
  # If you want to pass in the block, please use:
  #
  #  Terminator.terminate(:seconds => seconds, :trap => block) { code_to_execute }
  #
  # Where block is an anonymous method that gets called when the timeout occurs.
  def terminate options = {}, &block
    options = { :seconds => Float(options) } unless Hash === options 

    seconds = getopt(:seconds, options)

    default_trap = lambda{ eval("raise(::Terminator::Error, 'Timeout out after #{ seconds }s')", block.binding) }
    actual_trap  = getopt(:trap, options, default_trap)
    signal_trap  = lambda{|*_| actual_trap.call()}

    previous_trap = Signal.trap(signal, &signal_trap)

    terminator_pid = plot_to_kill(pid, :in => seconds, :with => signal)

    begin
      block.call
    ensure
      nuke_terminator(terminator_pid)
      Signal.trap(signal, previous_trap)
    end
  end

  def nuke_terminator(pid)
    Process.kill("KILL", pid) rescue nil
    Process.wait(pid) rescue nil
  end

  def plot_to_kill pid, options = {}
    seconds = getopt :in, options
    signal = getopt :with, options
    send_terminator(pid, seconds)
  end

  def send_terminator(pid, seconds)
    process = IO.popen(%[#{ ruby } -e'sleep #{seconds}; Process.kill("#{signal}", #{pid}) rescue nil;'], 'w+')
    process.pid
  end

  def temp_file_name
    "terminator-#{ ppid }-#{ pid }-#{ rand }"
  end

  fattr :ruby do
    c = (defined?(::RbConfig) ? ::RbConfig : ::Config)::CONFIG
    ruby = File::join(c['bindir'], c['ruby_install_name']) << c['EXEEXT']
    raise "ruby @ #{ ruby } not executable!?" unless test(?e, ruby)
    ruby
  end

  fattr :pid do
    Process.pid
  end

  fattr :ppid do
    Process.ppid
  end

  fattr :signal do
    'TERM'
  end

  def getopt key, hash, default = nil
    return hash.fetch(key) if hash.has_key?(key)
    key = key.to_s
    return hash.fetch(key) if hash.has_key?(key)
    key = key.to_sym
    return hash.fetch(key) if hash.has_key?(key)
    default
  end

  class Error < ::StandardError; end
  def error() ::Terminator::Error end
  def version() ::Terminator::Version end

  extend self
end
