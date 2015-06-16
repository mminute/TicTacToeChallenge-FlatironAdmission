=begin
Flatiron School Application
Tic-Tac-Toe Coding Challenge
By: Mason Jennings
Submitted: 2015-03-07

Project Narrative:

I began by defining the gameboard object as this is the object being manipulated by both the human and computer players.
Once I had established the form of the gameboard I began to code the methods that would be used by the player to interact with the game.
get_input, valid_coord?(), and input_cleanup() work together to prompt the human player to enter a valid move or quit the game.
input_cleanup() allows the user to enter the desired space to mark as either row/column or column/row because, to the human player, both formats are functionally equivalent.
player_turn implements the human interface methods to modify the gameboard attribute of the current game/ instance of class TicTacToe.

The next step was to produce a means by which the computer would select a space to mark and manipulate the gameboard to mark the selected space.
The limitations of simply defining an order of preference for the available spaces then selecting the highest ranked space are readily apparent as this
method of selecting a move fails to repond to the actions of the players.  A quick Google search revealed Minimax or Minimax with alpha/beta pruning to be 
the prefered solutions for this type of problem.  Alpha/beta pruning is not implemented in the solution below.  I used the articles listed in the 'Sources'
section at the end of this comment block as I was not familiar with this game strategy.

The computer_move()- the maximizing player- and the human_move()- the minimizing player- alternately call each other in a recursive-like fashion,
analyzing the best selection for each respective player by simulating the remainder of the game and returning the selection most likely to result in victory.
computer_makes_move() executes the Minimax decision engine, modifies the playing board, then displays the playing board for the human player to make his or her next move.

The initialize method brings everything together, passing control between the human player and the computer decision engine until the game has reached an end,
at which point it displays a message stating the result of the game. 

Sources Consulted:
  http://ai-depot.com/articles/minimax-explained
  http://en.wikipedia.org/wiki/Game_tree
  http://en.wikipedia.org/wiki/Minimax
=end
class TicTacToe
  
    ROW_IDX={"a" => 1, "b" => 2, "c" => 3}
    
    def initialize
      @gameboard = [["#","1","2","3",],["A","-","-","-"],["B","-","-","-"],["C","-","-","-"]]
      @human = nil #This takes the player's marker- x or o
      @computer = nil #This takes the computer's marker- x or o
      player_symbols #determine who is x's and o's
      display_board(@gameboard)
      
      current_turn=:player
      while victor_or_tie(@gameboard,@human,@computer)==false
        if current_turn == :player
          player_turn
          current_turn=:computer
        else
          computer_makes_move(@gameboard,@computer,@human)
          current_turn=:player       
        end#if
      end#while
      
      if victor_or_tie(@gameboard,@human,@computer) == :win
        if valuate_the_board(@gameboard,@human,@computer) > valuate_the_board(@gameboard,@computer,@human)
          puts
          puts "You WON!"
          play_it_again_sam
        else
          puts
          puts "The COMPUTER Won!"
          play_it_again_sam
        end
      elsif victor_or_tie(@gameboard,@human,@computer) == :tie
        puts
        puts "It's a DRAW"
        play_it_again_sam
      end
      
    end#def initialize
  

