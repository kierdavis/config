class Copy(object):
  @classmethod
  def enumerate(_, archive, st):
    """Return all known copies of an archive."""
    if st.contains(archive):
      yield StoreCopy(archive, st)

class StoreCopy(object):
  """A copy of an archive present in the local store."""

  is_remote = False

  def __init__(self, archive, st):
    self.archive = archive
    self.st = st

  @property
  def is_healthy(self):
    return self.st.is_healthy(self.archive)

  @property
  def filename(self):
    return self.st.filename(self.archive)
