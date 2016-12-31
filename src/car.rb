# Player car
class Car
  Z_ORDER = 5
  SPRITE_SCALE = 0.5

  LINEAR_ACCELERATION = 540
  BRAKING_POWER = 1080 # TODO: find a proper value for this

  ANGULAR_ACCELERATION = 0.1
  ANGULAR_FRICTION = 0.9

  attr_reader :sprite
  attr_reader :rigid_body
  attr_reader :angular_velocity

  def initialize(x:, y:, space:)
    @sprite = Gosu::Image.new('assets/Cars/car_blue_1.png', retro: true)

    @rigid_body = CP::Body.new(1, 1)
    space.add_body(rigid_body)

    @angular_velocity = 0
    rigid_body.p.x = x
    rigid_body.p.y = y
  end

  def update
    rigid_body.reset_forces
    dt = 1 / 60.0 # TEMP: approximation

    turn_left(dt)  if Gosu.button_down? Gosu::KbLeft
    turn_right(dt) if Gosu.button_down? Gosu::KbRight
    accelerate     if Gosu.button_down? Gosu::KbUp
    brake          if Gosu.button_down? Gosu::KbDown

    apply_tires_force(dt)

    turn(dt)
  end

  def draw(debug: false)
    sprite.draw_rot(rigid_body.p.x, rigid_body.p.y, Z_ORDER, angle, 0.5, 0.6, SPRITE_SCALE, SPRITE_SCALE)

    return unless debug
    draw_direction_vector
  end

  private

  def angle
    rigid_body.a.radians_to_gosu
  end

  def velocity
    rigid_body.v.length
  end

  def turn_right(dt)
    @angular_velocity += [ANGULAR_ACCELERATION / (velocity * dt) * 2, ANGULAR_ACCELERATION].min
  end

  def turn_left(dt)
    @angular_velocity -= [ANGULAR_ACCELERATION / (velocity * dt) * 2, ANGULAR_ACCELERATION].min
  end

  def accelerate
    @rigid_body.apply_force(direction_vector * LINEAR_ACCELERATION, CP::Vec2::ZERO)
  end

  def brake
    # TODO: Stop applying force when velocity is backwards
    @rigid_body.apply_force(direction_vector * BRAKING_POWER * -1, CP::Vec2::ZERO)
  end

  def apply_tires_force(dt)
    orthogonal_direction = CP::Vec2.for_angle(((angle + 90) % 360).gosu_to_radians)
    tires_force = (rigid_body.v / dt).project(orthogonal_direction) * -1
    rigid_body.apply_force(tires_force, CP::Vec2::ZERO)
  end

  def direction_vector
    CP::Vec2.for_angle(rigid_body.a)
  end

  def draw_direction_vector
    start = rigid_body.pos
    finish = start + direction_vector * 50
    Gosu.draw_line(
      start.x, start.y, Gosu::Color::WHITE,
      finish.x, finish.y, Gosu::Color::WHITE,
      Z_ORDER + 1
    )
  end

  def turn(dt)
    diff = (angular_velocity * (velocity * dt)).gosu_to_radians - 0.gosu_to_radians
    rigid_body.a += diff

    @angular_velocity *= ANGULAR_FRICTION
  end
end
