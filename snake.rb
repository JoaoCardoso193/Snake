require 'ruby2d'

set background: 'navy'
set fps_cap: 20

GRID_SIZE = 20 #grid size is 20 pixels

#for window that is 480 * 640, width is 32 (640/20) and height is 24 (480/20) at grid size = 20 pixels
GRID_WIDTH = Window.width / GRID_SIZE
GRID_HEIGHT = Window.height / GRID_SIZE

class Snake

    attr_writer :direction
    attr_reader :positions

    def initialize
        @positions = [[2, 0], [2,1], [2,2], [2,3]] #first coordinate is x and the second is y, starting from top left corner
        @direction = 'down'
        @growing = false
    end

    def draw
        @positions.each do |position|
            Square.new(x: position[0] * GRID_SIZE, y: position[1] * GRID_SIZE, size: GRID_SIZE - 1, color: 'olive')
        end
    end

    def move
        if !@growing
            @positions.shift
        end

        case @direction
        when 'down'
            @positions.push(new_coords(head[0], head[1] + 1))
        when 'up'
            @positions.push(new_coords(head[0], head[1] - 1))
        when 'left'
            @positions.push(new_coords(head[0] - 1, head[1]))
        when 'right'
            @positions.push(new_coords(head[0] + 1, head[1]))
        end
        @growing = false
    end

    #Preventing snake from moving backwards into itself
    def can_change_direction_to?(new_direction)
        case @direction
        when 'up' then new_direction != 'down'
        when 'down' then new_direction != 'up'
        when 'left' then new_direction != 'right'
        when 'right' then new_direction != 'left'
        end
    end

    def x
        head[0]
    end

    def y
        head[1]
    end

    def grow
        @growing = true
    end

    def snake_hit_itself?
        @positions.uniq.length != @positions.length #this checks if there are any duplicate positions in the snake (self-collision)
    end

    private

    #This method uses the modulus operator to make the
    #snake appear on the other side of the screen when it goes over the edge
    def new_coords(x,y)
        [x % GRID_WIDTH, y % GRID_HEIGHT]
    end

    def head
        @positions.last
    end

end

class Game
    def initialize(snake)
        @snake = snake
        @score = 0
        initial_coords = draw_ball
        @ball_x = initial_coords[0]
        @ball_y = initial_coords[1]
        @finished = false
        @paused = false
    end

    def draw_ball

        available_coords = []
        for x in (0..GRID_WIDTH-1)
            for y in (0..GRID_HEIGHT-1)
                available_coords.append([x, y])
            end
        end

        selected = available_coords.select{|coord| !@snake.positions.include?(coord)}
        selected.sample
        
    end

    def draw
        unless finished?
            Square.new(x: @ball_x * GRID_SIZE, y: @ball_y * GRID_SIZE, size: GRID_SIZE, color: 'yellow')
        end
        Text.new(text_message, color: 'white', x: 10, y: 10, size: 25)
    end

    def snake_hit_ball?(x, y)
        @ball_x == x && @ball_y == y
    end

    def record_hit
        @score += 1
        ball_coords = draw_ball
        @ball_x = ball_coords[0]
        @ball_y = ball_coords[1]
    end

    def finish
        @finished = true
    end

    def finished?
        @finished
    end

    def pause
        @paused = true
    end

    def unpause
        @paused = false
    end

    def paused?
        @paused
    end



    private

    def text_message
        if finished?
            "Game over, score: #{@score}. Press 'R' to restart, 'Q' to quit."
        elsif paused?
            "Game paused, score: #{@score}. Press 'P' to resume."
        else
            "Score: #{@score}"
        end
    end

end

snake = Snake.new
game = Game.new(snake)

#this block will run for each frame
update do
    clear

    unless game.finished? or game.paused?
        snake.move
    end
    snake.draw
    game.draw

    if game.snake_hit_ball?(snake.x, snake.y)
        game.record_hit
        snake.grow
    end

    if snake.snake_hit_itself?
        game.finish
    end
end

#this event triggers when any key has been pressed
on :key_down do |event|
    if ['up', 'down', 'left', 'right'].include?(event.key)
        if snake.can_change_direction_to?(event.key) and !game.paused?
            snake.direction = event.key
        end
    elsif event.key == 'r' or event.key == 'R' #resetting game
        snake = Snake.new
        game = Game.new(snake)
    elsif event.key == 'q' or event.key == 'Q' #quitting game
        exit()
    elsif event.key == 'p' or event.key == 'P' #pausing/unpausing game
        if game.paused?
            game.unpause
        else
            game.pause
        end
    end
    
end

show