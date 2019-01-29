require_relative 'Mastermind'

class Solver
  def initialize(game)
    @game = game

    all_comb   = @game.colors.keys.repeated_permutation(@game.nb_holes).to_a
    uniq_comb  = Array.new
    all_comb.each do |elem|
      if elem.uniq.length == elem.length
        uniq_comb.push(elem)
      end
    end
    @game.allow_duplicates ? combinations = all_comb : combinations = uniq_comb
    @unused_codes = combinations.dup
    @remaining_combinations = combinations.dup

    @all_outomes = Array.new
    (0..@game.nb_holes).step(1) do |b|
      (0..@game.nb_holes-b).step(1) do |w|
        unless (b == @game.nb_holes-1 && w==1)
          @all_outomes.push(Outcome.new(black:b, white:w))
        end
      end
    end
  end

  def knuth_algo
    @game.guess = [@game.colors.keys[0], @game.colors.keys[0], @game.colors.keys[1], @game.colors.keys[1]]
    @game.play
    @unused_codes.delete(@game.guess)

    while @game.max_attempts - @game.nb_attempts > 0 && !@game.done
      remove_inconsistent
      if @remaining_combinations.length == 1
        @game.guess = @remaining_combinations.pop
      else
        @game.guess = minmax_next_guess
      end
      @game.play
      @unused_codes.delete(@game.guess)
    end

  end

  def remove_inconsistent()
    unless @game.done || @remaining_combinations.length == 1
      previous_outcome = @game.outcome.dup
      inconsistent = Array.new
      @remaining_combinations.each do |rem|
        @game.compare(rem, @game.guess)
        unless (@game.outcome == previous_outcome)
          inconsistent.push(rem)
        end
      end
      @remaining_combinations -= inconsistent
    end
  end

  def minmax_next_guess
    @unused_codes.max_by { |x|
      foo = Array.new
      @all_outomes.each do |outcome|
        i = 0
        @remaining_combinations.each do |rem|
          @game.compare(rem, x)
          unless (@game.outcome == outcome)
            i+=1
          end
        end
        foo.push(i)
      end
      foo.min
    }
  end

end
