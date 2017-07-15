# This module provides an interface to the top level bits of GLib
# via ruby-ffi.
#
# Author::    John Cupitt  (mailto:jcupitt@gmail.com)
# License::   MIT

require 'ffi'

module Vips

    attach_function :vips_image_new, [], :pointer

    attach_function :vips_filename_get_filename, [:string], :string
    attach_function :vips_filename_get_options, [:string], :string
    attach_function :vips_filename_get_options, [:string], :string

    attach_function :vips_foreign_find_load, [:string], :string
    attach_function :vips_foreign_find_save, [:string], :string
    attach_function :vips_foreign_find_load_buffer, [:pointer, :size_t], :string
    attach_function :vips_foreign_find_save_buffer, [:pointer, :size_t], :string

    attach_function :vips_image_get_typeof, [:pointer, :string], :GType
    attach_function :vips_image_get, [:pointer, :string, GLib::GValue.ptr], :int
    attach_function :vips_image_set, [:pointer, :string, GLib::GValue.ptr], :void
    attach_function :vips_image_remove, [:pointer, :string], :void

    class Image < Vips::Object

        # the layout of the VipsImage struct
        module ImageLayout
            def self.included(base)
                base.class_eval do
                    layout :parent, Vips::Object::Struct
                    # rest opaque
                end
            end
        end

        class Struct < Vips::Object::Struct
            include ImageLayout

            def initialize(ptr)
                log "Vips::Image::Struct.new: #{ptr}"
                super
            end

        end

        class ManagedStruct < Vips::Object::ManagedStruct
            include ImageLayout

            def initialize(ptr)
                log "Vips::Image::ManagedStruct.new: #{ptr}"
                super
            end

        end

        def method_missing(name, *args)
            Vips::Operation::call name.to_s, [self] + args
        end

        def self.method_missing(name, *args)
            Vips::Operation::call name.to_s, args
        end

        def get_typeof name
            Vips::vips_image_get_typeof self, name
        end

        def get name
            gvalue = GLib::GValue.alloc
            result = Vips::vips_image_get self, name, gvalue
            if result != 0 
                raise Vips::Error
            end

            return gvalue.get
        end

        def set_type gtype, name, value
            gvalue = GLib::GValue.alloc
            gvalue.init gtype
            gvalue.set value
            Vips::vips_image_set self, name, gvalue
        end

        def set name, value
            set_type get_typeof(name), name, value
        end

        def remove name
            Vips::vips_image_remove self, name
        end

        # compatibility: old name for get
        def get_value name
            get name
        end

        # compatibility: old name for set
        def set_value name, value
            set name, value
        end

        def width
            get "width"
        end

        def height
            get "height"
        end

        def bands
            get "bands"
        end

        def format
            get "format"
        end

        def interpretation
            get "interpretation"
        end

        def coding
            get "coding"
        end

        def filename
            get "filename"
        end

        def xres
            get "xres"
        end

        def yres
            get "yres"
        end

        def self.new_partial
            Image.new Vips::vips_image_new
        end

        def self.new_from_file(name, opts = {})
            # very common, and Vips::vips_filename_get_filename will segv if we 
            # pass this
            if name == nil
                raise Vips::Error, "filename is nil"
            end
            filename = Vips::vips_filename_get_filename name
            option_string = Vips::vips_filename_get_options name
            loader = Vips::vips_foreign_find_load filename
            if loader == nil
                raise Vips::Error
            end

            Operation::call loader, [filename, opts], option_string
        end

    end

end