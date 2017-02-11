import logging
from archiveman import models
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

class Database(object):
  def __init__(self, location):
    self.logger = logging.getLogger("archiveman.database")
    self.engine = create_engine(location)
    self.make_session = sessionmaker(bind = self.engine)

    models.init(self.engine)
