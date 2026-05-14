# apps/users/models.py
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin
from django.db import models

class UserManager(BaseUserManager):
    def create_user(self, email, password=None, **extra_fields):
        if not email:
            raise ValueError('Email is required')
        email = self.normalize_email(email)
        user = self.model(email=email, **extra_fields)
        user.set_password(password)
        user.save()
        return user

    def create_superuser(self, email, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        extra_fields.setdefault('role', 'admin')
        return self.create_user(email, password, **extra_fields)

class User(AbstractBaseUser, PermissionsMixin):
    ROLE_CHOICES = (
        ('admin', 'Admin'),
        ('stockManager', 'Stock Manager'),
        ('cashier', 'Cashier'),
        ('projectManager', 'Project Manager'),
        ('staff', 'Staff'),
    )
    
    email = models.EmailField(unique=True)
    full_name = models.CharField(max_length=255)
    role = models.CharField(max_length=20, choices=ROLE_CHOICES, default='staff')
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)
    notes = models.TextField(blank=True, default='')
    created_at = models.DateTimeField(auto_now_add=True)
    
    objects = UserManager()
    
    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['full_name']
    
    def __str__(self):
        return f"{self.email} ({self.role})"


class AuditLog(models.Model):
    at = models.DateTimeField(auto_now_add=True)
    module = models.CharField(max_length=64)
    category = models.CharField(max_length=128)
    summary = models.CharField(max_length=255)
    detail = models.TextField(blank=True, default='')
    actor_email = models.EmailField(blank=True, default='')
    actor_role = models.CharField(max_length=64, blank=True, default='')

    class Meta:
        ordering = ['-at']

    def __str__(self):
        return f"{self.at:%Y-%m-%d %H:%M} · {self.module} · {self.summary}"
