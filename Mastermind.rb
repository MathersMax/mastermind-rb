COLORS = Hash[
          "R" => "red",
          "B" => "blue",
          "G" => "green",
          "C" => "cyan",
          "M" => "magenta",
          "O" => "orange"
          ]
def red(txt)      ; "\e[31m#{txt}\e[0m" ; end
def green(txt)    ; "\e[32m#{txt}\e[0m" ; end
def orange(txt)   ; "\e[33m#{txt}\e[0m" ; end
def blue(txt)     ; "\e[34m#{txt}\e[0m" ; end
def magenta(txt)  ; "\e[35m#{txt}\e[0m" ; end
def cyan(txt)     ; "\e[36m#{txt}\e[0m" ; end
def bold(txt)     ; "\e[1m#{txt}\e[22m" ; end

class Outcome
  attr_accessor :black
  attr_accessor :white
  def initialize(black:0, white:0)
    @black=black
    @white=white
  end
  def ==(otherOutcome)
    @black == otherOutcome.black && @white == otherOutcome.white
  end
end

class Mastermind
  attr_accessor :nb_attempts
  attr_accessor :guess
  attr_reader :max_attempts
  attr_reader :done
  attr_reader :allow_duplicates
  attr_reader :outcome
  attr_reader :nb_holes
  attr_reader :colors
  def initialize(nb_holes, nb_colors, allow_duplicates, max_attempts)
    # Mastermind Constructor
    # Params:
    # +nb_holes+          :: number of holes in the board (default:4)
    # +nb_colors+         :: number of available colors (default:6)
    # +allow_duplicates+  :: decide if the code could contain duplicates (default:true)
    # +max_attempts+      :: maximum number of attempts to break the code (default:10)
    @nb_holes = nb_holes
    m_nb_colors = [nb_colors, COLORS.length].min
    @colors = COLORS.first(m_nb_colors).to_h
    @allow_duplicates = allow_duplicates
    @max_attempts = max_attempts

    @selection = Array.new(@nb_holes)
    @guess = nil
    @outcome = nil
    @unused_codes = nil
  end

  def ask(code:false, first:true)
    # Aks the player for a value (his guess or the code to be broken)
    # Params:
    # +code+  :: is the function called by the code master or the code breaker?
    # +first+ :: is it the first function call? (to arrange display)
    if first
      print "Please choose #{@nb_holes} colors from:\n"
      @colors.keys.each do |c|
        eval("print #{@colors[c]}(c)")
        print "(#{@colors[c]}) "
      end
      puts "\nIn exemple, type RBGC + Enter"
    end
    begin
      input = gets.chomp.split("")
      unless (input-@colors.keys).empty? && input.length == @nb_holes
        raise "Woups, seems like you did not provide something usefull, please try again :)"
      end
    rescue Exception => e
      puts bold(e.message)
      retry
    end
    if code
      @done = false
      @nb_attempts = 0
      @selection = input
    else
      @guess = input
    end
  end

  def draw
    # The computer draw a random code
    @done = false
    @nb_attempts = 0
    if @allow_duplicates
      for i in 1..@nb_holes
        @selection[i-1]=@colors.keys.sample
      end
    else
      @selection = @colors.keys.sample(@nb_holes)
    end
  end

  def compare(guess, target)
    # Compute the comparison between 2 codes
    # Params:
    # +guess+    :: the guessed code
    # +target+   :: the comparison target
    @outcome = Outcome.new
    guess.each_with_index do |elem, index|
      if elem == target[index]
        @outcome.black += 1
      end
    end
    whiteCount = Array.new
    @colors.keys.each do |i|
      j = [guess.count(i), target.count(i)].min
      whiteCount.push(j)
    end
    @outcome.white = whiteCount.inject(0, :+) - @outcome.black
  end

  def play
    # Compare the player guess with the code.
    # Increment nb_attempts.
    # This represent an actual attempt to broke the code.
    @nb_attempts+=1
    compare(@guess, @selection)
    print "Attempt: #{@nb_attempts}/#{@max_attempts}; Guess: "
    @guess.each do |g|
      eval("print #{@colors[g]}(g)")
    end
    print " ", "+"*@outcome.black, "-"*@outcome.white, "\n"
    if @outcome.black == 4
      @done = true
      puts bold("Solved in #{@nb_attempts} attempts!")
    elsif @nb_attempts == @max_attempts
      print red("Failed, combination was: ")
      @selection.each do |g|
        eval("print bold(#{@colors[g]}(g))")
      end
      puts
    end
  end

end
