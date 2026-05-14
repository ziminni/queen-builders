# apps/users/views.py
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import AllowAny
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth import authenticate
from .serializers import UserSerializer, RegisterSerializer
from .audit import record_audit

class LoginView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        email = request.data.get('email')
        password = request.data.get('password')
        
        user = authenticate(email=email, password=password)
        
        if user:
            record_audit(
                module='System',
                category='Movement logs',
                summary=f'User logged in: {user.full_name or user.email}',
                detail=f'Email: {user.email}\nRole: {user.role}',
                actor_email=user.email,
                actor_role=user.role,
            )
            refresh = RefreshToken.for_user(user)
            
            refresh['role'] = user.role
            refresh['user_id'] = user.id
            refresh['email'] = user.email
            
            return Response({
                'access': str(refresh.access_token),
                'refresh': str(refresh),
                'user': UserSerializer(user).data,
                'role': user.role,
            })
        else:
            return Response(
                {'error': 'Invalid credentials'}, 
                status=status.HTTP_401_UNAUTHORIZED
            )

class LogoutView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        user = request.user if request.user.is_authenticated else None
        email = request.data.get('email') or (user.email if user else '')
        role = request.data.get('role') or (user.role if user else '')
        name = request.data.get('name') or email or 'Unknown user'
        record_audit(
            module='System',
            category='Movement logs',
            summary=f'User logged out: {name}',
            detail=f'Email: {email or "unknown"}\nRole: {role or "unknown"}',
            actor=user,
            actor_email=email,
            actor_role=role,
        )
        return Response({'ok': True}, status=status.HTTP_200_OK)

class RegisterView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            return Response(UserSerializer(user).data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
