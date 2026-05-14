# apps/users/admin_directory_views.py
from rest_framework import generics
from rest_framework.permissions import IsAuthenticated

from .models import AuditLog, User
from .audit import record_audit
from .permissions import IsAdmin
from .serializers import (
    DIRECTORY_ROLES,
    AdminDirectoryUserReadSerializer,
    AdminDirectoryUserCreateSerializer,
    AdminDirectoryUserUpdateSerializer,
    AuditLogSerializer,
)


class AdminDirectoryUserListCreateView(generics.ListCreateAPIView):
    """List or create directory users (PM / stock / cashier). Admin only."""

    permission_classes = [IsAuthenticated, IsAdmin]

    def get_queryset(self):
        return User.objects.filter(role__in=DIRECTORY_ROLES).order_by('role', 'email')

    def get_serializer_class(self):
        if self.request.method == 'POST':
            return AdminDirectoryUserCreateSerializer
        return AdminDirectoryUserReadSerializer

    def perform_create(self, serializer):
        user = serializer.save()
        record_audit(
            module='Admin',
            category='User management',
            summary=f'User added: {user.full_name} · {user.get_role_display()}',
            detail=f'Email: {user.email}\nRole: {user.role}\nActive: {user.is_active}',
            actor=self.request.user,
        )


class AdminDirectoryUserDetailView(generics.RetrieveUpdateDestroyAPIView):
    permission_classes = [IsAuthenticated, IsAdmin]
    lookup_field = 'pk'

    def get_queryset(self):
        return User.objects.filter(role__in=DIRECTORY_ROLES)

    def get_serializer_class(self):
        if self.request.method in ('PUT', 'PATCH'):
            return AdminDirectoryUserUpdateSerializer
        return AdminDirectoryUserReadSerializer

    def perform_update(self, serializer):
        before = self.get_object()
        old = {
            'email': before.email,
            'full_name': before.full_name,
            'role': before.role,
            'is_active': before.is_active,
            'notes': before.notes,
        }
        user = serializer.save()
        changes = []
        if old['full_name'] != user.full_name:
            changes.append('name')
        if old['email'] != user.email:
            changes.append('email')
        if old['role'] != user.role:
            changes.append(f'role -> {user.get_role_display()}')
        if old['is_active'] != user.is_active:
            changes.append('activated' if user.is_active else 'deactivated')
        if old['notes'] != user.notes:
            changes.append('notes')
        if (self.request.data.get('password') or '').strip():
            changes.append('password reset')
        record_audit(
            module='Admin',
            category='User management',
            summary=f'User updated: {user.full_name} ({user.email})',
            detail='Changed: ' + ', '.join(changes) if changes else 'No field changes.',
            actor=self.request.user,
        )

    def perform_destroy(self, instance):
        record_audit(
            module='Admin',
            category='User management',
            summary=f'User removed from directory: {instance.full_name}',
            detail=f'Email: {instance.email}\nRole: {instance.get_role_display()}',
            actor=self.request.user,
        )
        instance.delete()


class AdminAuditLogListView(generics.ListAPIView):
    permission_classes = [IsAuthenticated, IsAdmin]
    serializer_class = AuditLogSerializer
    queryset = AuditLog.objects.all()
