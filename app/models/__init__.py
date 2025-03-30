# Archivo __init__.py para el módulo models
# Este directorio contiene los modelos de datos de la aplicación

from app.models.database import init_database, get_db_connection

# Exponer clases principales para facilitar la importación
# Por ejemplo: from app.models import User, Teacher, Class

# Clases que representan las tablas de la base de datos
class User:
    """Representa un usuario del sistema"""
    def __init__(self, id=None, username=None, password_hash=None, email=None, role='user', is_active=True):
        self.id = id
        self.username = username
        self.password_hash = password_hash
        self.email = email
        self.role = role
        self.is_active = is_active
    
    @classmethod
    def from_row(cls, row):
        """Crea un objeto User a partir de una fila de base de datos"""
        if not row:
            return None
        return cls(
            id=row['id'],
            username=row['username'],
            password_hash=row['password_hash'],
            email=row['email'],
            role=row['role'],
            is_active=bool(row['is_active'])
        )

class Teacher:
    """Representa un profesor"""
    def __init__(self, id=None, first_name=None, last_name=None, email=None, phone=None, rate_per_class=0, is_active=True):
        self.id = id
        self.first_name = first_name
        self.last_name = last_name
        self.email = email
        self.phone = phone
        self.rate_per_class = rate_per_class
        self.is_active = is_active
    
    @property
    def full_name(self):
        """Devuelve el nombre completo del profesor"""
        return f"{self.first_name} {self.last_name}"
    
    @classmethod
    def from_row(cls, row):
        """Crea un objeto Teacher a partir de una fila de base de datos"""
        if not row:
            return None
        return cls(
            id=row['id'],
            first_name=row['first_name'],
            last_name=row['last_name'],
            email=row['email'],
            phone=row['phone'],
            rate_per_class=row['rate_per_class'],
            is_active=bool(row['is_active'])
        )

class Class:
    """Representa un tipo de clase (Ej: RIDE, MOVE, BOX)"""
    def __init__(self, id=None, name=None, description=None, class_type='OTHER'):
        self.id = id
        self.name = name
        self.description = description
        self.class_type = class_type
    
    @classmethod
    def from_row(cls, row):
        """Crea un objeto Class a partir de una fila de base de datos"""
        if not row:
            return None
        return cls(
            id=row['id'],
            name=row['name'],
            description=row['description'],
            class_type=row['class_type']
        )

class Schedule:
    """Representa un horario de clase programado regularmente"""
    def __init__(self, id=None, class_id=None, teacher_id=None, day_of_week=0, start_time=None, 
                 duration=60, max_capacity=20, is_active=True):
        self.id = id
        self.class_id = class_id
        self.teacher_id = teacher_id
        self.day_of_week = day_of_week
        self.start_time = start_time
        self.duration = duration
        self.max_capacity = max_capacity
        self.is_active = is_active
        
        # Propiedades que pueden ser cargadas bajo demanda
        self._class = None
        self._teacher = None
    
    @property
    def class_obj(self):
        """Devuelve el objeto Class asociado (cargado bajo demanda)"""
        return self._class
    
    @class_obj.setter
    def class_obj(self, value):
        self._class = value
    
    @property
    def teacher(self):
        """Devuelve el objeto Teacher asociado (cargado bajo demanda)"""
        return self._teacher
    
    @teacher.setter
    def teacher(self, value):
        self._teacher = value
    
    @classmethod
    def from_row(cls, row):
        """Crea un objeto Schedule a partir de una fila de base de datos"""
        if not row:
            return None
        return cls(
            id=row['id'],
            class_id=row['class_id'],
            teacher_id=row['teacher_id'],
            day_of_week=row['day_of_week'],
            start_time=row['start_time'],
            duration=row['duration'],
            max_capacity=row['max_capacity'],
            is_active=bool(row['is_active'])
        )

class Attendance:
    """Representa una clase realizada"""
    def __init__(self, id=None, schedule_id=None, teacher_id=None, class_date=None,
                 arrival_time=None, students_count=0, notes=None, audio_file=None):
        self.id = id
        self.schedule_id = schedule_id
        self.teacher_id = teacher_id
        self.class_date = class_date
        self.arrival_time = arrival_time
        self.students_count = students_count
        self.notes = notes
        self.audio_file = audio_file
        
        # Propiedades que pueden ser cargadas bajo demanda
        self._schedule = None
        self._teacher = None
    
    @property
    def schedule(self):
        """Devuelve el objeto Schedule asociado (cargado bajo demanda)"""
        return self._schedule
    
    @schedule.setter
    def schedule(self, value):
        self._schedule = value
    
    @property
    def teacher(self):
        """Devuelve el objeto Teacher asociado (cargado bajo demanda)"""
        return self._teacher
    
    @teacher.setter
    def teacher(self, value):
        self._teacher = value
    
    @classmethod
    def from_row(cls, row):
        """Crea un objeto Attendance a partir de una fila de base de datos"""
        if not row:
            return None
        return cls(
            id=row['id'],
            schedule_id=row['schedule_id'],
            teacher_id=row['teacher_id'],
            class_date=row['class_date'],
            arrival_time=row['arrival_time'],
            students_count=row['students_count'],
            notes=row['notes'],
            audio_file=row['audio_file']
        ) 