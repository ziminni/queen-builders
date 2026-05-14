from django.db.models import Max
from rest_framework import serializers

from .models import Product, Sale, StockReceipt, StockReceiptLine, Supplier


class SupplierSerializer(serializers.ModelSerializer):
    paymentTerms = serializers.CharField(source="payment_terms")
    leadTimeDays = serializers.IntegerField(source="lead_time_days", min_value=0)
    categories = serializers.ListField(
        child=serializers.CharField(allow_blank=False),
        allow_empty=False,
    )

    class Meta:
        model = Supplier
        fields = (
            "id",
            "code",
            "name",
            "contact",
            "email",
            "address",
            "paymentTerms",
            "leadTimeDays",
            "categories",
        )
        read_only_fields = ("id",)

    def validate_code(self, value):
        code = value.strip().upper()
        if not code:
            raise serializers.ValidationError("Supplier code is required.")
        return code

    def validate_name(self, value):
        name = value.strip()
        if not name:
            raise serializers.ValidationError("Supplier name is required.")
        return name

    def validate_contact(self, value):
        contact = value.strip()
        if not contact:
            raise serializers.ValidationError("Contact is required.")
        return contact

    def validate_categories(self, value):
        categories = [v.strip() for v in value if v.strip()]
        if not categories:
            raise serializers.ValidationError("At least one category is required.")
        return categories


class ProductSerializer(serializers.ModelSerializer):
    """JSON field names match the Flutter `Product` model (camelCase)."""

    itemCode = serializers.CharField(
        source="item_code", allow_blank=True, required=False, default=""
    )
    costPrice = serializers.FloatField(source="cost_price")
    markupPercent = serializers.FloatField(source="markup_percent")
    sellingPrice = serializers.FloatField(source="selling_price")
    reorderLevel = serializers.IntegerField(
        source="reorder_level", required=False, default=20
    )
    reorderQuantity = serializers.IntegerField(
        source="reorder_quantity", required=False, default=50
    )
    supplierCode = serializers.CharField(
        source="supplier_code", allow_null=True, required=False, allow_blank=True
    )
    batchNumber = serializers.CharField(
        source="batch_number", allow_null=True, required=False, allow_blank=True
    )
    expiryDate = serializers.CharField(
        source="expiry_date", allow_null=True, required=False, allow_blank=True
    )
    location = serializers.CharField(
        allow_null=True, required=False, allow_blank=True
    )
    barcode = serializers.CharField(
        allow_null=True, required=False, allow_blank=True
    )
    supplier = serializers.CharField(allow_blank=True, required=False, default="")

    class Meta:
        model = Product
        fields = (
            "id",
            "itemCode",
            "name",
            "description",
            "category",
            "subcategory",
            "brand",
            "specifications",
            "unit",
            "costPrice",
            "markupPercent",
            "sellingPrice",
            "stock",
            "reorderLevel",
            "reorderQuantity",
            "supplier",
            "supplierCode",
            "batchNumber",
            "expiryDate",
            "location",
            "barcode",
            "taxable",
        )
        read_only_fields = ("id", "stock")

    def create(self, validated_data):
        code = (validated_data.get("item_code") or "").strip()
        if not code:
            next_id = (Product.objects.aggregate(m=Max("id"))["m"] or 0) + 1
            validated_data["item_code"] = f"SKU-{next_id}"
        else:
            validated_data["item_code"] = code
        validated_data.setdefault("stock", 0)
        validated_data.setdefault("supplier", "")
        return super().create(validated_data)


class ProductPatchSerializer(serializers.ModelSerializer):
    """Partial catalog update; does not change stock."""

    itemCode = serializers.CharField(
        source="item_code", required=False, allow_blank=True
    )
    costPrice = serializers.FloatField(source="cost_price", required=False)
    markupPercent = serializers.FloatField(source="markup_percent", required=False)
    sellingPrice = serializers.FloatField(source="selling_price", required=False)
    unit = serializers.CharField(required=False, allow_blank=True)
    supplierCode = serializers.CharField(
        source="supplier_code", required=False, allow_null=True, allow_blank=True
    )
    batchNumber = serializers.CharField(
        source="batch_number", required=False, allow_null=True, allow_blank=True
    )
    expiryDate = serializers.CharField(
        source="expiry_date", required=False, allow_null=True, allow_blank=True
    )

    class Meta:
        model = Product
        fields = (
            "itemCode",
            "name",
            "description",
            "category",
            "subcategory",
            "brand",
            "specifications",
            "unit",
            "costPrice",
            "markupPercent",
            "sellingPrice",
            "supplierCode",
            "batchNumber",
            "expiryDate",
            "location",
            "barcode",
            "taxable",
        )

    def update(self, instance, validated_data):
        code = validated_data.pop("item_code", serializers.empty)
        if code is not serializers.empty:
            c = (code or "").strip()
            if c:
                validated_data["item_code"] = c
        return super().update(instance, validated_data)


