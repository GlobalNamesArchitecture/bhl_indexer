module BHLIndexer
  class Carousel
    include Enumerable
    attr_accessor :herd_size, :carousel

    alias :size :count

    def initialize
      @herd_size = BHLIndexer::Config.carousel_size
      @carousel = []
      @cursor = 0
    end

    def populate
      titles = Title.where(:status => Title::STATUS[:init]).limit(@herd_size - @carousel.size)
      @carousel = titles + @carousel
    end

    def send_texts
      @carousel.each_with_index do |t, i|
        @cursor = i
        break if t.gnrd_url
        t.send_text
      end
    end

    def get_names
      @carousel = @carousel[@cursor..-1] + @carousel[0...@cursor]
      @herd_size.times do
        title = @carousel.shift
        title.get_names
        title.names ? title.make_pages : @carousel.carousel.push(title)
      end
      @cursor = 0
    end

    def each &block
      @carousel.each { |horsie| block.call(horsie) }
    end

  end
end
