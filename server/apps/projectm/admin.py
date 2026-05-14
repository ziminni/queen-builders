from django.contrib import admin

from .models import Project


@admin.register(Project)
class ProjectAdmin(admin.ModelAdmin):
    list_display = ("id", "name", "client", "foreman", "status", "progress")
    list_filter = ("status",)
    search_fields = ("name", "client", "foreman", "location")
