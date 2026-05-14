from django.urls import path

from .views import ProjectDetailView, ProjectListCreateView


urlpatterns = [
    path("projects/", ProjectListCreateView.as_view(), name="projectm-projects"),
    path("projects/<int:pk>/", ProjectDetailView.as_view(), name="projectm-project-detail"),
]
