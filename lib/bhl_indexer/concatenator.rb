module BHLIndexer
  class Concatenator

    attr :files, :concatenated_text, :pages_offsets

    def initialize(path)
      @path = path
      @files = get_files
      @concatenated_text = nil
      @pages_offsets = {}
    end

    def concatenate
      @concatenated_text = ''
      @files.each do |f|
        file = open(f, 'r:utf-8').read
        prev_size = @pages_offsets.keys.first ? @pages_offsets[@pages_offsets.keys.last] : 0 
        @pages_offsets[f] = prev_size + file.size
        @concatenated_text << file
      end
    end

    private

    def get_files
      files = Dir.entries(@path).map { |f| File.join(@path, f) }.sort
      files.select { |f| File.file?(f) }
    end
  end
end
