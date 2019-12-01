require 'spec_helper.rb'

RSpec.describe Vips::Streami do
  #Vips.set_debug true

  if Vips::at_least_libvips?(8, 9)
    it 'can create a stream from a descriptor' do
      stream = Vips::Streami.new_from_descriptor(0)

      expect(stream)
    end

    it 'can create a stream from a filename' do
      stream = Vips::Streami.new_from_file simg('wagon.jpg')

      expect(stream)
    end

    it 'can create a stream from an area of memory' do
      str = File.open(simg('wagon.jpg'), 'rb').read
      stream = Vips::Streami.new_from_memory str

      expect(stream)
    end

    it 'streams have filenames and nicks' do
      stream = Vips::Streami.new_from_file simg('wagon.jpg')

      expect(stream.filename).to eq(simg('wagon.jpg'))
      expect(stream.nick)
    end

    it 'can load an image from filename stream' do
      stream = Vips::Streami.new_from_file simg('wagon.jpg')
      image = Vips::Image.new_from_stream stream, ''

      expect(image)
      expect(image.width).to eq(685)
      expect(image.height).to eq(478)
      expect(image.bands).to eq(3)
      #expect(image.avg).to be_within(0.001).of(109.789)
    end

  end
end
