from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

# كتابة رابط الاتصال صراحة هنا لتفادي خطأ الـ UnicodeDecodeError أثناء قراءة ملف .env
DATABASE_URL = "postgresql://postgres:1234@localhost:5432/match-booking"

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()