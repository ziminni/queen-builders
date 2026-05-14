# apps/users/serializers.py
from rest_framework import serializers
from .models import User

DIRECTORY_ROLES = ('projectManager', 'stockManager', 'cashier')


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'email', 'full_name', 'role', 'is_active', 'notes', 'created_at']
        read_only_fields = ['id', 'created_at']


class AdminDirectoryUserReadSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'email', 'full_name', 'role', 'is_active', 'notes', 'created_at']


class AdminDirectoryUserCreateSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=4)

    class Meta:
        model = User
        fields = ['email', 'full_name', 'password', 'role', 'is_active', 'notes']

    def validate_role(self, value):
        if value not in DIRECTORY_ROLES:
            raise serializers.ValidationError(
                'Role must be one of: project manager, stock manager, cashier.',
            )
        return value

    def validate_email(self, value):
        return value.strip().lower()

    def create(self, validated_data):
        return User.objects.create_user(**validated_data)


class AdminDirectoryUserUpdateSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, required=False, allow_blank=True)

    class Meta:
        model = User
        fields = ['email', 'full_name', 'role', 'is_active', 'notes', 'password']

    def validate_role(self, value):
        if value not in DIRECTORY_ROLES:
            raise serializers.ValidationError(
                'Role must be one of: project manager, stock manager, cashier.',
            )
        return value

    def validate_email(self, value):
        return value.strip().lower()

    def validate_password(self, value):
        if value and len(value) < 4:
            raise serializers.ValidationError('Use at least 4 characters.')
        return value

    def update(self, instance, validated_data):
        raw_password = validated_data.pop('password', '')
        raw_password = (raw_password or '').strip()
        user = super().update(instance, validated_data)
        if raw_password:
            user.set_password(raw_password)
            user.save(update_fields=['password'])
        return user


class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=6)
    
    class Meta:
        model = User
        fields = ['email', 'full_name', 'password', 'role']
    
    def create(self, validated_data):
        user = User.objects.create_user(**validated_data)
        return user