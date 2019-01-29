require_relative 'Mastermind'
require_relative 'Solver'
require 'getoptlong'

opts = GetoptLong.new(
  [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
  [ '--lenght', '-l', GetoptLong::OPTIONAL_ARGUMENT ],
  [ '--colors', '-c', GetoptLong::OPTIONAL_ARGUMENT ],
  [ '--games', '-g', GetoptLong::OPTIONAL_ARGUMENT ],
  [ '--ia', '-i', GetoptLong::OPTIONAL_ARGUMENT ],
  [ '--duplicates', '-d', GetoptLong::OPTIONAL_ARGUMENT ],
  [ '--attempts', '-a', GetoptLong::OPTIONAL_ARGUMENT ],
)
# default values
nb_holes=4
nb_colors=6
nb_games=1
against_computer=true
allow_duplicates=true
max_attempts=10

def wrongArg
  puts "Wrong argument (try --help)"
  exit 0
end
def true?(obj)
  obj.to_s == "true"
end

opts.each do |opt, arg|
  case opt
    when '--help'
      puts <<-EOF
@Name     : Mastermind in Ruby
@Author   : Maxime VAST
@Version  : 1.0
@Date     : March the 11th 2017
@Desc     : This programm allow you to play Mastermind with a friend or alone against the computer.
            The computer uses Donald Knuth Five-Guess algorithm
            Omited parameters will use default values.
            While playing against the computer, it is advised to keep the default parameters
            Done for P00400: Paradigms of Programming @ Brookes University

--help, -h:
    show help and exit
--lenght, -l:
    Number of holes in the board (Type : Int; Range : [2..6]; Default : 4)
--colors, -c:
    Number of available colors (Type : Int; Range : [2..6]; Default : 6)
--games, -g:
    Number of game both player will play (Type : Int; Range : [1..10]; Default : 1)
--ia, -i:
    Choose to play against the computer instead of another human (Type : Bool; Range : [true, false]; Default : true)
--duplicates, -d:
    Decide if the code could contain duplicates (Type : Bool; Range : [true, false]; Default : true)
--attempts, -a:
    Maximum number of attempts to break the code (Type : Int; Range : [5..20]; Default : 10)
      EOF
      exit 0
    when '--lenght'
      a = arg.to_i
      if (2..6).step().to_a.include? a
        nb_holes=a
      else
        wrongArg
      end
    when '--colors'
      a = arg.to_i
      if (2..6).step().to_a.include? a
        nb_colors=a
      else
        wrongArg
      end
    when '--games'
      a = arg.to_i
      if (1..10).step().to_a.include? a
        nb_games=a
      else
        wrongArg
      end
    when '--ia'
      against_computer=true?(arg)
    when '--duplicates'
      against_computer=true?(arg)
    when '--attempts'
      a = arg.to_i
      if (5..20).step().to_a.include? a
        max_attempts=a
      else
        wrongArg
      end
  end
end

player1_score = 0
player2_score = 0
m = Mastermind.new(nb_holes, nb_colors, allow_duplicates, max_attempts)
def human(game)
  game.draw
  f = true
  while game.max_attempts - game.nb_attempts > 0 && !game.done
    game.ask(first:f)
    game.play
    f=false
  end
end
def computer(game)
  game.ask(code:true)
  game = Solver.new(game)
  game.knuth_algo
end
def update_score(score, game)
  score += game.nb_attempts
  unless game.done
    score += 1
  end
  score
end


(0..nb_games-1).step() do |i|
  print green("------------------------\n")
  print "It's Player 1 turn (#{i+1}/#{nb_games})\n"
  print green("------------------------\n")
  human(m)
  player2_score = update_score(player2_score, m)
  if against_computer
    print green("-----------------------------\n")
    print "The computer is playing (#{i+1}/#{nb_games})\n"
    print green("-----------------------------\n")
    computer(m)
  else
    print green("------------------------\n")
    print "It's Player 2 turn (#{i+1}/#{nb_games})\n"
    print green("------------------------\n")
    human(m)
  end
  player1_score = update_score(player1_score, m)
end

if player1_score > player2_score
  print green("Player 1 won against ")
  if against_computer
    print green("the computer!\n")
  else
    print green("player 2!\n")
  end
elsif player1_score < player2_score
  if against_computer
    print green("The computer ")
  else
    print green("Player 2 ")
  end
  print green("won against player 1\n")
else
  puts green("This is a tie, play again :)")
end
