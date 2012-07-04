
require './Vector3D'

################################################################################

class Numeric
  def degrees
    self * Math::PI / 180
  end
end


################################################################################

class Particle
  attr_accessor :loc, :vel, :acc, :radius, :theta


  def initialize(width,
                 height,
                 origin = Vector3D.new(0,0,0),
                 radius = 10.0,
                 max_speed = 10.0,
                 max_force = 2.0)
    @width = width
    @height = height
    @loc = origin
    @radius = radius
    @max_speed = max_speed
    @max_force = max_force
    @vel = Vector3D.new
    @acc = Vector3D.new
    @timer = 5000.0
    @theta = 0.0
    @wander_theta = 0.0
  end


  def run(particles = [])
    flock(particles) if particles.size > 0
    update
    enforce_bounds
  end


  def update
    @vel += @acc
    @vel = @vel.limit(@max_speed)
    @loc += @vel
    @acc.x, @acc.y, @acc.z = 0.0, 0.0, 0.0
    @timer -= 1.0
  end


  def dead?
    @timer <= 0.0
  end


  def seek(target)
    @acc += steer(target, false)
  end


  def arrive(target)
    @acc += steer(target, true)
  end


  def steer(target, slowdown)
    slowdown_threshold = 100.0
    desired = target - @loc
    desm = desired.magnitude

    return Vector3D.new(0,0,0) if desm < 0.001

    desired = desired.normalize

    if (slowdown == true) and (desm < slowdown_threshold)
      desired = desired * (@max_speed * (desm/slowdown_threshold))
    else
      desired = desired * @max_speed
    end

    (desired - @vel).limit @max_force
  end


  def wander
    wander_radius   = 16.0
    wander_distance = 60.0
    change          = 0.25

    @wander_theta += rand*change*2.0 - change

    circle_loc = (@vel.normalize * wander_distance) + @loc

    circle_offset = Vector3D.new(wander_radius * Math.cos(@wander_theta),
                                 wander_radius * Math.sin(@wander_theta))

    target = circle_loc + circle_offset
    @acc += steer(target, false)

    @draw_wander_circle = false
    draw_wander_reticle(@loc, circle_loc, target, wander_radius) if @draw_wander_circle
  end


  def draw_wander_reticle(loc, circle, target, radius)
    $app.stroke 200
#    $app.no_fill
#    $app.ellipse_mode CENTER
    $app.ellipse circle.x, circle.y, radius*2, radius*2
    $app.ellipse target.x, target.y, 4, 4
    $app.line loc.x, loc.y, circle.x, circle.y
    $app.line circle.x, circle.y, target.x, target.y
  end


  def separation particles
    desired_separation = 25.0
    sum = Vector3D.new
    count = 0

    particles.each do |p|
      d = @loc.distance_from p.loc
      if d > 0 and d < desired_separation
        diff = ((@loc - p.loc).normalize) / d
        sum += diff
        count += 1
      end
    end

    sum = sum / count.to_f if count > 0
    sum
  end


  def alignment particles
    neighbor_dist = 100.0
    sum = Vector3D.new
    count = 0

    particles.each do |p|
      d = @loc.distance_from p.loc
      if d > 0 and d < neighbor_dist
        sum += p.vel
        count += 1
      end
    end

    if count > 0
      sum = sum / count.to_f
      sum = sum.limit(@max_force)
    end

    sum
  end


  def cohesion particles
    neighbor_dist = 50.0
    sum = Vector3D.new
    count = 0

    particles.each do |p|
      d = @loc.distance_from p.loc
      if d > 0 and d < neighbor_dist
        sum += p.loc
        count += 1
      end
    end

    return steer(sum/count.to_f, false) if count > 0
    return sum
  end


  def flock particles
    @acc += (separation(particles)*1.5 +
             alignment(particles)*0.5 +
             cohesion(particles)*1.0)
  end


  def enforce_bounds
    # Wraparound
    @loc.x = @width  + @radius if @loc.x < -@radius
    @loc.y = @height + @radius if @loc.y < -@radius

    @loc.x = -@radius if @loc.x > @width  + @radius
    @loc.y = -@radius if @loc.y > @height + @radius
  end


  def render
    @theta = @vel.heading2D + 90.degrees
    yield self
  end
end


################################################################################

class ParticleSystem
  def initialize(num, origin = Vector3D.new(0,0,0))
    @origin = origin
     @particles = []
    num.times do |i|
      @particles << Particle.new($app.width,
                                 $app.height,
                                 Vector3D.new(rand*$app.width, rand*$app.height),
                                 4.0,
                                 rand*20.0,
                                 rand*6.0)
    end
  end


  def run
    @particles.delete_if do |p|
      rand_behavior p
      p.run(@particles)
      p.dead?
    end
  end


  def render &blk
    @particles.each do |p|
      p.render &blk
    end
  end


  def rand_behavior particle
      case rand*3
      when 2..3
        particle.seek(Vector3D.new($app.mouse_x, $app.mouse_y))
      when 1..2
        particle.arrive(Vector3D.new($app.mouse_x, $app.mouse_y))
      else
        particle.wander
      end
  end


=begin
  def render
    $app.fill 200/255.0
    $app.stroke 255/255.0

    @particles.each do |p|
      p.render do |pr|
        env.push_matrix
        env.translate pr.loc.x, pr.loc.y
        env.rotate pr.theta
        env.begin_shape TRIANGLES
        env.vertex 0, -pr.radius*2
        env.vertex -pr.radius, pr.radius*2
        env.vertex pr.radius, pr.radius*2
        env.end_shape
        env.pop_matrix
      end
    end
  end
=end

  def add_particle(p = Particle.new(@origin))
    @particles << p
  end


  def dead?
    @particles.size == 0
  end
end


