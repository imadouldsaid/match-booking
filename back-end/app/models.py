from sqlalchemy import Column, Integer, String
from app.database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    uid = Column(String, unique=True, nullable=True, index=True) # لربطه بـ Firebase UID
    username = Column(String, unique=True, nullable=False)
    email = Column(String, unique=True, nullable=False)
    role = Column(String, nullable=False) # لاعب أو قائد فريق
    account_password = Column(String, nullable=False) # كلمة المرور المحلية للحساب