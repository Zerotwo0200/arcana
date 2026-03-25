from sqlalchemy import Column, Integer, String, Text, DateTime, ForeignKey, Boolean
from sqlalchemy.orm import relationship
from datetime import datetime
from database import Base

class User(Base):
    __tablename__ = "users"
    id       = Column(Integer, primary_key=True, index=True)
    email    = Column(String, unique=True, index=True, nullable=False)
    password = Column(String, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    readings = relationship("Reading", back_populates="user")

class Reading(Base):
    __tablename__ = "readings"
    id           = Column(Integer, primary_key=True, index=True)
    user_id      = Column(Integer, ForeignKey("users.id"), nullable=False)
    question     = Column(Text, nullable=True)
    spread_type  = Column(String, nullable=False)   # "1", "3", "5"
    cards_json   = Column(Text, nullable=False)     # JSON-строка с картами
    interpretation = Column(Text, nullable=True)    # ответ Claude
    created_at   = Column(DateTime, default=datetime.utcnow)
    user         = relationship("User", back_populates="readings")
