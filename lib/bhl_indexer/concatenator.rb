module BHLIndexer
  class Concatenator

    attr :files, :concatenated_text, :pages_offsets, :pages_ids

    def initialize(path)
      @path = path
      @files = get_files
      @concatenated_text = nil
      @pages_offsets = []
      @pages_ids = []
    end

    def concatenate
      @concatenated_text = ''
      @files.each do |f|
        file = open(f, 'r:utf-8')
        file_text = file.read
        prev_size = @pages_offsets.empty? ? 0 : @pages_offsets.last 
        @pages_ids << File.basename(f, '.txt')
        @pages_offsets << prev_size + file_text.size
        @concatenated_text << file_text
        file.close
      end
    end

    private

    def get_files
      files = Dir.entries(@path).map { |f| File.join(@path, f) }.sort
      files.select { |f| File.file?(f) }
    end
  end
end
