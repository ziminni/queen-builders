from django.db import models


class Project(models.Model):
    name = models.CharField(max_length=255)
    client = models.CharField(max_length=255)
    foreman = models.CharField(max_length=255)
    status = models.CharField(max_length=64, default="Planning")
    location = models.CharField(max_length=255)
    progress = models.PositiveIntegerField(default=0)
    budget_materials = models.DecimalField(max_digits=14, decimal_places=2, default=0)
    budget_labor = models.DecimalField(max_digits=14, decimal_places=2, default=0)
    budget_equipment = models.DecimalField(max_digits=14, decimal_places=2, default=0)
    start_date = models.DateField()
    deadline = models.DateField()
    materials = models.JSONField(default=list, blank=True)
    expenses = models.JSONField(default=list, blank=True)
    progress_logs = models.JSONField(default=list, blank=True)
    issues = models.JSONField(default=list, blank=True)
    comments = models.JSONField(default=list, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["-created_at", "name"]

    def __str__(self):
        return self.name
