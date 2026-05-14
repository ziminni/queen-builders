# apps/users/admin_directory_views.py
from rest_framework import generics
from rest_framework.permissions import IsAuthenticated

from .models import User
from .permissions import IsAdmin
from .serializers import (
    DIRECTORY_ROLES,
    AdminDirectoryUserReadSerializer,
    AdminDirectoryUserCreateSerializer,
    AdminDirectoryUserUpdateSerializer,
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


class AdminDirectoryUserDetailView(generics.RetrieveUpdateDestroyAPIView):
    permission_classes = [IsAuthenticated, IsAdmin]
    lookup_field = 'pk'

    def get_queryset(self):
        return User.objects.filter(role__in=DIRECTORY_ROLES)

    def get_serializer_class(self):
        if self.request.method in ('PUT', 'PATCH'):
            return AdminDirectoryUserUpdateSerializer
        return AdminDirectoryUserReadSerializer
