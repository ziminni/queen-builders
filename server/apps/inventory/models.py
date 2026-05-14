from django.conf import settings
from django.db import models


class Supplier(models.Model):
    code = models.CharField(max_length=64, unique=True)
    name = models.CharField(max_length=255)
    contact = models.CharField(max_length=128)
    email = models.EmailField(blank=True, null=True)
    address = models.TextField(blank=True, null=True)
    payment_terms = models.CharField(max_length=128, default="Net 30")
    lead_time_days = models.PositiveIntegerField(default=3)
    categories = models.JSONField(default=list, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["code"]

    def __str__(self):
        return f"{self.code} — {self.name}"


class Product(models.Model):
    item_code = models.CharField(max_length=128)
    name = models.CharField(max_length=255)
    description = models.TextField(blank=True, default="")
    category = models.CharField(max_length=128, blank=True, default="")
    subcategory = models.CharField(max_length=128, blank=True, default="")
    brand = models.CharField(max_length=128, blank=True, default="")
    specifications = models.TextField(blank=True, default="")
    unit = models.CharField(max_length=64, blank=True, default="unit")
    cost_price = models.FloatField(default=0)
    markup_percent = models.FloatField(default=0)
    selling_price = models.FloatField(default=0)
    stock = models.PositiveIntegerField(default=0)
    reorder_level = models.PositiveIntegerField(default=20)
    reorder_quantity = models.PositiveIntegerField(default=50)
    supplier = models.CharField(max_length=255, blank=True, default="")
    supplier_code = models.CharField(max_length=64, blank=True, null=True)
    batch_number = models.CharField(max_length=128, blank=True, null=True)
    expiry_date = models.CharField(max_length=64, blank=True, null=True)
    location = models.CharField(max_length=255, blank=True, null=True)
    barcode = models.CharField(max_length=128, blank=True, null=True)
    taxable = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["name"]
        constraints = [
            models.UniqueConstraint(
                fields=["item_code"],
                name="inventory_product_item_code_unique",
            ),
        ]

    def __str__(self):
        return f"{self.item_code} — {self.name}"


class StockReceipt(models.Model):
    """One supplier receipt / delivery batch (summary row for the inventory UI)."""

    received_at = models.DateTimeField(auto_now_add=True)
    supplier_name = models.CharField(max_length=255, blank=True, default="")
    supplier_code = models.CharField(max_length=64, blank=True, null=True)
    warehouse_location = models.CharField(max_length=255, blank=True, default="")
    invoice_number = models.CharField(max_length=128, blank=True, default="")
    received_by = models.CharField(max_length=255, blank=True, default="")
    notes = models.TextField(blank=True, default="")
    line_count = models.PositiveIntegerField(default=0)
    total_units = models.PositiveIntegerField(default=0)
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="stock_receipts",
    )

    class Meta:
        ordering = ["-received_at"]

    def __str__(self):
        return f"Receipt {self.id} · {self.supplier_name} · {self.total_units} u"


class StockReceiptLine(models.Model):
    receipt = models.ForeignKey(
        StockReceipt,
        on_delete=models.CASCADE,
        related_name="lines",
    )
    product = models.ForeignKey(
        Product,
        on_delete=models.CASCADE,
        related_name="receipt_lines",
    )
    quantity = models.PositiveIntegerField()


class Sale(models.Model):
    """Point-of-sale order; stock is deducted from [Product]."""

    created_at = models.DateTimeField(auto_now_add=True)
    subtotal = models.DecimalField(max_digits=12, decimal_places=2)
    tax = models.DecimalField(max_digits=12, decimal_places=2)
    total = models.DecimalField(max_digits=12, decimal_places=2)
    items_count = models.PositiveIntegerField(default=0)
    payment_method = models.CharField(max_length=64)
    is_pay_later = models.BooleanField(default=False)
    customer_name = models.CharField(max_length=255, blank=True, default="")
    customer_phone = models.CharField(max_length=64, blank=True, default="")
    customer_address = models.TextField(blank=True, default="")

    class Meta:
        ordering = ["-created_at"]

    def __str__(self):
        return f"Sale {self.id} · ₱{self.total}"


class SaleLine(models.Model):
    """One line on a sale; [product] FK is source of truth — only price/name snapshotted."""

    sale = models.ForeignKey(Sale, on_delete=models.CASCADE, related_name="lines")
    product = models.ForeignKey(
        Product,
        on_delete=models.PROTECT,
        related_name="sale_lines",
    )
    quantity = models.PositiveIntegerField()
    unit_price = models.DecimalField(max_digits=12, decimal_places=2)
    line_subtotal = models.DecimalField(max_digits=12, decimal_places=2)
    product_name = models.CharField(max_length=255)

    class Meta:
        ordering = ["id"]
