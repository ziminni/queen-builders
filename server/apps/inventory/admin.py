from django.contrib import admin

from .models import Product, Sale, SaleLine, StockReceipt, StockReceiptLine, Supplier


class SaleLineInline(admin.TabularInline):
    model = SaleLine
    extra = 0
    readonly_fields = ("product", "quantity", "unit_price", "line_subtotal", "product_name")


@admin.register(Sale)
class SaleAdmin(admin.ModelAdmin):
    list_display = ("id", "created_at", "total", "payment_method", "is_pay_later", "items_count")
    list_filter = ("is_pay_later", "payment_method")
    inlines = [SaleLineInline]


@admin.register(Product)
class ProductAdmin(admin.ModelAdmin):
    list_display = ("id", "item_code", "name", "category", "stock", "supplier")
    search_fields = ("item_code", "name", "brand")


@admin.register(Supplier)
class SupplierAdmin(admin.ModelAdmin):
    list_display = ("code", "name", "contact", "payment_terms", "lead_time_days")
    search_fields = ("code", "name", "contact", "email")


class StockReceiptLineInline(admin.TabularInline):
    model = StockReceiptLine
    extra = 0


@admin.register(StockReceipt)
class StockReceiptAdmin(admin.ModelAdmin):
    list_display = ("id", "received_at", "supplier_name", "line_count", "total_units")
    inlines = [StockReceiptLineInline]
