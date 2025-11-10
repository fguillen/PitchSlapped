require "active_support"
require "active_support/core_ext/string/inflections"

module PitchSlapped
  module Utils
    def self.timestamp
      DateTime.now.strftime("%Y%m%d%H%M%S")
    end

    def self.sanitize(string)
      string.underscore.parameterize(separator: "_")
    end

    def self.root_dir
      File.expand_path("..", __dir__)
    end

    def self.class_name_sanitized(klass)
      PitchSlapped::Utils.sanitize(klass.name.split("::").last)
    end

    def self.book_title_sanitized(book_title)
      PitchSlapped::Utils.sanitize(book_title)
    end
  end
end