#---AI Methods-------------------------------------------------------------------------------------------------------------
    def computer_makes_move(board, computer_marker,human_marker)
      coord=computer_move(board, computer_marker,human_marker)
      board[coord[0]][coord[1]]=computer_marker
      2.times{puts}
      display_board(board)
    end

    def computer_move(board,computer_marker,human_marker)       #Decision algorithm using the Minimax/MinMax decision rule-  computer_move() represents the maximizing player/ MaxMove
      if victor_or_tie(board,computer_marker,human_marker)!= false   #If the game is won or tied, then do this
        return valuate_the_board(board,computer_marker, human_marker)
      else    #If the game is not yet won/tied do this instead
        possible_moves = available_squares(board)
        best_move=[possible_moves[0][0],possible_moves[0][1]]   #A coordinate pair
        possible_moves.each do |poss_move|
          move=human_move(do_next_move(poss_move,board,computer_marker),human_marker,computer_marker)  #The best coordinate pair determined by the the simulation of subsequent moves
          if valuate_the_board(do_next_move(move,board,computer_marker),computer_marker, human_marker) > valuate_the_board(do_next_move(best_move,board,computer_marker),computer_marker, human_marker)
            best_move=move
          end
        end#possible_moves.each
      end#if/else
      return best_move
    end#def computer_move
    
    def human_move(board,human_marker,computer_marker)          #The minimizing player
      if victor_or_tie(board,human_marker,computer_marker)!= false   #If the game is won or tied, then do this
        return valuate_the_board(board,human_marker, computer_marker)
      else
        possible_moves = available_squares(board)
        best_move=[possible_moves[0][0],possible_moves[0][1]]
        possible_moves.each do |poss_move|
        move=computer_move(do_next_move(poss_move,board,human_marker),computer_marker,human_marker)
          if valuate_the_board(do_next_move(move,board,human_marker),human_marker, computer_marker) > valuate_the_board(do_next_move(best_move,board,human_marker),human_marker, computer_marker)
            best_move=move
          end#if
        end#each
      end#if/else  
      return best_move    #A coordinate pair?
    end
    
    #--Helper Methods for Decision Engine----------------------------------------------------------
    
    def available_squares(board)    #Find spaces available to mark
        avail_sqrs=[]
        board.each_with_index do |row,rw_idx|
          row.each_with_index do |elem, elem_idx|
            if elem=="-"
              avail_sqrs << [rw_idx,elem_idx]
            end
          end
        end#each_with_index
        return avail_sqrs #array of arrays of coordinates'[[a,b],[c,d],[e,f]]'
      end#def available_squares
      
      
      def lines_that_win(board)      #Create an Array of the state of each possible way to win the game
        top_row = board[1][1..3]
        middle_row = board[2][1..3]
        bottom_row = board[3][1..3]
        left_column = [board[1][1],board[2][1],board[3][1]]
        middle_column = [board[1][2],board[2][2],board[3][2]]
        right_column = [board[1][3],board[2][3],board[3][3]]
        diag_down = [board[1][1],board[2][2],board[3][3]]
        diag_up = [board[1][3],board[2][2],board[3][1]]
        
        winning_lines = [top_row, middle_row, bottom_row, left_column, middle_column, right_column, diag_down, diag_up]    
      end
      
      
      
      def victor_or_tie(board,player_marker,opponent_marker)      #Determine if someone has won/it's a draw or if the game continues
        winning_lines = lines_that_win(board)
        #look at each in winning lines, if one is filled with all same chars then there is a victory, if every line has x' and o's it is a draw, else the game is not over
        win = false
        tie = false
        # sets win_or_tie to true if there are 3 in a row
        winning_lines.each do |ln|
          if ln[0]==ln[1] && ln[1]==ln[2] && ln[0]!="-"
            win = true
          end
        end#each
        
        if win == false
          lns = 0
          winning_lines.each do |ln|
            if ln.include?(player_marker) && ln.include?(opponent_marker)
              lns+=1
            end#if
          end#each
          if lns == 8
            tie = true
          end     
        end#if win == false
        
        if win == true
          return :win
        elsif tie == true
          return :tie
        else
          return false
        end    
      end#def victor_or_tie?
      
      
      def do_next_move(coordinate_pair,board,player_marker)  #Apply a move and return the resulting board
        here_board = Marshal.load( Marshal.dump(board) ) #Make a deep copy of the playing board
        here_board[coordinate_pair[0]][coordinate_pair[1]]=player_marker
        return here_board
      end
      
      def valuate_the_board(board,player_marker, opponent_marker)#Get a score value for the current state of the board
        lines_to_score = lines_that_win(board)
        evaluated_score=0
        
        lines_to_score.each do |ln|
          #Score for 3-in-a-row
          if ln[0]==player_marker && ln[0]==ln[1] && ln[1]==ln[2]
            evaluated_score+=100
          #Score for 2-in-a-row w/ no opponent marks
          elsif ln.include?(opponent_marker)==false && ln.select{|elem|elem==player_marker}.length==2
            evaluated_score+=10
          #Score for single mark w/ no opponent marks
          elsif ln.include?(opponent_marker)==false && ln.include?(player_marker)==true
            evaluated_score+=1
          #Score for opponent 3-in-a-row
          elsif ln[0]==opponent_marker && ln[0]==ln[1] && ln[1]==ln[2]
            evaluated_score-=100
          #Score for opponent 2-in-a-row w/o current players' mark
          elsif ln.include?(player_marker)==false && ln.select{|elem|elem==opponent_marker}.length==2
            evaluated_score-=10
          #Score for opponent single mark w/o current players' mark
          elsif ln.include?(player_marker)==false && ln.include?(opponent_marker)==true
            evaluated_score-=1
          #Score for lines claimed by both players is equal to 0
          end#If/else for scoring
        end#each
        return evaluated_score
      end
      
