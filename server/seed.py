# apps/users/seed.py
import os
import django

# Set up Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from users.models import User

def seed_users():
    """Create test users with different roles"""
    
    users_data = [
        {
            'email': 'admin@example.com',
            'full_name': 'Admin User',
            'password': 'admin123',
            'role': 'admin',
            'is_staff': True,
            'is_superuser': True
        },
        {
            'email': 'manager@example.com',
            'full_name': 'Manager User',
            'password': 'manager123',
            'role': 'manager',
            'is_staff': True,
            'is_superuser': False
        },
        {
            'email': 'cashier@example.com',
            'full_name': 'Cashier User',
            'password': 'cashier123',
            'role': 'cashier',
            'is_staff': False,
            'is_superuser': False
        },
        {
            'email': 'supervisor@example.com',
            'full_name': 'Project Supervisor',
            'password': 'supervisor123',
            'role': 'project_supervisor',
            'is_staff': False,
            'is_superuser': False
        },
        {
            'email': 'staff@example.com',
            'full_name': 'Staff User',
            'password': 'staff123',
            'role': 'staff',
            'is_staff': False,
            'is_superuser': False
        },
    ]
    
    created_count = 0
    existing_count = 0
    
    for user_data in users_data:
        email = user_data['email']
        
        # Check if user already exists
        if not User.objects.filter(email=email).exists():
            if user_data['role'] == 'admin':
                User.objects.create_superuser(
                    email=user_data['email'],
                    full_name=user_data['full_name'],
                    password=user_data['password'],
                    role=user_data['role']
                )
            else:
                User.objects.create_user(
                    email=user_data['email'],
                    full_name=user_data['full_name'],
                    password=user_data['password'],
                    role=user_data['role']
                )
            created_count += 1
            print(f"✅ Created: {email} ({user_data['role']})")
        else:
            existing_count += 1
            print(f"⚠️  Already exists: {email}")
    
    print(f"\n📊 Summary: {created_count} users created, {existing_count} already existed")

def delete_all_users():
    """Delete all non-superuser users (useful for reseeding)"""
    deleted_count, _ = User.objects.exclude(role='admin').delete()
    print(f"🗑️  Deleted {deleted_count} non-admin users")
    return deleted_count

if __name__ == "__main__":
    import sys
    
    if len(sys.argv) > 1 and sys.argv[1] == '--delete':
        delete_all_users()
    
    seed_users()