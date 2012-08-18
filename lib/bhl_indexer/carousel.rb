module BHLIndexer
  class Carousel
    include Enumerable
    attr_accessor :herd_size, :carousel_ary

    alias :size :count

    def initialize
      @herd_size = BHLIndexer::Config.carousel_size
      @carousel_ary = []
      @cursor = 0
      @first_batch = true
    end
    
    def rebuild_names_hash
      if Title::NAMES_HASH.empty?
        NameString.all.each do |n|
          Title::NAMES_HASH[n.name] = n.id
        end
      end
    end

    def populate
      if @first_batch
        Title.connection.execute("update titles set status = %s where status != %s" % [Title::STATUS[:init], Title::STATUS[:completed]])
        @first_batch = false
      end
      titles = Title.where(:status => Title::STATUS[:init]).limit(@herd_size - @carousel_ary.size)
      titles.each do |t|
        t.status = Title::STATUS[:enqueued]
        t.save!
      end
      @carousel_ary = titles + @carousel_ary
    end

    def send_texts
      @cursor = 0
      @carousel_ary.each_with_index do |t, i|
        if t.gnrd_url
          @cursor = i
          break
        end
        t.send_text
      end
    end

    def get_names
      @carousel_ary = @carousel_ary[@cursor..-1] + @carousel_ary[0...@cursor] if @cursor != 0
      @herd_size.times do
        title = @carousel_ary.shift
        if title && title.status != Title::STATUS[:failed]
          title.get_names
          title.names ? title.names_to_pages : @carousel_ary.push(title)
        end
      end
      @cursor = 0
    end

    def each &block
      @carousel_ary.each { |horsie| block.call(horsie) }
    end

  end
end
