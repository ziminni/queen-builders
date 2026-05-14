from rest_framework import serializers

from .models import Project


class ProjectSerializer(serializers.ModelSerializer):
    budgetAllocated = serializers.SerializerMethodField()
    startDate = serializers.DateField(source="start_date")
    progressLogs = serializers.JSONField(source="progress_logs", required=False)

    class Meta:
        model = Project
        fields = (
            "id",
            "name",
            "client",
            "foreman",
            "status",
            "location",
            "progress",
            "budgetAllocated",
            "startDate",
            "deadline",
            "materials",
            "expenses",
            "progressLogs",
            "issues",
            "comments",
        )
        read_only_fields = ("id",)

    def get_budgetAllocated(self, obj):
        return {
            "materials": float(obj.budget_materials),
            "labor": float(obj.budget_labor),
            "equipment": float(obj.budget_equipment),
        }

    def to_internal_value(self, data):
        mutable = dict(data)
        budget = mutable.pop("budgetAllocated", {}) or {}
        mutable["budget_materials"] = budget.get("materials", 0)
        mutable["budget_labor"] = budget.get("labor", 0)
        mutable["budget_equipment"] = budget.get("equipment", 0)
        return super().to_internal_value(mutable)

    def create(self, validated_data):
        budget = self.initial_data.get("budgetAllocated", {}) or {}
        validated_data["budget_materials"] = budget.get("materials", 0)
        validated_data["budget_labor"] = budget.get("labor", 0)
        validated_data["budget_equipment"] = budget.get("equipment", 0)
        validated_data.setdefault("materials", [])
        validated_data.setdefault("expenses", [])
        validated_data.setdefault("progress_logs", [])
        validated_data.setdefault("issues", [])
        validated_data.setdefault("comments", [])
        return super().create(validated_data)

    def update(self, instance, validated_data):
        budget = self.initial_data.get("budgetAllocated")
        if budget is not None:
            validated_data["budget_materials"] = budget.get("materials", 0)
            validated_data["budget_labor"] = budget.get("labor", 0)
            validated_data["budget_equipment"] = budget.get("equipment", 0)
        return super().update(instance, validated_data)
