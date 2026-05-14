from django.urls import path

from .admin_directory_views import (
    AdminDirectoryUserDetailView,
    AdminDirectoryUserListCreateView,
)

urlpatterns = [
    path(
        'directory-users/',
        AdminDirectoryUserListCreateView.as_view(),
        name='admin-directory-users',
    ),
    path(
        'directory-users/<int:pk>/',
        AdminDirectoryUserDetailView.as_view(),
        name='admin-directory-user-detail',
    ),
]
