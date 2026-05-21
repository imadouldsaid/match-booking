from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware  # <-- Add this import
from sqlalchemy.orm import Session
from typing import List, Optional
from app import models
from app.database import SessionLocal, engine  # استيراد جلسة قاعدة البيانات والـ engine

# إنشاء الجداول في قاعدة البيانات إذا لم تكن موجودة
models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="Sports Match Booking API")

# ---- ADD THIS CORS BLOCK RIGHT HERE ----
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows your Flutter web app to connect
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
# ----------------------------------------
# دالة للحصول على جلسة قاعدة البيانات (Database Session) لكل طلب
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# --- 1. Endpoint جلب الملاعب بناءً على نوع الرياضة (المصحح) ---
@app.get("/courts", response_model=List[dict])
def get_courts(sport: Optional[str] = None, db: Session = Depends(get_db)):
    try:
        query = db.query(models.Court)
        
        if sport:
            # تم التعديل هنا إلى sport_type ليطابق عمود قاعدة البيانات بدقة
            query = query.filter(models.Court.sport_type == sport)
            
        courts = query.all()
        
        # تحويل النتيجة إلى قائمة من القواميس لتسهيل قراءتها في الفلاتر
        return [
            {
                "id": court.id,
                "name": court.name,
                "sport_type": court.sport_type,
                "price_per_hour": court.price_per_hour,
                "capacity": court.capacity,
                "location_url": court.location_url,
                "description": court.description,
                "main_image": court.main_image,
                "additional_images": court.additional_images
            }
            for court in courts
        ]
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Database error: {str(e)}"
        )

# --- 2. Endpoint تسجيل مستخدم جديد وحفظه تلقائياً ---
@app.post("/users/register", status_code=status.HTTP_201_CREATED)
def register_user(user_data: dict, db: Session = Depends(get_db)):
    try:
        # إنشاء كائن مستخدم جديد يطابق أعمدة جدول users لديك
        new_user = models.User(
            uid=user_data.get("uid"),
            username=user_data.get("username"),
            email=user_data.get("email"),
            role=user_data.get("role", "لاعب"), # تم تعديل القيمة الافتراضية إلى "لاعب" لتطابق واجهة فلاتر
            account_password=user_data.get("account_password")
        )
        
        db.add(new_user)
        db.commit()
        db.refresh(new_user)
        return {"status": "success", "message": "User registered successfully", "user_id": new_user.id}
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to register user: {str(e)}"
        )

# --- 3. Endpoint تسجيل الدخول والتحقق من الحساب (المضاف والمطابق لـ Flutter) ---
@app.post("/users/login")
def login_user(login_data: dict, db: Session = Depends(get_db)):
    # البحث عن المستخدم بواسطة البريد الإلكتروني الممرر من فلاتر
    user = db.query(models.User).filter(models.User.email == login_data.get("email")).first()
    
    # التحقق من وجود المستخدم ومطابقة كلمة المرور المتواجدة في عمود account_password
    if not user or user.account_password != login_data.get("password"):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="البريد الإلكتروني أو كلمة المرور غير صحيحة"
        )
    
    # إرجاع البيانات المطلوبة لـ Flutter للانتقال لصفحة الـ HomeScreen بنجاح
    return {
        "status": "success",
        "user": {
            "id": user.id,
            "uid": user.uid,
            "username": user.username,
            "email": user.email,
            "role": user.role
        }
    }

# --- 4. Endpoint إنشاء حجز جديد في القائمة تلقائياً ---
@app.post("/bookings/create", status_code=status.HTTP_201_CREATED) 
def create_booking(booking_data: dict, db: Session = Depends(get_db)):
    try:
        # إنشاء كائن حجز جديد يطابق أعمدة جدول bookings لديك
        new_booking = models.Booking(
            court_id=booking_data.get("court_id"),
            booking_date=booking_data.get("booking_date"), 
            booking_hour=booking_data.get("booking_hour")  
        )
        
        db.add(new_booking)
        db.commit()
        db.refresh(new_booking)
        return {"status": "success", "message": "Booking created successfully", "booking_id": new_booking.id}
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to create booking: {str(e)}"
        )