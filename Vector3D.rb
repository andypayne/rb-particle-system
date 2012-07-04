

################################################################################

class Vector3D
  attr_accessor :x, :y, :z

  def initialize(x = 0.0, y = 0.0, z = 0.0)
    @x, @y, @z = x, y, z
  end


  def + (other)
    if (other.respond_to? 'x' and
       other.respond_to? 'y' and
       other.respond_to? 'z')

      Vector3D.new(@x + other.x,
          @y + other.y,
          @z + other.z)
    else
      Vector3D.new(@x + other, @y + other, @z + other)
    end
  end


  def - (other)
    if (other.respond_to? 'x' and
       other.respond_to? 'y' and
       other.respond_to? 'z')

      Vector3D.new(@x - other.x,
          @y - other.y,
          @z - other.z)
    else
      Vector3D.new(@x - other, @y - other, @z - other)
    end
  end


  def * (scalar)
    Vector3D.new(@x*scalar, @y*scalar, @z*scalar)
  end


  def / (scalar)
    raise ZeroDivisionError if scalar == 0
    Vector3D.new(@x/scalar, @y/scalar, @z/scalar)
  end


  def cross (other)
    if !(other.respond_to? 'x' and
         other.respond_to? 'y' and
         other.respond_to? 'z')
       raise "Vector3D#cross requires a Vector3D."
    end

    Vector3D.new(@y*other.z - @z*other.y,
                 @z*other.x - @x*other.z,
                 @x*other.y - @y*other.x)
  end


  # Vector dot product
  def dot (other)
    if !(other.respond_to? 'x' and
         other.respond_to? 'y' and
         other.respond_to? 'z')
       raise "Vector3D#dot requires a Vector3D."
    end

    @x*other.x + @y*other.y + @z*other.z
  end


  def magnitude
    Math.sqrt(@x**2 + @y**2 + @z**2)
  end


  def normalize
    m = magnitude
    return Vector3D.new if m == 0
    Vector3D.new(@x/m, @y/m, @z/m)
  end


  def limit(scalar)
    if magnitude > scalar
      normalize * scalar
    else
      self
    end
  end


  def distance_from(other)
    Math.sqrt((@x - other.x)**2 + (@y - other.y)**2 + (@z - other.z)**2)
  end


  def heading2D
    -1.0*(Math.atan2(-@y, @x))
  end


  def to_s
    "(#{format "%.4f", @x}, #{format "%.4f", @y}, #{format "%.4f", @z})"
  end
end


################################################################################


if __FILE__ == $PROGRAM_NAME
  require 'test/unit'

  class TestVector3D < Test::Unit::TestCase
    def test_vector_addition
      v1 = Vector3D.new(1,2,3)
      v2 = Vector3D.new(4,5,6)
      v3 = v1 + v2
      assert_equal(v3.x, 5, 'Vector addition')
      assert_equal(v3.y, 7, 'Vector addition')
      assert_equal(v3.z, 9, 'Vector addition')
    end

    def test_scalar_addition
      v1 = Vector3D.new(1.5,39.3,7.0)
      v2 = v1 + 54.2
      assert_equal(v2.x, 55.7, 'Vector-scalar addition')
      assert_equal(v2.y, 93.5, 'Vector-scalar addition')
      assert_equal(v2.z, 61.2, 'Vector-scalar addition')
    end

     def test_vector_subtraction
      v1 = Vector3D.new(5,12,9)
      v2 = Vector3D.new(4,5,6)
      v3 = v1 - v2
      assert_equal(v3.x, 1, 'Vector subtraction')
      assert_equal(v3.y, 7, 'Vector subtraction')
      assert_equal(v3.z, 3, 'Vector subtraction')
    end

    def test_scalar_subtraction
      v1 = Vector3D.new(121.5,39.3,97.0)
      v2 = v1 - 54.2
      assert_equal(v2.x,   67.3, 'Vector-scalar subtraction')

      # Floating point rigmarole.
      assert(v2.y - 14.9 < 0.0001, 'Vector-scalar subtraction')
      assert_equal(v2.z,   42.8, 'Vector-scalar subtraction')
    end

    def test_scalar_multiplication
      v1 = Vector3D.new(5,12,9)
      v2 = v1 * 3
      assert_equal(v2.x, 15, 'Vector-scalar multiplication')
      assert_equal(v2.y, 36, 'Vector-scalar multiplication')
      assert_equal(v2.z, 27, 'Vector-scalar multiplication')
    end

    def test_scalar_division
      v1 = Vector3D.new(6,8,10)
      v2 = v1 / 2
      assert_equal(v2.x, 3, 'Vector-scalar division')
      assert_equal(v2.y, 4, 'Vector-scalar division')
      assert_equal(v2.z, 5, 'Vector-scalar division')

      assert_raises(ZeroDivisionError) { v2 = v1 / 0 }
    end

    def test_cross_product
      v1 = Vector3D.new(1,2,3)
      v2 = Vector3D.new(4,5,6)
      v3 = v1.cross v2
      assert_equal(v3.x, -3, 'Vector cross product')
      assert_equal(v3.y, 6,  'Vector cross product')
      assert_equal(v3.z, -3, 'Vector cross product')
    end

    def test_dot_product
      v1 = Vector3D.new(1,3,-5)
      v2 = Vector3D.new(4,-2,-1)
      assert_equal(v1.dot(v2), 3, 'Vector dot product')
    end

    def test_magnitude
      v1 = Vector3D.new(1,1,Math.sqrt(2))
      assert_equal(v1.magnitude, 2.0, 'Vector magnitude')
    end

    def test_normalize
      v1 = Vector3D.new(1,1,Math.sqrt(2))
      v2 = v1.normalize
      assert_equal(v2.x, 0.5, 'Vector normalization')
      assert_equal(v2.y, 0.5, 'Vector normalization')
      assert_equal(v2.z, Math.sqrt(2)/2.0, 'Vector normalization')

      v1 = Vector3D.new
      v2 = v1.normalize
      assert_equal(v2.x, 0.0, 'Vector normalization - 0.0')
      assert_equal(v2.y, 0.0, 'Vector normalization - 0.0')
      assert_equal(v2.z, 0.0, 'Vector normalization - 0.0')
    end

    def test_limit
      v1 = Vector3D.new(10, 200, 3000)
      v2 = v1.limit(20)
      assert(v2.x < 20.0, 'Vector limit')
      assert(v2.y < 20.0, 'Vector limit')
      assert(v2.z < 20.0, 'Vector limit')
    end

    def test_to_s
      v1 = Vector3D.new(32.4,4830.329,82147.2)
      assert_equal(v1.to_s,'(32.4000, 4830.3290, 82147.2000)', 'Vector3D#to_s')
    end
  end
end