#--Human Interface Methods----------------------------------------------------------------
      def player_turn  #get player input then mark a spot    
        2.times{puts}
        while true
          player_says = get_input
          if @gameboard[ROW_IDX[player_says[0]]][player_says[1]] == "-"  #the coordinate is unclaimed
            @gameboard[ROW_IDX[player_says[0]]][player_says[1]] = @human
            display_board(@gameboard)
            break
          else #do this if the coordinate is claimed
            puts "Sorry, that cell is occupied.  Please try a different coordinate."
          end#if      
        end#while
      end#def player_turn

    #--Human Interface Helper Methods-----------------------------------
    
      def get_input   #get a coordinate or 'quit' from the user-----------
        puts "Where would you like to place your mark?"
        puts "Enter a row letter and a column number(ex. 'B2') or 'quit' to end the game."
        
        while true
          mark_this = gets.chomp.downcase
          puts
          if mark_this == "quit"
            return exit
          elsif valid_coord?(mark_this.split(''))
            return input_cleanup(mark_this.split(''))
          else
            puts "Sorry, that isn't a valid coordinate.  Try again or enter 'quit'."
          end#if
        end#while
      end#get_input
      
      
      def valid_coord?(coords)    #Validate that user gave an acceptable coordinate.  Accepts array of single character strings as arguement-------------
        if coords.length == 2 #if the array contains two elements
          a_valid_letter = false
          a_valid_number = false
          coords.each do |partial_coord| #look at both array elements
            if partial_coord.to_i.between?(1,3) && a_valid_number == false
              a_valid_number = true
            elsif partial_coord.between?("a","c") && a_valid_letter == false
              a_valid_letter = true
            end#if
          end#each      
          if a_valid_letter && a_valid_number #does the each method above set both a_valid_letter and a_valid_number to true?  if so it is a valid coordinate
            return true
          else
            return false
          end          
        else#coord.length != 2
          return false
        end#outer if    
      end#def valid_coord?
      
               
      def input_cleanup(input_arr)    #Make the coordinate of the form ["some_letter", some_number]----------------------------------
        if input_arr[1].to_i > 0
          return [input_arr[0],input_arr[1].to_i]
        else
          return [input_arr[1],input_arr[0].to_i]
        end    
      end#def input_cleanup
            
      
      def player_symbols    # Determine who plays as X or O--------------
        puts "Would you like your marker to be X or O?"
        until @human != nil
          x_or_o = gets.chomp.downcase #input from player          
          #Assign marker based on player input
          if x_or_o == "x"
            @human = "X"
            @computer = "O"
          elsif x_or_o == "o"
            @human = "O"
            @computer = "X"
          elsif x_or_o == "quit"
            return :quit
          else
            puts "Sorry, I didn't understand that.  Please enter'X' or 'O' or 'quit'."
          end#if/else
        end#until
        puts "You are playing as #{@human}"
      end#def player_symbol
      
      
      def display_board(playing_board)    #Display the game board.  Accepts 2D array representing gameboard as arguement---------------------
        playing_board.each do |ln|
          puts ln.to_s
        end
      end#def display_board
      
      
      def play_it_again_sam
        puts
        puts "Would you like to play again? y/n"
        response=gets.chomp.downcase
        if response=="y"
          initialize
        else
          exit
        end
      end
      

end#class



mygame = TicTacToe.new