# == Schema Information
#
# Table name: photos
#
#  id           :integer          not null, primary key
#  name         :string(255)
#  content_type :string(255)
#  sha1         :string(255)
#  md5          :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  width        :string(255)
#  height       :string(255)
#

class Photo < ApplicationRecord
  has_one :event

  validates_format_of :content_type, :with => /\Aimage/, :message => I18n.translate(:needs_to_be_a_picture)

  after_validation :validate_photo_size
  after_save :save_photo
  before_destroy :remove_photos

  def file=(file_field)
    unless file_field.nil? || file_field.size == 0
      Dir.mkdir("#{Rails.root}/tmp/photos") unless File.exist?("#{Rails.root}/tmp/photos")
      @temp_file_path = "#{Rails.root}/tmp/photos/#{create_hash}"
      FileUtils.move file_field.path, @temp_file_path
      content_type = `file -b --mime-type #{@temp_file_path}`
      self[:sha1] = Digest::SHA1.file(@temp_file_path).hexdigest
      self[:md5]  = Digest::MD5.file(@temp_file_path).hexdigest
      self[:content_type] = content_type.chop
      self[:name] = create_hash + '.' + 'jpg'
    end
  end

  def external_cache_path
    path
  end

  def external_cache_thumb_path
    thumb_path
  end

  def path
    "/photos/big/#{photo_date_path}/#{name}"
  end

  def thumb_path
    add_postfix("/photos/thumb/#{photo_date_path}/#{name}", '_thumb')
  end

  def url
    "https://www.wasgehtheuteab.de" + path
  end

  def thumb_url
    "https://www.wasgehtheuteab.de" + thumb_path
  end

  def add_postfix(path, postfix)
    parts = path.split('.')
    parts[-2] << postfix
    parts.join('.')
  end

  private
  def create_hash
    Digest::SHA1.hexdigest( Time.zone.now.to_s.split(//).sort_by {rand}.join )
  end

  def path_to_full_size
    "#{Rails.root}/public/photos/big/#{photo_date_path}/#{name}"
  end

  def path_to_thumb
    add_postfix("#{Rails.root}/public/photos/thumb/#{photo_date_path}/#{name}", '_thumb')
  end

  def save_photo
    if @temp_file_path

      Dir.mkdir("#{Rails.root}/public/photos") unless File.exist?("#{Rails.root}/public/photos")

      Dir.mkdir("#{Rails.root}/public/photos/thumb") unless File.exist?("#{Rails.root}/public/photos/thumb")
      Dir.mkdir("#{Rails.root}/public/photos/thumb/#{created_at.year}") unless File.exist?("#{Rails.root}/public/photos/thumb/#{created_at.year}")
      Dir.mkdir("#{Rails.root}/public/photos/thumb/#{created_at.year}/#{created_at.month}") unless File.exist?("#{Rails.root}/public/photos/thumb/#{created_at.year}/#{created_at.month}")
      Dir.mkdir("#{Rails.root}/public/photos/thumb/#{created_at.year}/#{created_at.month}/#{created_at.day}") unless File.exist?("#{Rails.root}/public/photos/thumb/#{created_at.year}/#{created_at.month}/#{created_at.day}")

      Dir.mkdir("#{Rails.root}/public/photos/big") unless File.exist?("#{Rails.root}/public/photos/big")
      Dir.mkdir("#{Rails.root}/public/photos/big/#{created_at.year}") unless File.exist?("#{Rails.root}/public/photos/big/#{created_at.year}")
      Dir.mkdir("#{Rails.root}/public/photos/big/#{created_at.year}/#{created_at.month}") unless File.exist?("#{Rails.root}/public/photos/big/#{created_at.year}/#{created_at.month}")
      Dir.mkdir("#{Rails.root}/public/photos/big/#{created_at.year}/#{created_at.month}/#{created_at.day}") unless File.exist?("#{Rails.root}/public/photos/big/#{created_at.year}/#{created_at.month}/#{created_at.day}")

      photo = MiniMagick::Image.open(@temp_file_path)
      photo.format('jpg')
      photo.combine_options do |c|
        c.colorspace "srgb"
      end

      if photo[:width] > photo[:height]
        if photo[:width] > 1170
          photo.resize "1170"
        end
      else
        if photo[:width] > 770
          photo.resize "770"
        end
      end

      photo.write(path_to_full_size)

      `jpegtran -copy none -optimize -progressive -outfile #{path_to_full_size + '.tmp'} #{path_to_full_size} && mv #{path_to_full_size + '.tmp'} #{path_to_full_size}`

      #Thumb erzeugen
      photo = MiniMagick::Image.open(@temp_file_path)
      photo.format('jpg')
      photo.resample(72)
      photo.combine_options do |c|
        c.colorspace "srgb"
      end
      if photo[:width] > photo[:height]
        # rectangle 16:9 flyer
        photo.resize "x295"

        if photo[:width] < 440
          photo = MiniMagick::Image.open(@temp_file_path)
          photo.format('jpg')
          photo.resample(72)
          photo.combine_options do |c|
            c.colorspace "srgb"
          end

          photo.resize "440"
          h = photo[:height]
          to_chop = h - 295
          to_chop = to_chop / 2

          if to_chop > 1
            photo.combine_options do |c|
              c.shave "0x#{to_chop.to_i}"
            end
          end
        else
          w = photo[:width]
          to_chop = w - 440
          to_chop = to_chop / 2

          if to_chop > 1
            photo.combine_options do |c|
              c.shave "#{to_chop.to_i}x0"
            end
          end
        end
      else
        # poster flyer
        photo.resize "440"
        h = photo[:height]
        to_chop = h - 295
        to_chop = to_chop / 2

        if to_chop > 1
          photo.combine_options do |c|
            c.shave "0x#{to_chop.to_i}"
          end
        end
      end

      photo.write(path_to_thumb)
      photo = MiniMagick::Image.open(path_to_thumb)
      if photo[:width] != 440 || photo[:height] != 295
        photo.resize "440x295!"
        photo.write(path_to_thumb)
      end

      `jpegtran -copy none -optimize -progressive -outfile #{path_to_thumb + '.tmp'} #{path_to_thumb} && mv #{path_to_thumb + '.tmp'} #{path_to_thumb}`

      FileUtils.rm @temp_file_path, :force => true
      @temp_file_path = nil # empty @temp_file_path so were not getting in a loop when saving again

      photo = MiniMagick::Image.open(path_to_full_size)
      self[:width] = photo[:width]
      self[:height] = photo[:height]
      self.save
    end
  end

  def remove_photos
    FileUtils.remove_dir(path_to_full_size, true) if File.exist?(path_to_full_size)
    FileUtils.remove_dir(path_to_thumb, true) if File.exist?(path_to_thumb)
  end

  def validate_photo_size
    return if !@temp_file_path

    photo = MiniMagick::Image.open(@temp_file_path)
    photo_width = photo[:width]
    photo = nil

    errors.add(:content_type, 'Der Flyer muss eine Mindestbreite von 250px haben.') if photo_width < 250
  end

  def photo_date_path
    "#{created_at.year}/#{created_at.month}/#{created_at.day}"
  end
end
