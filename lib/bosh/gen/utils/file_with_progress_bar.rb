require "progressbar"
# f = FileWithProgressBar.open(file, 'r')
# f.out = $stdout
#
# Then pass f like any File object that invokes f.read
#
# To upload with Fog:
# d = Storage[:aws].directories.create(key: 'drnic-test-upload')
# d.files.create(key: 'test.tgz', body: f)
# redis-2.8.12.: 100% |oooooooooooooo|   1.2MB 243.4KB/s Time: 00:00:04
class FileWithProgressBar < ::File

  def out=(out)
    @out = out
  end

  def progress_bar
    return @progress_bar if @progress_bar
    @out ||= StringIO.new
    @progress_bar = ProgressBar.new(file_name, size, @out)
    @progress_bar.file_transfer_mode
    @progress_bar
  end

  def file_name
    File.basename(self.path)
  end

  def stop_progress_bar
    progress_bar.halt unless progress_bar.finished?
  end

  def size
    @size || File.size(self.path)
  end

  def size=(size)
    @size=size
  end

  def read(*args)
    result = super(*args)

    if result && result.size > 0
      progress_bar.inc(result.size)
    else
      progress_bar.finish
    end

    result
  end

  def write(*args)
    count = super(*args)
    if count
      progress_bar.inc(count)
    else
      progress_bar.finish
    end
    count
  end
end
