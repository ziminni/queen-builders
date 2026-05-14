from decimal import Decimal

from django.db import transaction
from django.utils import timezone
from rest_framework import generics, status
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import Product, Sale, SaleLine, StockReceipt, StockReceiptLine, Supplier
from .serializers import (
    PosCheckoutSerializer,
    ProductPatchSerializer,
    ProductSerializer,
    ReceiveDeliverySerializer,
    SaleOutSerializer,
    StockReceiptSerializer,
    SupplierSerializer,
)


class ProductListCreateView(generics.ListCreateAPIView):
    authentication_classes = []
    queryset = Product.objects.all()
    permission_classes = [AllowAny]
    serializer_class = ProductSerializer


class SupplierListCreateView(generics.ListCreateAPIView):
    authentication_classes = []
    queryset = Supplier.objects.all()
    permission_classes = [AllowAny]
    serializer_class = SupplierSerializer


class ProductDetailView(generics.RetrieveUpdateDestroyAPIView):
    authentication_classes = []
    queryset = Product.objects.all()
    permission_classes = [AllowAny]
    http_method_names = ["get", "patch", "delete", "head", "options"]

    def get_serializer_class(self):
        if self.request.method == "PATCH":
            return ProductPatchSerializer
        return ProductSerializer


class ReceiveDeliveryView(APIView):
    authentication_classes = []
    permission_classes = [AllowAny]

    def post(self, request):
        ser = ReceiveDeliverySerializer(data=request.data)
        ser.is_valid(raise_exception=True)
        data = ser.validated_data
        lines = data["items"]
        qty_by_product = {}
        for it in lines:
            pid = it["productId"]
            qty_by_product[pid] = qty_by_product.get(pid, 0) + it["quantity"]

        supplier_name = (data.get("supplierName") or "").strip()
        supplier_code = data.get("supplierCode")
        if isinstance(supplier_code, str):
            supplier_code = supplier_code.strip() or None
        warehouse_location = (data.get("warehouseLocation") or "").strip()

        with transaction.atomic():
            receipt = StockReceipt.objects.create(
                supplier_name=supplier_name,
                supplier_code=supplier_code,
                warehouse_location=warehouse_location,
                invoice_number=(data.get("invoiceNumber") or "").strip(),
                received_by=(data.get("receivedBy") or "").strip(),
                notes=(data.get("notes") or "").strip(),
                line_count=len(qty_by_product),
                total_units=sum(qty_by_product.values()),
                user=request.user if request.user.is_authenticated else None,
            )
            for pid, add_qty in qty_by_product.items():
                try:
                    product = Product.objects.select_for_update().get(pk=pid)
                except Product.DoesNotExist:
                    return Response(
                        {"detail": f"Unknown product id {pid}"},
                        status=status.HTTP_400_BAD_REQUEST,
                    )
                StockReceiptLine.objects.create(
                    receipt=receipt,
                    product=product,
                    quantity=add_qty,
                )
                product.stock += add_qty
                if supplier_name:
                    product.supplier = supplier_name
                if supplier_code:
                    product.supplier_code = supplier_code
                if warehouse_location:
                    product.location = warehouse_location
                product.save()

        return Response({"ok": True}, status=status.HTTP_200_OK)


class PosCheckoutStockView(APIView):
    """
    Commit a POS sale: creates Sale + SaleLine rows and decrements Product.stock
    inside one atomic transaction. Line prices come from inventory (not from client).
    """

    authentication_classes = []
    permission_classes = [AllowAny]

    def post(self, request):
        ser = PosCheckoutSerializer(data=request.data)
        ser.is_valid(raise_exception=True)
        data = ser.validated_data
        lines_in = data["lines"]

        qty_by_product = {}
        for it in lines_in:
            pid = it["productId"]
            qty_by_product[pid] = qty_by_product.get(pid, 0) + it["quantity"]

        subtotal = Decimal("0")
        line_specs = []

        with transaction.atomic():
            for pid, qty in qty_by_product.items():
                try:
                    product = Product.objects.select_for_update().get(pk=pid)
                except Product.DoesNotExist:
                    return Response(
                        {"detail": f"Unknown product id {pid}"},
                        status=status.HTTP_400_BAD_REQUEST,
                    )
                if product.stock < qty:
                    return Response(
                        {
                            "detail": (
                                f"Insufficient stock for {product.name} "
                                f"(need {qty}, have {product.stock})."
                            )
                        },
                        status=status.HTTP_400_BAD_REQUEST,
                    )
                unit_price = Decimal(str(product.selling_price))
                line_sub = (unit_price * Decimal(qty)).quantize(Decimal("0.01"))
                subtotal += line_sub
                line_specs.append((product, qty, unit_price, line_sub))

            tax = (subtotal * Decimal("0.12")).quantize(Decimal("0.01"))
            total = (subtotal + tax).quantize(Decimal("0.01"))
            items_count = sum(spec[1] for spec in line_specs)

            sale = Sale.objects.create(
                subtotal=subtotal,
                tax=tax,
                total=total,
                items_count=items_count,
                payment_method=(data.get("paymentMethod") or "Cash").strip() or "Cash",
                is_pay_later=bool(data.get("isPayLater")),
                customer_name=(data.get("customerName") or "").strip(),
                customer_phone=(data.get("customerPhone") or "").strip(),
                customer_address=(data.get("customerAddress") or "").strip(),
            )
            for product, qty, unit_price, line_sub in line_specs:
                SaleLine.objects.create(
                    sale=sale,
                    product=product,
                    quantity=qty,
                    unit_price=unit_price,
                    line_subtotal=line_sub,
                    product_name=product.name,
                )
                product.stock -= qty
                product.save(update_fields=["stock"])

        sale = Sale.objects.prefetch_related("lines").get(pk=sale.pk)
        out = SaleOutSerializer(sale)
        return Response({"sale": out.data}, status=status.HTTP_201_CREATED)


class PosSaleListView(generics.ListAPIView):
    authentication_classes = []
    permission_classes = [AllowAny]
    serializer_class = SaleOutSerializer
    queryset = Sale.objects.prefetch_related("lines").all()


class PosSaleMarkPaidView(APIView):
    authentication_classes = []
    permission_classes = [AllowAny]

    def post(self, request, pk):
        try:
            sale = Sale.objects.prefetch_related("lines").get(pk=pk, is_pay_later=True)
        except Sale.DoesNotExist:
            return Response(
                {"detail": "Collectible sale not found."},
                status=status.HTTP_404_NOT_FOUND,
            )

        if sale.paid_at is None:
            sale.paid_at = timezone.now()
            sale.payment_method = "Paid Collectible"
            sale.save(update_fields=["paid_at", "payment_method"])

        return Response({"sale": SaleOutSerializer(sale).data})


class StockReceiptListView(generics.ListAPIView):
    authentication_classes = []
    queryset = StockReceipt.objects.all()
    permission_classes = [AllowAny]
    serializer_class = StockReceiptSerializer
