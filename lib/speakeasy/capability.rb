module Speakeasy
  class Capability < Language
    CAPABILITY_DATA_DIR = File.join(File.dirname(__FILE__), '..', '..', 'capabilities')

    class << self
      def supported_capability_ids
        Dir.glob("#{CAPABILITY_DATA_DIR}/*").map { |file| File.basename(file) }
      end

      alias_method :supported_language_ids, :supported_capability_ids
    end

    alias_method :capability_id, :language_id

    def supported_by?(font_codepoints)
      unless font_codepoints.is_a?(Enumerable)
        raise ArgumentError, "Font codepoints must be enumerable"
      end
      (codepoints - font_codepoints.to_a).empty?
    end

  private
    def data_directory
      CAPABILITY_DATA_DIR
    end
  end
end
