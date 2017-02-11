from sqlalchemy import Column, Integer, String, Unicode
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()

archive_disc = 

class Archive(Base):
  __tablename__ = "archive"

  id = Column(Integer, primary_key = True)
  name = Column(Unicode(255))
  checksum = Column(String(64))

  def __repr__(self):
    return "Archive(id=%r, name=%r, checksum=%r)" % (self.id, self.name, self.checksum)

class Disc(Base):
  __tablename__ = "disc"

  id = Column(Integer, primary_key = True)
  volume_id = Column(Unicode(32))

  def __repr__(self):
    return "Disc(id=%r, volume_id=%r)" % (self.id, self.volume_id)

def init(engine):
  Base.metadata.create_all(engine)
