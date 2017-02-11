import os.path
from archiveman import util

class Store(object):
  def __init__(self, dir):
    self.dir = dir

  def filename(self, archive):
    return os.path.join(self.dir, "archives", "{}.dat".format(archive.id))

  def contains(self, archive):
    return os.path.exists(self.filename(archive))

  def is_healthy(self, archive):
    return util.checksum_file(self.filename(archive)) == archive.checksum

  def copy_from(self, archive, source_filename):
    assert os.path.exists(source_filename)

    # Ensure destination directory exists.
    dest_filename = self.filename(archive)
    util.ensure_parent_dir(dest_filename)

    # Copy source to destination.
    cmd = ["cp", source_filename, dest_filename]
    with util.execute(cmd):
      pass

    # Change mode of file to read-only to prevent modification.
    # If the file were modified then our checksum would be invalidated.
    os.chmod(dest_filename, 0o444)

  def copy_to(self, archive, dest_filename):
    source_filename = self.filename(archive)
    assert os.path.exists(source_filename)

    # Ensure destination directory exists.
    util.ensure_parent_dir(dest_filename)

    # Copy source to destination.
    cmd = ["cp", source_filename, dest_filename]
    with util.execute(cmd):
      pass

    # Change mode of file to read-write.
    os.chmod(dest_filename, 0o644)