class DeliveryItemSerializer(serializers.Serializer):
    productId = serializers.IntegerField(min_value=1)
    quantity = serializers.IntegerField(min_value=1)


class ReceiveDeliverySerializer(serializers.Serializer):
    supplierName = serializers.CharField(allow_blank=True, required=False, default="")
    supplierCode = serializers.CharField(
        allow_blank=True, required=False, allow_null=True, default=None
    )
    warehouseLocation = serializers.CharField(
        allow_blank=True, required=False, default=""
    )
    invoiceNumber = serializers.CharField(allow_blank=True, required=False, default="")
    receivedBy = serializers.CharField(allow_blank=True, required=False, default="")
    notes = serializers.CharField(allow_blank=True, required=False, default="")
    items = DeliveryItemSerializer(many=True)

    def validate_items(self, value):
        if not value:
            raise serializers.ValidationError("At least one line item is required.")
        return value


class StockReceiptSerializer(serializers.ModelSerializer):
    supplierName = serializers.CharField(source="supplier_name", read_only=True)
    warehouseLocation = serializers.CharField(
        source="warehouse_location", read_only=True
    )
    lineCount = serializers.IntegerField(source="line_count", read_only=True)
    totalUnits = serializers.IntegerField(source="total_units", read_only=True)
    receivedAt = serializers.DateTimeField(source="received_at", read_only=True)
    receivedBy = serializers.CharField(source="received_by", read_only=True)

    class Meta:
        model = StockReceipt
        fields = (
            "supplierName",
            "warehouseLocation",
            "receivedBy",
            "lineCount",
            "totalUnits",
            "receivedAt",
        )


# --- POS checkout (uses inventory Product FK; no duplicate catalog) ---


class PosLineInSerializer(serializers.Serializer):
    productId = serializers.IntegerField(min_value=1)
    quantity = serializers.IntegerField(min_value=1)


class PosCheckoutSerializer(serializers.Serializer):
    lines = PosLineInSerializer(many=True)
    paymentMethod = serializers.CharField(max_length=64)
    isPayLater = serializers.BooleanField(default=False)
    customerName = serializers.CharField(
        allow_blank=True, required=False, default=""
    )
    customerPhone = serializers.CharField(
        allow_blank=True, required=False, default=""
    )
    customerAddress = serializers.CharField(
        allow_blank=True, required=False, default=""
    )

    def validate_lines(self, value):
        if not value:
            raise serializers.ValidationError("Cart must contain at least one line.")
        return value


class SaleOutSerializer(serializers.ModelSerializer):
    """Shape matches Flutter `Transaction.fromJson` (camelCase)."""

    timestamp = serializers.DateTimeField(source="created_at", read_only=True)
    items = serializers.IntegerField(source="items_count", read_only=True)
    paymentMethod = serializers.CharField(source="payment_method", read_only=True)
    isPayLater = serializers.BooleanField(source="is_pay_later", read_only=True)
    paidAt = serializers.DateTimeField(source="paid_at", read_only=True)
    customerName = serializers.CharField(source="customer_name", read_only=True)
    customerPhone = serializers.CharField(source="customer_phone", read_only=True)
    customerAddress = serializers.CharField(source="customer_address", read_only=True)
    itemDetails = serializers.SerializerMethodField()
    id = serializers.SerializerMethodField()
    total = serializers.SerializerMethodField()
    subtotal = serializers.SerializerMethodField()
    tax = serializers.SerializerMethodField()

    class Meta:
        model = Sale
        fields = (
            "id",
            "timestamp",
            "items",
            "subtotal",
            "tax",
            "total",
            "paymentMethod",
            "itemDetails",
            "isPayLater",
            "paidAt",
            "customerName",
            "customerPhone",
            "customerAddress",
        )

    def get_id(self, obj):
        return f"POS-{obj.pk}"

    def get_total(self, obj):
        return float(obj.total)

    def get_subtotal(self, obj):
        return float(obj.subtotal)

    def get_tax(self, obj):
        return float(obj.tax)

    def get_itemDetails(self, obj):
        return [
            {
                "name": line.product_name,
                "quantity": line.quantity,
                "price": float(line.unit_price),
            }
            for line in obj.lines.all()
        ]
