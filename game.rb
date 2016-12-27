require 'json'

require 'gosu'
require 'chipmunk'

require_relative './debug_dialog.rb'
require_relative './track.rb'

# Main game window
class GameWindow < Gosu::Window
  WIDTH = Track::TILE_SIZE * 10
  HEIGHT = Track::TILE_SIZE * 6

  def initialize
    super(WIDTH, HEIGHT)
    self.caption = 'Gosu Tutorial Game'

    @debug_dialog = DebugDialog.new(window: self)

    @space = CP::Space.new

    load_map!
    load_car!
    @space.damping = Car::LINEAR_FRICTION
  end

  def update
    @debug_dialog.update
    @track.update
    @car.update

    @space.step(update_interval / 1000)
  end

  def draw
    @debug_dialog.draw
    @track.draw
    @car.draw
  end

  def load_map!
    current_map = File.open('maps/test_track_1.json') do |file|
      JSON.load(file)
    end
    @track = Track.new(map: current_map)
  end

  def load_car!
    load('./car.rb')
    @car = Car.new(WIDTH / 2, HEIGHT / 2)
    @space.add_body(@car.rigid_body)
  end
end

window = GameWindow.new
window.show
