import json
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from typing import List, Optional
from database import get_db
from routers.auth import get_current_user
from interpretations import build_interpretation
import models

router = APIRouter()

SPREAD_LABELS = {
    "1": ["Сейчас"],
    "3": ["Прошлое", "Настоящее", "Будущее"],
    "5": ["Основа", "Препятствие", "Прошлое", "Будущее", "Итог"],
}


class CardIn(BaseModel):
    num: str
    name: str
    keys: str
    reversed: bool

class ReadingCreate(BaseModel):
    question: Optional[str] = None
    spread_type: str
    cards: List[CardIn]

class ReadingOut(BaseModel):
    id: int
    question: Optional[str]
    spread_type: str
    cards_json: str
    interpretation: Optional[str]
    created_at: str
    class Config:
        from_attributes = True


@router.post("/", response_model=ReadingOut, status_code=201)
def create_reading(
    data: ReadingCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    if data.spread_type not in SPREAD_LABELS:
        raise HTTPException(status_code=400, detail="Неверный тип расклада")
    if len(data.cards) != int(data.spread_type):
        raise HTTPException(status_code=400, detail="Неверное количество карт")

    interpretation = build_interpretation(data.question, data.spread_type, data.cards)

    reading = models.Reading(
        user_id=current_user.id,
        question=data.question,
        spread_type=data.spread_type,
        cards_json=json.dumps([c.dict() for c in data.cards], ensure_ascii=False),
        interpretation=interpretation,
    )
    db.add(reading)
    db.commit()
    db.refresh(reading)

    reading.created_at = reading.created_at.isoformat()
    return reading


@router.get("/", response_model=List[ReadingOut])
def get_readings(
    skip: int = 0,
    limit: int = 20,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    readings = (
        db.query(models.Reading)
        .filter(models.Reading.user_id == current_user.id)
        .order_by(models.Reading.created_at.desc())
        .offset(skip).limit(limit).all()
    )
    for r in readings:
        r.created_at = r.created_at.isoformat()
    return readings


@router.get("/{reading_id}", response_model=ReadingOut)
def get_reading(
    reading_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    reading = db.query(models.Reading).filter(
        models.Reading.id == reading_id,
        models.Reading.user_id == current_user.id
    ).first()
    if not reading:
        raise HTTPException(status_code=404, detail="Расклад не найден")
    reading.created_at = reading.created_at.isoformat()
    return reading


@router.delete("/{reading_id}", status_code=204)
def delete_reading(
    reading_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    reading = db.query(models.Reading).filter(
        models.Reading.id == reading_id,
        models.Reading.user_id == current_user.id
    ).first()
    if not reading:
        raise HTTPException(status_code=404, detail="Расклад не найден")
    db.delete(reading)
    db.commit()
