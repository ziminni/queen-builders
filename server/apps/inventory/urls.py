from django.urls import path

from .views import (
    PosCheckoutStockView,
    PosSaleMarkPaidView,
    PosSaleListView,
    ProductDetailView,
    ProductListCreateView,
    ReceiveDeliveryView,
    StockReceiptListView,
    SupplierListCreateView,
)

urlpatterns = [
    path("products/", ProductListCreateView.as_view(), name="inventory-products"),
    path("products/<int:pk>/", ProductDetailView.as_view(), name="inventory-product-detail"),
    path("suppliers/", SupplierListCreateView.as_view(), name="inventory-suppliers"),
    path("deliveries/", StockReceiptListView.as_view(), name="inventory-deliveries"),
    path("deliveries/receive/", ReceiveDeliveryView.as_view(), name="inventory-receive"),
    path("pos/checkout/", PosCheckoutStockView.as_view(), name="pos-checkout"),
    path("pos/sales/", PosSaleListView.as_view(), name="pos-sales"),
    path("pos/sales/<int:pk>/mark-paid/", PosSaleMarkPaidView.as_view(), name="pos-sale-mark-paid"),
]
